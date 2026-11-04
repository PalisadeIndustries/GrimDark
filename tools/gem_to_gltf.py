#!/usr/bin/env python3
"""Convert a GEM engine (Men of War) model to a binary glTF (.glb) for Godot.

Reads:
  * the .mdl skeleton (text)
  * the .ply mesh referenced by the skeleton's first VolumeView (GEM binary, not standard PLY)
  * the .mtl materials named by the mesh (text)
  * optional textures (.png/.jpg/.tga/.dds) found in --textures; .tga/.dds need Pillow

Writes one .glb with the mesh, materials, skeleton and skin weights. Converts GEM's
left-handed Z-up units to glTF's right-handed Y-up metres (model facing +Z).

Usage:
  python3 tools/gem_to_gltf.py art_source/gem/traitor_guard_1/traitor_guard_1.mdl \\
      -o game/assets/characters/traitor_guard/traitor_guard_1.glb [--textures DIR] [--scale 0.05]

Only standard-library Python is required. Pillow is used only to convert .tga/.dds textures.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import struct
import sys
from dataclasses import dataclass, field

DEFAULT_SCALE = 0.05  # GEM units to metres: a ~36-unit soldier becomes ~1.8 m

# ---------------------------------------------------------------------------
# Small 4x4 matrix helpers. Matrices are row-major lists, used with column vectors.
# ---------------------------------------------------------------------------


def mat_identity() -> list[list[float]]:
    return [[1.0 if r == c else 0.0 for c in range(4)] for r in range(4)]


def mat_mul(a, b):
    return [[sum(a[r][k] * b[k][c] for k in range(4)) for c in range(4)] for r in range(4)]


def mat_apply(m, p, w=1.0):
    return [m[r][0] * p[0] + m[r][1] * p[1] + m[r][2] * p[2] + m[r][3] * w for r in range(3)]


def det3(m) -> float:
    return (m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
            - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
            + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]))


def mat_rigid_inverse(m):
    """Inverse of a rotation + translation matrix."""
    rt = [[m[c][r] for c in range(3)] for r in range(3)]
    t = [m[0][3], m[1][3], m[2][3]]
    inv = mat_identity()
    for r in range(3):
        for c in range(3):
            inv[r][c] = rt[r][c]
        inv[r][3] = -(rt[r][0] * t[0] + rt[r][1] * t[1] + rt[r][2] * t[2])
    return inv


def orthonormalize(m):
    """Gram-Schmidt on the rotation columns, to clean up rounding in exported files."""
    cols = [[m[r][c] for r in range(3)] for c in range(3)]
    out = []
    for c in cols:
        for o in out:
            d = sum(c[i] * o[i] for i in range(3))
            c = [c[i] - d * o[i] for i in range(3)]
        n = math.sqrt(sum(x * x for x in c)) or 1.0
        out.append([x / n for x in c])
    # keep handedness of the third axis consistent with the first two
    cross = [out[0][1] * out[1][2] - out[0][2] * out[1][1],
             out[0][2] * out[1][0] - out[0][0] * out[1][2],
             out[0][0] * out[1][1] - out[0][1] * out[1][0]]
    if sum(cross[i] * out[2][i] for i in range(3)) < 0:
        cross = [-x for x in cross]
    out[2] = cross
    r = mat_identity()
    for c in range(3):
        for i in range(3):
            r[i][c] = out[c][i]
        r[c][3] = m[c][3]
    return r


def quat_from_matrix(m) -> list[float]:
    """glTF quaternion [x, y, z, w] from a proper rotation matrix."""
    tr = m[0][0] + m[1][1] + m[2][2]
    if tr > 0:
        s = math.sqrt(tr + 1.0) * 2
        w, x, y, z = 0.25 * s, (m[2][1] - m[1][2]) / s, (m[0][2] - m[2][0]) / s, (m[1][0] - m[0][1]) / s
    elif m[0][0] > m[1][1] and m[0][0] > m[2][2]:
        s = math.sqrt(1.0 + m[0][0] - m[1][1] - m[2][2]) * 2
        w, x, y, z = (m[2][1] - m[1][2]) / s, 0.25 * s, (m[0][1] + m[1][0]) / s, (m[0][2] + m[2][0]) / s
    elif m[1][1] > m[2][2]:
        s = math.sqrt(1.0 + m[1][1] - m[0][0] - m[2][2]) * 2
        w, x, y, z = (m[0][2] - m[2][0]) / s, (m[0][1] + m[1][0]) / s, 0.25 * s, (m[1][2] + m[2][1]) / s
    else:
        s = math.sqrt(1.0 + m[2][2] - m[0][0] - m[1][1]) * 2
        w, x, y, z = (m[1][0] - m[0][1]) / s, (m[0][2] + m[2][0]) / s, (m[1][2] + m[2][1]) / s, 0.25 * s
    n = math.sqrt(x * x + y * y + z * z + w * w)
    return [x / n, y / n, z / n, w / n]


# GEM is left-handed, Z up, model facing +X, model's left on -Y.
# glTF is right-handed, Y up, model facing +Z, model's left on +X.
# So glTF (x, y, z) = (-gem_y, gem_z, gem_x). This is a mirror (det -1), as expected for LH -> RH.
AXIS = [[0.0, -1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [1.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 1.0]]

# ---------------------------------------------------------------------------
# GEM text formats (.mdl, .mtl, .def): nested { } lists.
# ---------------------------------------------------------------------------

_TOKEN = re.compile(r'\{|\}|"[^"]*"|[^\s{}"]+')


def parse_braces(text: str) -> list:
    text = re.sub(r"(?m)^\s*;[^\n]*", "", text)  # comments are whole lines starting with ';'
    tokens = _TOKEN.findall(text)
    pos = 0

    def node():
        nonlocal pos
        pos += 1  # skip '{'
        out = []
        while tokens[pos] != "}":
            if tokens[pos] == "{":
                out.append(node())
            else:
                tok = tokens[pos]
                out.append(tok[1:-1] if tok.startswith('"') else tok)
                pos += 1
        pos += 1
        return out

    items = []
    while pos < len(tokens):
        if tokens[pos] == "{":
            items.append(node())
        else:
            pos += 1
    return items


@dataclass
class Bone:
    name: str
    parent: int
    local: list
    volume_views: list = field(default_factory=list)


def _bone_local(items: list):
    m = mat_identity()
    for it in items:
        if not isinstance(it, list) or not it:
            continue
        key, vals = it[0], it[1:]
        if key in ("Orientation", "Matrix34"):
            v = [float(x) for x in vals]
            for row in range(3):  # each row of the file is a local axis in parent space -> a column here
                for i in range(3):
                    m[i][row] = v[row * 3 + i]
            if key == "Matrix34":
                m[0][3], m[1][3], m[2][3] = v[9], v[10], v[11]
        elif key == "Position":
            m[0][3], m[1][3], m[2][3] = (float(x) for x in vals[:3])
    return m


def parse_mdl(path: str) -> list[Bone]:
    with open(path, encoding="utf-8", errors="replace") as f:
        top = parse_braces(f.read())
    skeleton = next(it for it in top if it and it[0] == "Skeleton")
    bones: list[Bone] = []

    def walk(items, parent):
        bone = Bone(items[1], parent, _bone_local(items))
        index = len(bones)
        bones.append(bone)
        for it in items[2:]:
            if isinstance(it, list) and it and it[0] == "bone":
                walk(it, index)
            elif isinstance(it, list) and it and it[0] == "LODView":
                bone.volume_views = [v[1] for v in it[1:] if isinstance(v, list) and v[0] == "VolumeView"]
            elif isinstance(it, list) and it and it[0] == "VolumeView":
                bone.volume_views = [it[1]]

    for it in skeleton[1:]:
        if isinstance(it, list) and it and it[0] == "bone":
            walk(it, -1)
    return bones


def parse_mtl(path: str) -> dict:
    with open(path, encoding="utf-8", errors="replace") as f:
        top = parse_braces(f.read())
    out = {"type": top[0][1] if top and len(top[0]) > 1 else "simple"}
    for it in top[0][2:] if top else []:
        if isinstance(it, list) and len(it) > 1:
            out[it[0]] = it[1]
    return out


# ---------------------------------------------------------------------------
# GEM binary mesh (.ply)
# ---------------------------------------------------------------------------


@dataclass
class GemMesh:
    first_tri: int
    tri_count: int
    flags: int
    material: str
    bone_subset: list


@dataclass
class GemPly:
    bounds: tuple
    skin_bones: list
    meshes: list
    positions: list
    normals: list
    uvs: list
    bone_ids: list
    weights: list
    indices: list


def parse_ply(path: str) -> GemPly:
    with open(path, "rb") as f:
        d = f.read()
    if d[:4] != b"EPLY":
        sys.exit(f"{path}: not a GEM mesh (missing EPLY header)")
    pos = 4
    bounds = ()
    skin_bones: list[str] = []
    meshes: list[GemMesh] = []
    positions, normals, uvs, bone_ids, weights, indices = [], [], [], [], [], []
    while pos + 4 <= len(d):
        tag = d[pos:pos + 4]
        pos += 4
        if tag == b"BNDS":
            bounds = struct.unpack_from("<6f", d, pos)
            pos += 24
        elif tag == b"SKIN":
            (count,) = struct.unpack_from("<I", d, pos)
            pos += 4
            for _ in range(count):
                n = d[pos]
                skin_bones.append(d[pos + 1:pos + 1 + n].decode("latin-1"))
                pos += 1 + n
        elif tag == b"MESH":
            _kind, first_tri, tri_count, flags = struct.unpack_from("<4I", d, pos)
            pos += 16
            if flags & 0x200:  # material colour present
                pos += 4
            n = d[pos]
            material = d[pos + 1:pos + 1 + n].decode("latin-1")
            pos += 1 + n
            subset = []
            if skin_bones:
                n = d[pos]
                subset = list(d[pos + 1:pos + 1 + n])
                pos += 1 + n
            meshes.append(GemMesh(first_tri, tri_count, flags, material, subset))
        elif tag == b"VERT":
            count, stride, vflags = struct.unpack_from("<IHH", d, pos)
            pos += 8
            if stride not in (32, 56) or (stride == 56 and not skin_bones):
                sys.exit(f"{path}: unsupported vertex format (stride {stride}, flags {vflags:#x})")
            for i in range(count):
                o = pos + i * stride
                positions.append(struct.unpack_from("<3f", d, o))
                if stride == 56:  # position, weight, 4 bone bytes, normal, uv, tangent
                    w = struct.unpack_from("<f", d, o + 12)[0]
                    ids = d[o + 16:o + 20]
                    normals.append(struct.unpack_from("<3f", d, o + 20))
                    uvs.append(struct.unpack_from("<2f", d, o + 32))
                    bone_ids.append((ids[0], ids[1]))
                    weights.append((w, 1.0 - w))
                else:  # position, normal, uv
                    normals.append(struct.unpack_from("<3f", d, o + 12))
                    uvs.append(struct.unpack_from("<2f", d, o + 24))
            pos += count * stride
        elif tag == b"INDX":
            (count,) = struct.unpack_from("<I", d, pos)
            pos += 4
            indices = list(struct.unpack_from(f"<{count}H", d, pos))
            pos += count * 2
        else:
            break  # trailing data or an unknown chunk
    return GemPly(bounds, skin_bones, meshes, positions, normals, uvs, bone_ids, weights, indices)


# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------


def find_file(name: str, dirs: list[str]) -> str | None:
    base = os.path.basename(name.replace("\\", "/"))
    for d in dirs:
        p = os.path.join(d, base)
        if os.path.isfile(p):
            return p
    return None


def find_texture(gem_path: str, dirs: list[str]) -> str | None:
    base = os.path.basename(gem_path.replace("\\", "/"))
    for d in dirs:
        for ext in (".png", ".jpg", ".jpeg", ".tga", ".dds"):
            p = os.path.join(d, base + ext)
            if os.path.isfile(p):
                return p
    return None


def _load_image(path: str):
    try:
        from PIL import Image
    except ImportError:
        sys.exit(f"Pillow is needed to read {path} (pip install pillow)")
    return Image.open(path)


def _png(image) -> bytes:
    from io import BytesIO
    buf = BytesIO()
    image.save(buf, "PNG")
    return buf.getvalue()


def texture_png_bytes(path: str) -> tuple[bytes, str]:
    """Colour texture as PNG/JPEG bytes."""
    ext = os.path.splitext(path)[1].lower()
    if ext in (".png", ".jpg", ".jpeg"):
        with open(path, "rb") as f:
            return f.read(), "image/png" if ext == ".png" else "image/jpeg"
    return _png(_load_image(path).convert("RGB")), "image/png"


def normal_png_bytes(path: str) -> bytes:
    """Normal map as a standard glTF (OpenGL, +Y up) RGB normal map.

    GEM normal maps are DirectX style and often 'DXT5nm' (X in alpha, Y in green). Detected
    automatically: if the red channel is flat and alpha varies, X is read from alpha.
    The green channel is inverted to go from DirectX (-Y) to OpenGL (+Y)."""
    from PIL import Image, ImageStat
    img = _load_image(path).convert("RGBA")
    r, g, b, a = img.split()
    stats = ImageStat.Stat(img)
    swizzled = stats.stddev[0] < 2 and stats.stddev[3] > 2
    x_chan = a if swizzled else r
    xs, ys = x_chan.tobytes(), g.tobytes()
    out = bytearray(len(xs) * 3)
    for i in range(len(xs)):
        x = xs[i] / 127.5 - 1.0
        y = -(ys[i] / 127.5 - 1.0)
        z = math.sqrt(max(0.0, 1.0 - x * x - y * y))
        out[i * 3] = int(round((x + 1.0) * 127.5))
        out[i * 3 + 1] = int(round((y + 1.0) * 127.5))
        out[i * 3 + 2] = int(round((z + 1.0) * 127.5))
    return _png(Image.frombytes("RGB", img.size, bytes(out)))


def roughness_png_bytes(path: str) -> bytes:
    """glTF metallic-roughness texture approximated from a GEM specular map.

    Brighter specular -> smoother. Green = roughness, blue = metallic (always 0)."""
    from PIL import Image
    spec = _load_image(path).convert("L")
    rough = spec.point(lambda v: max(60, 255 - v * 3))
    zero = Image.new("L", spec.size, 0)
    return _png(Image.merge("RGB", (zero, rough, zero)))


class GlbBuilder:
    def __init__(self):
        self.bin = bytearray()
        self.gltf = {"asset": {"version": "2.0", "generator": "GrimDark gem_to_gltf.py"},
                     "buffers": [], "bufferViews": [], "accessors": []}

    def _view(self, data: bytes, target: int | None = None) -> int:
        while len(self.bin) % 4:
            self.bin.append(0)
        view = {"buffer": 0, "byteOffset": len(self.bin), "byteLength": len(data)}
        if target:
            view["target"] = target
        self.bin.extend(data)
        self.gltf["bufferViews"].append(view)
        return len(self.gltf["bufferViews"]) - 1

    def accessor(self, values: list, fmt: str, comp: int, kind: str, target=None, minmax=False) -> int:
        flat = [x for v in values for x in (v if isinstance(v, (list, tuple)) else (v,))]
        view = self._view(struct.pack(f"<{len(flat)}{fmt}", *flat), target)
        acc = {"bufferView": view, "componentType": comp, "count": len(values), "type": kind}
        if minmax:
            n = len(values[0])
            acc["min"] = [min(v[i] for v in values) for i in range(n)]
            acc["max"] = [max(v[i] for v in values) for i in range(n)]
        self.gltf["accessors"].append(acc)
        return len(self.gltf["accessors"]) - 1

    def image(self, data: bytes, mime: str, name: str) -> int:
        view = self._view(data)
        self.gltf.setdefault("images", []).append({"bufferView": view, "mimeType": mime, "name": name})
        self.gltf.setdefault("textures", []).append({"source": len(self.gltf["images"]) - 1})
        return len(self.gltf["textures"]) - 1

    def write(self, path: str):
        while len(self.bin) % 4:
            self.bin.append(0)
        self.gltf["buffers"] = [{"byteLength": len(self.bin)}]
        js = json.dumps(self.gltf, separators=(",", ":")).encode()
        js += b" " * (-len(js) % 4)
        total = 12 + 8 + len(js) + 8 + len(self.bin)
        with open(path, "wb") as f:
            f.write(struct.pack("<III", 0x46546C67, 2, total))
            f.write(struct.pack("<II", len(js), 0x4E4F534A) + js)
            f.write(struct.pack("<II", len(self.bin), 0x004E4942) + bytes(self.bin))


def convert(mdl_path: str, out_path: str, texture_dirs: list[str], scale: float) -> dict:
    src_dir = os.path.dirname(os.path.abspath(mdl_path))
    bones = parse_mdl(mdl_path)
    skin_bone = next((b for b in bones if b.volume_views), None)
    if skin_bone is None:
        sys.exit(f"{mdl_path}: no bone with a VolumeView (mesh) found")
    ply_path = find_file(skin_bone.volume_views[0], [src_dir])
    if ply_path is None:
        sys.exit(f"Mesh {skin_bone.volume_views[0]} not found next to {mdl_path}")
    ply = parse_ply(ply_path)

    # Global bone matrices in GEM space.
    gem_global = []
    for b in bones:
        local = b.local
        gem_global.append(local if b.parent < 0 else mat_mul(gem_global[b.parent], local))

    # Bone matrices in glTF space: change axes, keep rotations proper (flip a local axis if mirrored).
    flip = mat_identity()
    flip[1][1] = -1.0
    gltf_global = []
    for g in gem_global:
        m = mat_mul(AXIS, g)
        if det3(m) < 0:
            m = mat_mul(m, flip)
        m = orthonormalize(m)
        for r in range(3):
            m[r][3] *= scale
        gltf_global.append(m)

    # Vertices: GEM mesh space -> skin bone -> world -> glTF.
    skin_index = bones.index(skin_bone)
    to_world = mat_mul(AXIS, gem_global[skin_index])
    positions = [[c * scale for c in mat_apply(to_world, p)] for p in ply.positions]
    normals = []
    for n in ply.normals:
        v = mat_apply(to_world, n, 0.0)
        ln = math.sqrt(sum(x * x for x in v)) or 1.0
        normals.append([x / ln for x in v])
    uvs = [list(uv) for uv in ply.uvs]

    # Triangles: pick the winding that agrees with the vertex normals (glTF front faces are CCW).
    tris = [ply.indices[i:i + 3] for i in range(0, len(ply.indices), 3)]
    agree = 0
    for a, b, c in tris:
        pa, pb, pc = positions[a], positions[b], positions[c]
        e1 = [pb[i] - pa[i] for i in range(3)]
        e2 = [pc[i] - pa[i] for i in range(3)]
        fn = [e1[1] * e2[2] - e1[2] * e2[1], e1[2] * e2[0] - e1[0] * e2[2], e1[0] * e2[1] - e1[1] * e2[0]]
        vn = [normals[a][i] + normals[b][i] + normals[c][i] for i in range(3)]
        agree += 1 if sum(fn[i] * vn[i] for i in range(3)) > 0 else 0
    flip_winding = agree < len(tris) / 2
    if flip_winding:
        tris = [[a, c, b] for a, b, c in tris]

    glb = GlbBuilder()
    gltf = glb.gltf
    ARRAY, ELEMENT = 34962, 34963
    pos_acc = glb.accessor(positions, "f", 5126, "VEC3", ARRAY, minmax=True)
    nrm_acc = glb.accessor(normals, "f", 5126, "VEC3", ARRAY)
    uv_acc = glb.accessor(uvs, "f", 5126, "VEC2", ARRAY)
    attributes = {"POSITION": pos_acc, "NORMAL": nrm_acc, "TEXCOORD_0": uv_acc}

    # Nodes: one per bone, then the mesh node and a scene root.
    nodes = []
    for i, b in enumerate(bones):
        parent_m = gltf_global[b.parent] if b.parent >= 0 else mat_identity()
        local = mat_mul(mat_rigid_inverse(parent_m), gltf_global[i])
        node = {"name": b.name, "translation": [local[0][3], local[1][3], local[2][3]],
                "rotation": quat_from_matrix(local)}
        nodes.append(node)
    for i, b in enumerate(bones):
        if b.parent >= 0:
            nodes[b.parent].setdefault("children", []).append(i)

    skinned = bool(ply.skin_bones) and bool(ply.bone_ids)
    if skinned:
        name_to_node = {b.name: i for i, b in enumerate(bones)}
        missing = [n for n in ply.skin_bones if n not in name_to_node]
        if missing:
            sys.exit(f"Skin bones missing from the skeleton: {missing}")
        joints = list(range(len(bones)))  # every bone is a joint; keeps indices simple
        root_joint = next(i for i, b in enumerate(bones) if b.parent < 0)

        # Per-mesh bone subsets are 1-based indices into the SKIN list (0 = no bone -> root).
        vert_subset = [None] * len(positions)
        for m in ply.meshes:
            for t in tris[m.first_tri:m.first_tri + m.tri_count]:
                for v in t:
                    vert_subset[v] = m.bone_subset

        def joint_for(subset, local_id):
            if subset is None or local_id >= len(subset) or subset[local_id] == 0:
                return root_joint
            return name_to_node[ply.skin_bones[subset[local_id] - 1]]

        joints_data, weights_data = [], []
        for v, (ids, ws) in enumerate(zip(ply.bone_ids, ply.weights)):
            subset = vert_subset[v]
            j0, j1 = joint_for(subset, ids[0]), joint_for(subset, ids[1])
            w0, w1 = ws
            if w1 <= 1e-6 or j0 == j1:
                joints_data.append([j0, 0, 0, 0])
                weights_data.append([1.0, 0.0, 0.0, 0.0])
            else:
                joints_data.append([j0, j1, 0, 0])
                weights_data.append([w0, w1, 0.0, 0.0])
        attributes["JOINTS_0"] = glb.accessor(joints_data, "H", 5123, "VEC4", ARRAY)
        attributes["WEIGHTS_0"] = glb.accessor(weights_data, "f", 5126, "VEC4", ARRAY)

        ibms = []
        for j in joints:
            inv = mat_rigid_inverse(gltf_global[j])
            ibms.append([inv[r][c] for c in range(4) for r in range(4)])  # column-major
        ibm_acc = glb.accessor(ibms, "f", 5126, "MAT4")
        gltf["skins"] = [{"name": "skeleton", "joints": joints, "inverseBindMatrices": ibm_acc,
                          "skeleton": root_joint}]

    # Materials and primitives.
    materials, mat_index, report_mats = [], {}, []
    tex_cache: dict = {}
    primitives = []
    for m in ply.meshes:
        if m.material not in mat_index:
            mtl_path = find_file(m.material, [src_dir])
            mtl = parse_mtl(mtl_path) if mtl_path else {}
            mat = {"name": os.path.splitext(m.material)[0],
                   "pbrMetallicRoughness": {"baseColorFactor": [0.55, 0.53, 0.48, 1.0],
                                            "metallicFactor": 0.0, "roughnessFactor": 0.85},
                   "extras": {k: v for k, v in mtl.items()}}
            found = []
            for key in ("diffuse", "bump", "specular"):
                if key not in mtl:
                    continue
                tex_path = find_texture(mtl[key], texture_dirs)
                if not tex_path:
                    continue
                name = os.path.basename(mtl[key])
                if key not in tex_cache:
                    tex_cache[key] = {}
                if tex_path not in tex_cache[key]:
                    if key == "diffuse":
                        data, mime = texture_png_bytes(tex_path)
                    elif key == "bump":
                        data, mime = normal_png_bytes(tex_path), "image/png"
                    else:
                        data, mime = roughness_png_bytes(tex_path), "image/png"
                    tex_cache[key][tex_path] = glb.image(data, mime, name)
                tex = tex_cache[key][tex_path]
                pbr = mat["pbrMetallicRoughness"]
                if key == "diffuse":
                    pbr["baseColorTexture"] = {"index": tex}
                    pbr["baseColorFactor"] = [1.0, 1.0, 1.0, 1.0]
                elif key == "bump":
                    mat["normalTexture"] = {"index": tex}
                else:
                    pbr["metallicRoughnessTexture"] = {"index": tex}
                    pbr["roughnessFactor"] = 1.0
                found.append(os.path.basename(tex_path))
            mat_index[m.material] = len(materials)
            materials.append(mat)
            report_mats.append((m.material, "found" if mtl_path else "MISSING .mtl",
                                {k: v for k, v in mtl.items() if k in ("diffuse", "bump", "specular")}, found))
        part = [i for t in tris[m.first_tri:m.first_tri + m.tri_count] for i in t]
        idx_acc = glb.accessor(part, "H" if len(positions) < 65536 else "I",
                               5123 if len(positions) < 65536 else 5125, "SCALAR", ELEMENT)
        primitives.append({"attributes": attributes, "indices": idx_acc, "material": mat_index[m.material]})

    gltf["materials"] = materials
    model_name = os.path.splitext(os.path.basename(mdl_path))[0]
    gltf["meshes"] = [{"name": model_name, "primitives": primitives}]
    mesh_node = {"name": model_name + "_mesh", "mesh": 0}
    if skinned:
        mesh_node["skin"] = 0
    nodes.append(mesh_node)
    roots = [i for i, b in enumerate(bones) if b.parent < 0] + [len(nodes) - 1]
    nodes.append({"name": model_name, "children": roots})
    gltf["nodes"] = nodes
    gltf["scenes"] = [{"name": model_name, "nodes": [len(nodes) - 1]}]
    gltf["scene"] = 0

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    glb.write(out_path)

    ys = [p[1] for p in positions]
    return {"mesh": os.path.basename(ply_path), "vertices": len(positions), "triangles": len(tris),
            "parts": len(ply.meshes), "bones": len(bones), "skin_bones": len(ply.skin_bones),
            "height_m": round(max(ys) - min(ys), 3), "min_y_m": round(min(ys), 3),
            "winding_flipped": flip_winding, "materials": report_mats,
            "lods_not_converted": skin_bone.volume_views[1:]}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("mdl", help="GEM .mdl skeleton file (the .ply and .mtl files must be next to it)")
    ap.add_argument("-o", "--output", required=True, help="output .glb path")
    ap.add_argument("--textures", action="append", default=[], help="folder to search for textures (repeatable)")
    ap.add_argument("--scale", type=float, default=DEFAULT_SCALE, help=f"GEM units to metres (default {DEFAULT_SCALE})")
    args = ap.parse_args()
    report = convert(args.mdl, args.output, args.textures + [os.path.dirname(os.path.abspath(args.mdl))], args.scale)
    print(f"Wrote {args.output}")
    print(f"  {report['vertices']} vertices, {report['triangles']} triangles, {report['parts']} parts")
    print(f"  {report['bones']} bones ({report['skin_bones']} skinned), height {report['height_m']} m, "
          f"lowest point {report['min_y_m']} m, winding flipped: {report['winding_flipped']}")
    for name, status, refs, found in report["materials"]:
        print(f"  material {name}: {status}; textures referenced {refs or '-'}; embedded {found or 'none'}")
    if report["lods_not_converted"]:
        print(f"  LODs not converted: {', '.join(report['lods_not_converted'])}")


if __name__ == "__main__":
    main()
