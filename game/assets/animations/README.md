# Animations

Drop humanoid animations here (`.glb`, `.gltf`, `.fbx`, or Godot `AnimationLibrary` `.res`/`.tres`) and they
appear at the Animation Station in the test range.

For animations made on another skeleton (Mixamo, CC0 packs, Blender rigs), open the file's import settings in
Godot, select its Skeleton3D, add a **BoneMap** with **SkeletonProfileHumanoid** (Godot auto-maps most common
rigs), and reimport. The bones are then renamed to the humanoid names the traitor guard uses
(`assets/characters/traitor_guard/traitor_guard_bone_map.tres`), so the animations retarget onto him.
