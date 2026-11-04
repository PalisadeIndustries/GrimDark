# GrimDark — Game Design Document

> **Working title:** GrimDark
> **Genre:** 45-player co-op PvE tactical combined-arms shooter
> **Setting:** Warhammer 40,000, playing a fallen, Chaos-corrupted Astra Militarum regiment in the vein of the Moebian 6th
> **Project type:** Free, non-commercial fan project
> **Document status:** Draft v0.2. All numbers are starting values to tune in playtests, not final balance.

---

## Table of Contents

1. [Vision](#1-vision)
2. [Core Pillars](#2-core-pillars)
3. [Setting and Tone](#3-setting-and-tone)
4. [The Platoon: Structure and Roles](#4-the-platoon-structure-and-roles)
5. [Core Gameplay Loop](#5-core-gameplay-loop)
6. [Combat Systems](#6-combat-systems)
7. [Weapons and Equipment](#7-weapons-and-equipment)
8. [Progression: Marks of Favour](#8-progression-marks-of-favour)
9. [Squad Leader Call-Ins](#9-squad-leader-call-ins)
10. [The Leman Russ](#10-the-leman-russ)
11. [Platoon Commander: Tactical Command](#11-platoon-commander-tactical-command)
12. [Logistics and Resupply](#12-logistics-and-resupply)
13. [Spawning, Death and Reinforcement](#13-spawning-death-and-reinforcement)
14. [Enemies and the AI Director](#14-enemies-and-the-ai-director)
15. [Missions and Maps](#15-missions-and-maps)
16. [Communication](#16-communication)
17. [UI and HUD](#17-ui-and-hud)
18. [Art and Audio Direction](#18-art-and-audio-direction)
19. [Meta-Progression](#19-meta-progression)
20. [Technical Considerations](#20-technical-considerations)
21. [Risks and Mitigations](#21-risks-and-mitigations)
22. [Open Questions](#22-open-questions)
23. [Roadmap](#23-roadmap)
24. [Appendix: Tuning Tables](#appendix-tuning-tables)

---

## 1. Vision

Forty-five players form one platoon of a traitor Guard regiment. They advance through an Imperial world against an AI-directed loyalist defence. Every player has a job in a real chain of command. The commander plans from the map, squad leaders turn orders into action, heavy weapons teams lock down lanes, and carrying teams keep the guns fed.

The fantasy is **"the horde with a plan."** You start as a ragged cultist with a stub gun. You earn your way into carapace, call down plague-ridden horrors, and eventually see a Leman Russ roll up because your squad killed enough of the Emperor's servants to earn it.

**Elevator pitch:** *A 45-player co-op war game where you play the bad guys. A traitor platoon grows from cultist rabble into a blessed war machine one kill at a time, and lives or dies by its supply lines.*

## 2. Core Pillars

| Pillar | What it means | Design test |
|---|---|---|
| **Chain of Command** | Every role matters, and orders flow down through the commander, squad leaders and troopers. | Does this feature give a role a decision only that role can make? |
| **Earned Corruption** | Power is earned in the match through kills and contribution, and you can see it on your character. | Can other players see that someone has progressed? |
| **Logistics Is Combat** | Ammunition, munitions and positions are physical things that have to be carried. A cut supply line is a lost fight. | Would running out of ammo here make a story? |
| **Braced and Deliberate** | Heavy firepower is positional. You commit to a spot, defend it and keep it fed. | Does using this weapon create a position worth protecting or attacking? |
| **Dynamic Response** | The AI Director punishes static plans and rewards a platoon that adapts. | Does the platoon have to change its plan at least twice per operation? |

## 3. Setting and Tone

### 3.1 The Player Faction: the Moebian 6th
- The players are one platoon of the **Moebian 6th**, an Astra Militarum regiment that has fallen to **Nurgle**, the Plague God. The playable unit is **3rd Platoon, "the Weeping Company"**.
- The regiment is a mix of veteran traitor Guardsmen ("Moebians"), who kept their Guard discipline, drill and equipment, and the **cultist mobs** they recruit from every district they take. Cultists who survive long enough are taken into the ranks, which is the in-fiction reason for the cultist → Moebian progression (Section 8).
- They still fight like Guardsmen: platoons, squads, vox discipline, heavy weapons teams and supply lines. What has changed is who they serve. This is the core of the game's identity: **a professional army that happens to be rotting.**

### 3.2 Patron: Nurgle Only
The platoon is locked to Nurgle for a consistent identity. Everything Chaos-flavoured in the game comes from the Plague God:
- **Call-ins:** plague zombies, plague hounds, Nurgle-tainted Chaos Spawn.
- **Weapons:** toxin grenades, corroded and filth-coated weapons as cosmetics, Blessed-tier mutations.
- **Ogryn:** bloated, fly-covered plague Ogryn.
- **Mutations** (Blessed tier and cosmetics) are themed on resilience and decay: swollen flesh, extra toughness, boils, rot, swarming flies. Nurgle's power is **endurance**, so Chaos bonuses lean towards damage resistance and sustain, not speed or burst.
- **Flavour rule of seven:** where it makes no balance difference, use sevens (7 hounds in a double pack, a 7-second toxin cloud, 7-stage corruption on a map) as a nod to Nurgle's sacred number.

### 3.3 The World: Varrus Secundus
All operations take place on one invented hive world, **Varrus Secundus**. The Moebian 6th has landed and the war for the planet is under way. Each operation is a separate battle in that war.

| Region | Terrain | Gameplay character |
|---|---|---|
| **The Ashfields** | Ash wastes and the outer trench lines around the hive | Trench assault, artillery, long approach under fire, HWT duels |
| **Karsten Hab-Sprawl** | Dense hab-blocks and collapsed streets | Urban close-quarters, flamers and Ogryn, verticality, short supply runs but many ambushes |
| **Refinery Nine** | Promethium refineries and pipe-yards | Industrial maze, explosive tanks (risk for both sides), fires spread across the map |
| **Hollowmere Agri-Belt** | Terraced farmland and grain silos | Open ground, long sightlines, armour-heavy, the Leman Russ and lascannons shine, long exposed supply lines |
| **The Sump** | Underhive tunnels and drainage | Darkness, tight tunnels, plague zombies at their strongest, heavy weapons hard to place |
| **Basilica of Saint Vorena** | Cathedral district at the hive spire | Final assault against the Ecclesiarchy and Sisters of Battle, Desecrate objectives |

**Visible corruption:** as the platoon takes ground in an operation, captured sectors decay: grey rot spreads over stone, fungal growth, fly swarms, sickly fog. This is the main visual sign of progress through a match.

### 3.4 The Enemy: Loyalist Guard
The main enemy is the loyalist **Astra Militarum** defending the world. They mirror the player platoon (lasguns, heavy weapons teams, tanks, artillery), which makes their tactics readable and lets the AI use the same systems as the players.

| Force | Role in the game | Frequency |
|---|---|---|
| **41st Tarsine Rifles** (Astra Militarum) | Main enemy: disciplined line infantry, heavy weapons teams, Sentinels, Chimeras, Leman Russ, Basilisk artillery | Every operation |
| **Varrusian PDF** | Planetary Defence Force: poorly trained conscripts, numerous, break easily | Common, mainly early phases |
| **Ministorum and Frateris Militia** | Priests and zealot mobs: fanatic charges, morale buffs | Common in urban and cathedral regions |
| **Order of the Ashen Rose** (Sisters of Battle) | Elite power-armoured squads with flamers, melta and faith buffs; a Canoness and Penitent Engines as climax threats | Rare elite events, guaranteed in the Basilica |
| **Tempestus Scions** (Militarum Tempestus) | Elite storm troopers dropped behind the platoon's lines | Rare elite events |

- **Visual contrast:** loyalists are clean and bright (sand-khaki uniforms, polished brass, white lumen-light, blessed purity seals). The Moebians are dark olive, rust and grime with sickly green light. Players must be able to tell friend from foe at a glance at range, since both sides use similar silhouettes.
- **Tone of the enemy:** loyalist vox chatter, hymns, Commissar speeches and executions. They are brave and fanatical, and the game lets the player see that.

### 3.5 Match Structure: Standalone Operations
- Each operation is a **self-contained match** (45–60 minutes). Nothing from one operation's result carries into the next.
- Operations can be played in any order from a mission select screen. A light "war map" on the menu shows the regions of Varrus Secundus as flavour, not as persistent state.
- In-match progression (Marks of Favour, Squad Favour) **resets every operation**. Only meta-unlocks (Section 19) carry over.

### 3.6 Tone
Grim, filthy, darkly comedic, never heroic. The loyalists are the heroes of their own story, and the player is the plague moving across their world. Players start as rag-wrapped cultists with improvised flak. As they progress they become disciplined, gas-masked Moebian troopers in tarnished carapace, with growing marks of the Plague God such as boils, rust, flies and stitched flesh.

### 3.7 IP Note
Warhammer 40,000 is Games Workshop IP. GrimDark is a **free, non-commercial fan project**: no sales, no monetisation, no donations tied to the game, and no assets ripped from official products. All art, models and audio are made by the project. The game credits Games Workshop and states it is unofficial and not endorsed. Factions, units and names live in data tables so the game could be reskinned to an original setting if it ever needs to be. Invented names (the world, the loyalist regiment, the Sisters' order) are used for enemies so the project doesn't contradict established lore.

## 4. The Platoon: Structure and Roles

### 4.1 Order of Battle (45 players)

```
PLATOON (45)
├── Command Section (5)
│   ├── Platoon Commander
│   ├── Veteran Medic             (carapace)
│   ├── Veteran Vox-Operator      (carapace)
│   ├── Veteran Standard Bearer   (carapace)
│   └── Veteran Special Weapons   (carapace)
├── Heavy Weapons Section (10)
│   ├── HWT 1: Gunner + Loader
│   ├── HWT 2: Gunner + Loader
│   ├── HWT 3: Gunner + Loader
│   ├── HWT 4: Gunner + Loader
│   └── HWT 5: Gunner + Loader
└── Infantry Squads (30)
    ├── 1st Squad (10): Squad Leader, Vox-Operator, 2× Special Weapons, 6× Riflemen
    ├── 2nd Squad (10): same
    └── 3rd Squad (10): same
```

5 + 10 + 30 = **45 players.**

### 4.2 Fire Teams
Each 10-man squad splits into two fire teams. This gives bots a clear structure to follow and gives the squad leader something to manoeuvre.

| Fire team | Members | Led by |
|---|---|---|
| **Alpha** | Squad Leader, Vox-Operator, Special Weapons 1, Riflemen 1–3 | Squad Leader |
| **Bravo** | Special Weapons 2, Riflemen 4–6 | The highest-tier member of Bravo (ties go to the human player) |

The squad leader can give Bravo its own waypoint ("Bravo, flank left") without involving the commander.

### 4.3 Role Details

Every role has: what it's for, its kit, its unique abilities, and how its bot plays it. Tier references are to Section 8.

#### Platoon Commander (1)
- **Purpose:** decides where the platoon goes and why. Turns the operation's objectives into orders, sets HWT lanes, runs depot priorities and approves the Leman Russ.
- **Fights normally.** The commander is a full combatant. The only cost of Tactical Command (Section 11) is being vulnerable while using it.
- **Kit:** carapace; bolt pistol or laspistol; power sword or chainsword; 2 Frag, 1 Krak; command auspex.
- **Abilities:**
  - **Tactical Command:** opens the platoon map (Section 11).
  - **Command Auspex:** reveals enemies in a 40 m cone for 5 s, visible to the whole platoon. 60 s cooldown.
  - **Commander's Presence:** squads within 30 m get +15% suppression resistance.
- **If the commander dies:** command passes to the **acting commander** (the 1st Squad leader, or the next alive squad leader) until the commander respawns. The acting commander can open Tactical Command and give orders but **cannot approve the Leman Russ or set up depots**.
- **Bot behaviour:** follows the operation's phase plan. Splits squads across the current objectives, puts HWTs on overwatch lanes covering the main approaches, sets supply priority to whichever position reports Critical ammo, approves a tank request whenever no tank is active. Stays with the Command Section, behind the front squads.

#### Veteran Medic (1)
- **Purpose:** keeps the platoon's strength up and the reinforcement pool from draining.
- **Kit:** carapace; lasgun or laspistol + chainsword; 1 Frag; **Medicae Satchel** (10 charges).
- **Abilities:**
  - **Full Revive** (1 charge, 3 s): a Downed player comes back at full health with no Wounded status. Squadmate stabilisation takes 6 s and leaves the player Wounded (6.4).
  - **Treat Wound** (1 charge, 2 s): removes Wounded status.
  - **Blessed Stitching** (2 charges, 4 s): revives a player who has **just died** (within 10 s, not from explosive overkill). They come back with +25% damage resistance and −20% move speed for 60 s. Saves a reinforcement ticket.
  - **Drag:** pulls a Downed player to cover.
  - **Casualty Collection Point:** marks a spot on the map. Medical crates delivered there refill the satchel and treat Wounded players nearby.
- **Bot behaviour:** stays behind the most engaged squad, goes to Downed players in order of distance and safety, requests Medical crates at 3 charges left.

#### Veteran Vox-Operator (1)
- **Purpose:** the commander's link to the platoon and to higher command.
- **Kit:** carapace; lasgun; 1 Frag; **platoon vox-set** (backpack).
- **Abilities:**
  - **Platoon Link:** while the commander is within 30 m, orders reach every squad instantly. Otherwise orders go through squad vox-ops with a 5 s delay.
  - **Platoon call-ins:** needed for depot setup, supply drops and tank approval.
  - **Intercept:** listens in on enemy vox. Gives an **earlier warning** (about +30 s) of the AI Director's telegraphed attacks (14.4) and shows the approach direction on the map.
- **If killed:** the vox-set drops and any Command Section member can pick it up. Until then the commander has no Platoon Link.
- **Bot behaviour:** stays within 15 m of the commander. Uses Intercept whenever it's off cooldown.

#### Veteran Standard Bearer (1)
- **Purpose:** carries the regiment's icon, provides the forward spawn and holds the line's morale.
- **Kit:** carapace; laspistol + chainsword; 1 Frag; **Icon of Corruption**. While carrying the icon the bearer can only use the pistol.
- **Abilities:**
  - **Plant Icon** (5 s): creates a **Rally Point** (spawn every 20 s) and a 25 m aura (+25% suppression resistance, slow health regeneration).
  - **Carried aura:** 10 m, +10% suppression resistance.
  - **Moving the icon:** after the icon is picked up, it can't be planted again for 60 s.
  - **Desecration:** enemies within 5 m of a planted icon with no defenders can channel for 10 s to desecrate it. This destroys the Rally Point and gives the platoon −15% suppression resistance for 2 minutes.
- **If killed:** the icon drops. Anyone in the platoon can carry it but only the bearer can plant it.
- **Bot behaviour:** plants the icon behind the front line once an objective is secured, and moves it up after the next objective falls.

#### Veteran Special Weapons (1)
- **Purpose:** the commander's flexible reserve, usually anti-armour.
- **Kit:** carapace; any special weapon (7.2), not counted against squad limits; laspistol; 1 Frag, 1 Krak; one more ammo slot than squad special weapons.
- **Bot behaviour:** picks melta or plasma by default. Moves to the nearest enemy vehicle the platoon has spotted.

#### Heavy Weapons Teams (5 × 2)
- **Purpose:** hold ground, deny lanes and kill armour. They are only as strong as their supply line.
- **Choosing a weapon:** each team picks **Autocannon, Heavy Bolter, Heavy Stubber, Missile Launcher or Lascannon** at spawn, within platoon caps (Appendix A). Teams can **swap weapon type at any depot** (10 s). The loader's current ammo is returned and new ammo drawn.
- **Gunner kit:** heavy weapon (must be braced, 6.3); laspistol; 1 Frag. Flak armour, carapace at Weapon Team tier 2.
- **Loader kit:** lasgun; ammo for the weapon (7.1); 1 Frag; **entrenching tool** (builds a sandbag brace point in 8 s). Flak armour, carapace at Weapon Team tier 2.
- **Loader abilities:**
  - **Assisted reload:** 50% faster than the gunner reloading alone.
  - **Assisted setup:** 40% faster tripod deployment.
  - **Spotter:** marks targets for the gunner (and the platoon).
  - **Human bipod:** heavy stubber only (6.3).
  - **Supply request:** sends a request for the team's ammo type (12.7).
- **Kill credit:** shared 100% between gunner and loader.
- **Bot behaviour:** the gunner picks the weapon the platoon most needs (lascannon if enemy armour was spotted recently, otherwise heavy stubber or heavy bolter). It moves to the overwatch lane the commander set, or the nearest strong brace point covering the objective. The loader stays within 3 m, reloads and requests supply at 1 reload left.

#### Dropped Heavy Weapons
- When a gunner dies, the weapon **stays in the world** where it fell (still braced if it was braced).
- **The loader** can take it over immediately at **normal speed**, but reloads alone at the unassisted rate.
- **Anyone else** in the platoon can also pick it up and fire it, with **+50% setup and reload time**.
- Enemies can't use it but can destroy it with explosives. An unused weapon despawns after 3 minutes.
- **Gunner respawn:** a gunner who respawns **at a depot** gets a new weapon. One who respawns at a Rally Point or squad leader spawns **without** a heavy weapon and has to recover the dropped one or walk back to a depot. This makes depots and recovering weapons matter.

#### Squad Leader (3)
- **Purpose:** turns orders into action and manages the squad's call-ins.
- **Kit:** starts at Moebian Trooper tier (leaders are never cultists); lasgun, or bolt pistol + chainsword; 2 Frag, 1 Krak; **2 smoke grenades** (squad leader only); magnoculars.
- **Abilities:**
  - **Squad waypoint / Bravo waypoint** (4.2).
  - **Mark target:** marks an enemy or position for the squad.
  - **Call-ins:** spends Squad Favour (Section 9). Needs the squad vox-op within 25 m.
  - **Spawn point:** the squad can spawn on the leader (13.2).
  - **Ammo cache:** drops one Small Arms crate's worth of ammo, once per life.
- **Progression:** uses the personal tiers from tier 1 up, but can't spawn as an Ogryn while holding the slot.
- **Bot behaviour:** moves the squad to the ordered objective using cover, sends Bravo to flank when a defended position is found, spends Squad Favour as soon as a call-in is affordable and enemies are within 80 m (zombies against infantry lines, hounds against HWTs and snipers, Chaos Spawn against fortified points), and sends a tank request at 200. After 15 minutes, if no tank is active, it stops buying Chaos Spawn to save for the tank.

#### Squad Vox-Operator (3)
- **Purpose:** links the squad to the platoon and enables call-ins.
- **Kit:** lasgun; 1 Frag; squad vox-set.
- **Abilities:** relays commander orders (see Platoon Link above), enables call-ins, **requests resupply** for the squad (12.7), and can **request a free supply drop** once per operation phase (3 crates at a marked open spot, like the commander's Supply Drop, 9.8).
- **If killed:** the vox-set drops and any squad member can pick it up.
- **Bot behaviour:** stays within 10 m of the squad leader. Requests supply when half the squad is Low on ammo.

#### Squad Special Weapons (6)
- Two per squad, from **Grenade Launcher, Bolter, Plasma Gun, Melta Gun, Flamer** (7.2). A squad can't take two meltas or two plasma guns.
- Follow the personal tiers but keep their special weapon.
- **Bot behaviour:** Alpha's specialist defaults to an anti-armour weapon (melta or plasma); Bravo's to an anti-infantry weapon (flamer or grenade launcher). Flamer bots clear buildings and trenches on the squad's path.

#### Riflemen (18)
- **Purpose:** the bulk of the platoon. They take and hold ground, carry supplies and escort HWTs.
- **Kit:** depends on tier (Section 8): cultist autogun → Moebian lasgun, growing grenade and gear slots.
- **Gear slot roles:** gear slots let riflemen specialise without new classes. For example, an entrenching tool for a "digger", demolition charges for a "sapper", extra ammo pouches that resupply squadmates for a "runner".
- **Ogryn:** riflemen are the only role that can spawn as an Ogryn, by spending Favour (8.8).
- **Bot behaviour:** fire and move with their fire team. Idle bots near a depot with open supply requests pick up crates and deliver them.

### 4.4 Role Slots and Bots
- **Bots fill every empty slot** (all 45, including the commander). A match can be played with any number of humans from 1 to 45.
- **Joining:** players pick a slot in the lobby or when joining a match in progress. They can pick any slot a bot holds.
- **Swapping mid-match:** a dead player can swap into **any bot-held slot** from the respawn screen. The bot takes over the player's old slot. Slots held by humans can't be taken.
- **What carries over when swapping:** personal Favour and tier go with the player. Squad Favour stays with the squad.
- **Leadership slots:** a human taking the commander or squad leader slot from a bot is allowed at any time while dead. A human commander can be **vote-kicked back to a bot** (majority of humans in the match) to stop griefing.
- **Commanding bots:** bots obey commander and squad leader orders like humans do. The commander also has a bot-only order: **Supply Detail**, which assigns up to 3 bot riflemen from a squad to run supplies between a depot and a position (11.2).

## 5. Core Gameplay Loop

### 5.1 Moment to Moment (seconds)
Move under cover, suppress, flank, throw grenades, revive. HWT crews brace, fire and reload, and loaders pass ammo.

### 5.2 Engagement (minutes)
1. The commander sets an objective.
2. Squads move up and HWTs reposition to overwatch.
3. Contact: suppression, fire and manoeuvre.
4. Squad leaders spend Favour on call-ins to break the enemy line.
5. The objective is secured. A forward depot or rally point is set up.
6. Logistics teams bring supplies forward. Positions are re-armed.

### 5.3 Operation (45–60 minutes)
Several phases across a large map (Section 15). The AI Director counter-attacks, cuts supply lines and adds new threats. The platoon has to adapt, holding gains while pushing forward.

### 5.4 Progression Arc (one match)
```
Cultist → Moebian Trooper → Moebian Veteran (carapace) → Blessed (mutation) → spend Favour on an Ogryn life
Squad Favour → Plague Zombies → Plague Hounds → Chaos Spawn → Leman Russ
```

## 6. Combat Systems

### 6.1 Feel and Camera
- **Mid-sim.** Between Battlefield and Squad/Hell Let Loose: a few hits kill, suppression really matters and positioning beats reflexes, but movement stays fluid and the game is readable.
- **First-person** on foot. Vehicle seats use their own view: driver's vision slit, gunner's sight, sponson periscopes, the tank commander's open hatch.
- **Movement:** walk, sprint (stamina), crouch, prone, lean, vault and mantle. Stamina only limits sprinting and melee charges, not walking or aiming.
- **No static crosshair.** Hip fire is shown by the weapon's position on screen. Aiming down sights is needed for accuracy beyond ~20 m. Heavy weapons show a sight only while braced (6.3).
- **Weight:** what you carry affects speed and sprint (crates, heavy weapons, Appendix D).

### 6.2 Health and Lethality
- **Base health:** 100 for every human-sized soldier. Armour (6.6) reduces damage taken.
- **Hit locations:**

| Location | Damage multiplier | Effect |
|---|---|---|
| Head | ×3 (×2 with helmet) | — |
| Torso | ×1 | — |
| Arms | ×0.6 | More weapon sway until treated |
| Legs | ×0.6 | Can't sprint until treated |

- **Target time-to-kill** (torso hits, to tune in playtests):

| Weapon | vs Cultist (no armour) | vs Moebian (flak) | vs Veteran (carapace) |
|---|---|---|---|
| Autogun / lasgun | 2 | 3 | 4–5 |
| Laspistol / stub revolver | 3 | 4 | 6 |
| Bolter / bolt pistol | 1 | 1–2 | 2 |
| Heavy stubber | 2 | 2–3 | 3–4 |
| Heavy bolter | 1 | 1 | 1–2 |

- **Regeneration:** none. Health is restored by the medic, the Standard Bearer's planted icon (slow) and depot Medical stations.
- Limb effects are cleared by a squadmate's **field dressing** (3 s, unlimited) or by the medic.

### 6.3 Bracing (Heavy Weapons)
**All heavy weapons must be braced to fire.** This is the defining rule of the Heavy Weapons Section.

| Brace type | Valid for | Setup time | Arc | Notes |
|---|---|---|---|---|
| **Tripod/Mount deploy** | All heavy weapons | 3–5 s (weapon dependent) | 60° | Most stable. The loader can speed up setup by 40%. |
| **Terrain brace** | All heavy weapons | 1.5 s | 30° | Needs a valid ledge, sandbag, wall or window. Shown by a context prompt. |
| **Prone/bipod** | Heavy Stubber, Heavy Bolter, Autocannon | 2 s | 25° | Heavy Bolter and Autocannon get extra recoil when bipodded. |
| **Loader's shoulder** | **Heavy Stubber only** | 1 s | 45° | The loader stands still and becomes the mount. Both players are locked in place, and the loader can turn to traverse. If the loader is hit or moves, the brace breaks. Allows high-angle fire over cover. |

- **Unbraced:** heavy weapons cannot fire. The gunner can only carry them at a slowed pace.
- The Missile Launcher has a **backblast cone** (8 m) that deals full damage and throws up dust that gives away the position. The Lascannon has no backblast, but its muzzle flash reveals it.
- **Displacement:** packing up takes time, which rewards teams that pick good positions and punishes being out-flanked.

### 6.4 Downed, Wounded and Dead
- At 0 HP you go **Downed**: bleed-out timer of 45 s. You can crawl slowly, call for a medic (a marker for the platoon) and choose to **give up** (respawn early).
- Downed players can't shoot.
- **Squadmate stabilise** (6 s): the player gets up with 50 HP and **Wounded** status (max HP 70, more sway) until treated by the medic or at a depot Medical station.
- **Medic Full Revive** (3 s): full HP, no Wounded status.
- **Instant death** (skips Downed): headshots from bolt or heavier weapons, explosive overkill (more than 150 damage in one hit), melta, lascannon, being crushed by a vehicle, executions by enemy elites.
- **Dead:** go to the respawn screen (Section 13). The medic's Blessed Stitching can still bring you back within 10 s unless it was explosive overkill.

### 6.5 Friendly Fire
**Full friendly fire.** Everything that can hurt an enemy hurts a friend for the same damage: bullets, las, explosives, fire, backblast, toxin and vehicles. Fire discipline is part of the game.

Because it's full damage, the game has to make friend and foe easy to tell apart:
- **Readability:** strong visual contrast between Moebians and loyalists (3.4). Friendly nameplates appear when aiming at a friendly within 50 m (no nameplate on enemies).
- **Call-in warnings:** call-in placement shows its area of effect, and friendlies inside it get an audio and HUD warning.
- **Backblast warning:** a cone is shown to anyone standing behind a braced missile launcher.
- **Bots** won't fire through friendlies in their line of fire and announce grenades ("Frag out!").
- **Teamkill penalties (humans):** a teamkill costs the killer 3 personal Favour. Three teamkills in 10 minutes starts an automatic vote-kick for the human players. Accidental damage from call-in units (Chaos Spawn, toxin clouds) is not counted against the player.
- **Allied Chaos units** (zombies, hounds, spawn) also take full damage from the platoon. They are expendable, but wasting them wastes Favour.

### 6.6 Armour and Penetration
Each weapon has a **penetration (Pen)** value from 1 to 6. Each target has an **armour** value on the same scale. Damage depends on the gap:

| Pen compared with armour | Damage multiplier |
|---|---|
| Pen ≥ armour | ×1.0 |
| Pen = armour − 1 | ×0.6 |
| Pen = armour − 2 | ×0.3 |
| Pen ≤ armour − 3 | ×0 (no effect) |

| Armour | Value | Examples |
|---|---|---|
| None / rags | 0 | Cultists, PDF conscripts, zombies |
| Flak | 1 | Moebian troopers, Guardsmen |
| Carapace | 2 | Veterans, Commissars, Moebian veterans, Ogryn |
| Power armour | 3 | Sisters of Battle, the Canoness |
| Light vehicle | 4 | Sentinels, Chimera side/rear |
| Medium vehicle | 5 | Chimera front, Leman Russ side/rear |
| Heavy vehicle | 6 | Leman Russ front |

| Weapon | Pen |
|---|---|
| Autogun, stub rifle, laspistol, heavy stubber, ripper gun | 1 |
| Lasgun, flamer | 2 (flamer ignores cover) |
| Bolter, bolt pistol, heavy bolter, frag missile | 3 |
| Autocannon, plasma (normal shot), krak grenade | 4 |
| Plasma (overcharged), krak missile | 5 |
| Lascannon, melta, battle cannon (AP) | 6 |

- **Vehicles** also have **facings** (front, side, rear, top) and **components**: tracks (immobilise), turret ring (jam traverse), engine (slow or fire), weapons (disable) and crew (an open-hatch commander can be shot).
- Infantry armour also reduces suppression taken (carapace −20%, power armour −50%).

### 6.7 Suppression and Morale
- **Suppression** builds from near misses, nearby impacts and explosions (0–100 meter):

| Level | Effect |
|---|---|
| 0–30 | None |
| 30–60 | Screen edge blur, slightly more sway |
| 60–90 | Heavy sway, slower aiming down sights, muffled audio |
| 90–100 | **Pinned:** can't aim down sights, sprint is limited, strong blur |

- Suppression decays after 3 s without new incoming fire. Heavier weapons cause more suppression per round (heavy stubber highest per second, battle cannon highest per hit).
- **Morale modifiers** change how fast suppression builds:
  - Standard Bearer aura, Commander's Presence, nearby squad leader, allied Chaos units nearby: **slower**.
  - Squadmates downed or killed nearby, under artillery fire: **faster**.
- **AI uses the same model.** Enemy squads that hit "broken" (pinned and losing members) fall back. Commissars and Priests stop that (and Commissars shoot fleeing troops), so killing them collapses a defence.

### 6.8 Melee
**Simple and lethal.** No combos, blocks or parries.

| Action | How | Notes |
|---|---|---|
| **Quick strike** | One button | Fast single attack with bayonet, knife or melee weapon. |
| **Charge** | Sprint + melee | Lunge into the target. Costs stamina. Bayonet charges knock down if they don't kill. |
| **Ogryn bash** | Melee | Wide arc, knockdown on everything hit. |

| Weapon | Hits to kill: no armour | flak | carapace | power armour |
|---|---|---|---|---|
| Knife, bayonet, rifle butt | 1 | 2 | 3 | no effect |
| Chainsword | 1 | 1 | 2 | 4 |
| Power sword | 1 | 1 | 1 | 2 |
| Ogryn bash | 1 | 1 | 1 | 3 |

- Melee from behind or against a Downed enemy is an instant kill (except power armour).
- Sisters of Battle and the Canoness are dangerous in melee and can **execute** players.

### 6.9 Hit and Kill Feedback
- **No hitmarkers.** Hits are shown through the world: impact sounds, armour sparks, the enemy flinching, staggering or falling.
- **Kill confirmation** comes from a quiet **fly-buzz audio cue** and a small Favour tick on the HUD (Section 17). This keeps the screen clean but still rewards kills, which drive progression.

### 6.10 Environmental Hazards
- **Fire:** flamers, promethium tanks and burning buildings. Fire spreads on flammable surfaces and blocks movement.
- **Toxin clouds:** from toxin grenades and plague effects. Moebians with rebreathers are resistant (Section 7.4).
- **Smoke:** blocks sight for players and AI. Plague hounds can still track through it.
- **Darkness:** underhive and night maps. Lumen lamps on weapons give away your position.
- **Explosive objects:** promethium tanks, ammo crates and fuel barrels detonate when hit by explosives or Pen 4+ weapons.

## 7. Weapons and Equipment

### 7.1 Ammunition Model
- **Small arms and special weapons use pooled ammo.** Each weapon has a magazine and a **reserve** of rounds. Reloading tops the magazine up from the reserve, and no rounds are lost by reloading early.
- The HUD shows the magazine as a bar and the reserve as a number (Section 17).
- **Heavy weapons use discrete reloads** (belts, boxes, missiles, power packs). The loader carries them as a count, since they are physical objects that are handed over and carried in crates.
- **Refilling:** Small Arms, Special Munitions and Heavy Munitions crates (12.1), depots, squad leader ammo caches and riflemen with a Runner's Pouch (7.6).
- **Lasgun power packs** can only be recharged at depots. In the field, lasgun ammo comes from crates like everything else.

### 7.2 Small Arms

| Weapon | Used by | Pen | Magazine | Fire modes | Effective range | Notes |
|---|---|---|---|---|---|---|
| **Autogun** | Cultists | 1 | 30 | Auto | 80 m | High rate of fire, poor accuracy, low damage per round. |
| **Stub rifle** | Cultists | 1 | 6 | Lever-action | 150 m | High damage per shot (cultist alternative to the autogun). |
| **Lasgun** | Moebian tiers and most roles | 2 | 40 | Semi / 3-round burst | 150 m | Accurate and reliable. Bayonet fitted. |
| **Laspistol** | Sidearm | 1 | 20 | Semi | 40 m | Default sidearm. |
| **Stub revolver** | Sidearm (cultists, HWT gunners option) | 1 | 6 | Semi | 40 m | Hits harder, slow reload. |
| **Bolt pistol** | Commander, Blessed tier sidearm | 3 | 8 | Semi | 40 m | Strong recoil. |
| **Ripper gun** | Ogryn | 1 | 12 | Auto (pellet bursts) | 20 m | Devastating up close, also a melee bash (6.8). |

### 7.3 Heavy Weapons

| Weapon | Pen | Rounds per reload | Reloads carried by loader | Setup / pack-up | Brace types | Notes |
|---|---|---|---|---|---|---|
| **Heavy Stubber** | 1 | 100 (belt) | 6 | 3 s / 2 s | All, **including loader's shoulder** | Highest suppression per second. Weakest per round. |
| **Heavy Bolter** | 3 | 40 (box) | 4 | 4 s / 3 s | Tripod, terrain, prone | Explosive rounds with a small blast (1 m). Great against infantry in cover and light vehicles. |
| **Autocannon** | 4 | 10 (clip) | 5 | 4 s / 3 s | Tripod, terrain, prone | Two-round bursts, long range, punches through light cover. Kills Sentinels and Chimera sides. |
| **Missile Launcher** | 3 (Frag) / 5 (Krak) | 1 missile | 6 (mix chosen at the depot, default 4 Krak + 2 Frag) | 5 s / 3 s | Tripod, terrain | Switch missile type between shots. **Backblast:** 8 m cone behind the launcher deals full damage. |
| **Lascannon** | 6 | 5 shots (power pack) | 3 | 5 s / 4 s | Tripod, terrain | 1.5 s charge before each shot. Kills Leman Russ from the side or rear. **No backblast**, but the muzzle flash shows its position to every enemy in sight. |

- Setup and pack-up times are without a loader. A loader makes setup 40% faster (4.3).
- A **dropped** heavy weapon used by someone who isn't the gunner or loader has +50% setup and reload time (4.3).

### 7.4 Special Weapons

| Weapon | Pen | Magazine | Starting reserve | Effective range | Notes |
|---|---|---|---|---|---|
| **Grenade Launcher** | 3 (Frag) / 4 (Krak) | 6 | 18 | 150 m (arc) | Fires Frag, Krak, **Smoke** or **Toxin** (if unlocked). Its rounds come from its own reserve, not the hand grenade slots. |
| **Bolter** | 3 | 20 | 80 | 100 m | Heavy recoil, high damage. One-hit kill on cultists and most Guardsmen to the torso. |
| **Plasma Gun** | 4 (normal) / 5 (overcharged) | — (heat, see below) | 6 flasks (each 10 shots) | 100 m | Heat system with a real risk of death. |
| **Melta Gun** | 6 | 2 shots (canister) | 4 canisters | 15 m | Short range, destroys vehicles in 1–3 shots and kills anything human-sized. |
| **Flamer** | 2 (ignores cover) | 10 s of fire (tank) | 2 tanks | 12 m | Sets targets and terrain alight, panics AI. Fuel tank can explode (below). |

#### Plasma Gun Heat
- **Normal shot:** +10 heat. **Overcharged shot** (hold fire 1 s): +30 heat, Pen 5, bigger damage and blast.
- Heat decays at 15 per second after 1 s without firing.
- **70+ heat:** the gun glows and hisses (warning visible to nearby players).
- **100 heat — Overheat:** the gun vents into the user's hands. The user takes 40 damage and can't fire for 5 s.
- **Overcharging at 90+ heat:** 1 in 3 chance of a **catastrophic failure**. The user dies instantly (no Downed state, no Blessed Stitching) and the gun explodes in a 3 m radius, which hurts friendlies.
- **Manual vent** (3 s): resets heat to 0 and costs 10 health.
- **Bots** never overcharge above 60 heat.

#### Flamer Fuel Tank
- The fuel tank is on the user's back. A hit on it from a Pen 3+ weapon or an explosion has a 25% chance to make it **explode** (4 m radius, sets the area on fire). The hit point is visible on the character model, so enemy AI and careless friendlies can target it.

### 7.5 Grenades

| Grenade | Who | Effect |
|---|---|---|
| **Frag** | Everyone | 4 s fuse, can be cooked. Kills unarmoured targets within 5 m, wounds up to 10 m. Pen 3. |
| **Krak** | Moebian Trooper and above, Command Section, HWTs | Small blast (1 m), Pen 5. Can be **thrown** or **planted** (2 s) on vehicles, doors and fortifications. |
| **Smoke** | Squad leaders (2), Grenade Launcher | Blocks sight for 45 s. Plague hounds can track through it. |
| **Toxin** | Blessed tier, once unlocked through meta-progression (Section 19) | Cloud of 6 m radius for **7 s** (rule of seven). Damage over time, blurred vision, suppression. |

- **Toxin resistance:** Moebians wear rebreathers and take **30%** toxin damage. Blessed take **none**. Cultists and Ogryn take **full** damage, so toxins thrown near them hurt friendlies (with full friendly fire, 6.5).

### 7.6 Gear Items
Gear slots (Section 8) take items chosen at spawn. Some items take one slot each.

| Item | Effect |
|---|---|
| **Ammo Pouch** | +50% reserve for your primary weapon. |
| **Runner's Pouch** | Hand 3 refills (one magazine's worth each) to squadmates. |
| **Heavy Weapon Reload** | Carry **1 reload** of a chosen heavy weapon type and hand it to any loader or gunner. Lets any soldier help feed a position. |
| **Entrenching Tool** | Build a sandbag brace point (8 s, max 3 per life). Loaders have this for free. |
| **Demolition Charge** | One large charge: destroys fortifications and wire, wrecks vehicle components. 7 s fuse. |
| **Auspex** | Short-range scan showing enemies through walls within 20 m for 5 s. 45 s cooldown. |
| **Rebreather Filter** | Cultists only: gives Moebian-level toxin resistance (30% damage). |
| **Medi-pack** | Self-stabilise once while Downed. |
| **Lumen Lamp** | Weapon light for dark maps. Gives your position away when on. |

- Riflemen use gear slots to specialise (digger, sapper, runner, ammo carrier) without needing extra classes (4.3).

### 7.7 Weapon Patterns
Weapons don't have attachments. Instead each weapon family has **2–3 patterns**: sidegrades that trade rate of fire, damage, handling and range but never Pen. Patterns are unlocked through meta-progression (Section 19) and picked at spawn.

| Weapon | Patterns (examples) |
|---|---|
| Lasgun | **Kantrael** (balanced, default) · **Lucius** (hotter shots, slower fire, longer range) · **Accatran** (short carbine, faster handling, shorter range) |
| Autogun | **Militia** (default) · **Hive-forged** (faster fire, more recoil) · **Braced** (semi-auto, more accurate) |
| Heavy Bolter | **Standard** (default) · **Mars-pattern** (slower fire, bigger blast) |
| Autocannon | **Standard** (default) · **Ryza-pattern** (single-shot, faster reload) |
| Flamer | **Standard** (default) · **Heavy-nozzle** (shorter range, bigger fire spread) |

Each operation's balance is tested with default patterns. Any pattern has to be a sidegrade, never a straight upgrade.

## 8. Progression: Marks of Favour

Progression in a match is driven mainly by **kill credit**, with smaller amounts from contribution so support roles are not starved. Everything resets at the end of the operation (3.5).

### 8.1 Favour Sources

| Source | Favour |
|---|---|
| Kill (infantry) | 1 |
| Kill (elite: Commissar, Veteran, Priest, Sister) | 3 |
| Kill (Canoness, Penitent Engine) | 8 |
| Vehicle kill (shared among damage dealers) | 5–15 |
| Assist (damage or suppression on a target that dies within 10 s) | 0.5 |
| Crew-served weapon kill | Full credit to **both** gunner and loader |
| Delivering a supply crate to a requesting position | 1 |
| Handing a heavy weapon reload to a loader or gunner | 0.5 |
| Revive | 0.5 |
| Completing a commander order (objective secured while ordered) | 3 to each squad member present |
| Teamkill | −3 |

Kills stay the main source. A strong rifleman progresses faster than a pure supply runner, but nobody gets stuck. Bots earn Favour by the same rules.

### 8.2 Pacing Targets
Operations last 45–60 minutes (15.1), so progression is tuned to fit. An **average rifleman reaches carapace in about 15 minutes**. The target earning rate is about **1.3 Favour per minute** of active fighting for an average player.

| Tier | Threshold | Average player | Strong player |
|---|---|---|---|
| Moebian Trooper | 8 | ~6 min | ~3 min |
| Moebian Veteran (carapace) | 20 | **~15 min** | ~8 min |
| Blessed | 40 | ~32 min | ~18 min |
| Ogryn (spend 30, needs Blessed) | — | Final phase, if at all | Mid match |

The AI Director (14.3) keeps the pace from stalling: quiet phases still give enough targets to progress.

### 8.3 Personal Tiers (Riflemen, Squad Leaders, Squad Vox, Squad Special Weapons)
Your **tier is set by your current Favour total**.

| Tier | Name | Favour | Armour | Grenade slots | Gear slots | Other |
|---|---|---|---|---|---|---|
| 0 | **Cultist** | 0 | Rags/none | 1 (Frag) | 1 | Autogun or stub rifle. Sprint 10% faster. No rebreather. |
| 1 | **Moebian Trooper** | 8 | Flak | 2 (Frag/Krak) | 2 | Lasgun, rebreather (toxin resistance). |
| 2 | **Moebian Veteran** | 20 | **Carapace** | 3 | 3 | Bayonet charge knocks down; brace and stabilise 20% faster. |
| 3 | **Blessed** | 40 | Carapace, **Rot-hardened** (−10% damage taken) | 4 (Toxin, if unlocked) | 3 | **One mutation** (8.6). Toxin immune. Small morale aura (5 m). |

- Squad leaders start at tier 1 (they are never cultists).
- Squad special weapons and squad vox-ops follow the tiers but keep their role weapon or vox-set.
- **Tier changes apply at your next respawn or at a depot**, where you get your new kit. Reaching a tier mid-fight gives a short audio and visual cue (flies swarm briefly) and the new kit is waiting for you.

### 8.4 Death Cost
- On death you lose **25% of your Favour above your current tier's threshold**. You never drop a tier from dying.
- Example: a Moebian Veteran (threshold 20) with 32 Favour dies. They lose 25% of 12 = 3 and respawn with 29.
- Blessed Stitching (4.3) avoids the death and its cost.

### 8.5 Role Tracks
Roles that don't change kit through the tiers use a **track** with the same thresholds. Everyone gets a mutation at 40.

| Role | 8 Favour | 20 Favour | 40 Favour |
|---|---|---|---|
| **Commander** | Command Auspex cooldown 60 → 40 s | Commander's Presence radius 30 → 45 m | Blessed: mutation, Rot-hardened |
| **Medic** | +2 satchel charges | Full Revive 3 → 2 s | Blessed + Blessed Stitching window 10 → 20 s |
| **Vox-Operator** | Intercept cooldown −30% | Platoon Link range 30 → 50 m | Blessed + 1 extra supply drop per phase |
| **Standard Bearer** | Plant icon 5 → 3 s | Planted aura 25 → 35 m | Blessed + Rally spawn wave 20 → 15 s |
| **Veteran Special Weapons** | +1 ammo slot | Reload 20% faster | Blessed: mutation, Rot-hardened |
| **HWT Gunner and Loader** | Loader carries +1 reload | **Carapace** for both, setup 20% faster | Blessed: mutation, Rot-hardened |

### 8.6 Mutations (Blessed)
On reaching Blessed you're offered **3 random mutations from the pool of 7** and keep **one** for the rest of the match. Mutations are themed on Nurgle's endurance and decay (3.2), and each has a drawback or a cost.

| Mutation | Effect | Drawback |
|---|---|---|
| **Bloated Hide** | +20% damage resistance | −10% move speed |
| **Cloud of Flies** | Enemies within 5 m get heavy sway and −30% accuracy | Your position is audible to everyone nearby |
| **Rotting Regeneration** | Regenerate 1 HP/s after 10 s out of combat, up to 70 HP (the only natural regeneration in the game) | Can't be treated by the medic's Treat Wound |
| **Bile Spew** | Short-range acid vomit: 4 m cone, Pen 2, 45 s cooldown | Leaves you unable to aim for 1 s |
| **Pox Carrier** | Enemies you kill in melee rise as allied plague zombies for 60 s | Zombie kills give half Squad Favour and no personal Favour (9.7) |
| **Unfeeling Flesh** | Immune to limb effects and Wounded status | Can't be stabilised by squadmates, only the medic |
| **Grandfather's Gift** | Downed timer 45 → 90 s, crawl twice as fast, can fire a pistol while Downed | When you die you burst into a toxin cloud (hurts cultists and Ogryn nearby) |

- Mutations are visible on the model (swollen hide, flies, open sores) so squadmates can read them.
- Mutations stay through deaths for the match. Dropping below Blessed (by spending Favour on the Ogryn) removes the mutation; reaching Blessed again gives a new pick.

### 8.7 Visual Feedback
Each tier changes the model clearly: rags → flak and gas mask → carapace → carapace with rust, boils, flies and the chosen mutation. Other players should be able to read rank at 50 m. Nameplates on friendlies also show a tier mark.

### 8.8 The Ogryn
The Ogryn is bought with personal Favour. It's a choice to spend progress on a powerful but temporary life.

- **Requirement:** Blessed tier (40 Favour) and a rifleman slot.
- **Cost:** **30 personal Favour**, spent when you choose Ogryn on the respawn screen. The respawn also costs **3 reinforcement tickets** (13.1).
- **Limit:** one Ogryn per squad at a time, three platoon-wide.
- **During the Ogryn life:** kills earn Favour normally. When the Ogryn dies, the player respawns as a rifleman at whatever tier their Favour now gives (for example, 45 − 30 = 15 → Moebian Trooper). A good Ogryn can earn its way back to Blessed.
- **The death cost (8.4) does not apply** to an Ogryn's death, since the Favour was already spent.
- **Stats:**

| Stat | Value |
|---|---|
| Health | 300 |
| Armour | Carapace (2) |
| Move speed | 90%, sprint knocks down infantry |
| Weapon | Ripper gun (7.2), Ogryn bash (6.8), 2 frag bombs |
| Toxin | **Full damage** (no rebreather fits) |
| Restrictions | Can't go prone, can't use heavy weapons, can't board the Leman Russ, too large for some tunnels and doors |

- **Logistics synergy:** an Ogryn can **carry a two-man crate alone** at full speed, or **two one-man crates at once** at 90% speed. This is a real reason to bring one besides combat power.
- **Weakness:** big hitbox and a priority target for enemy AI.
- **Bot behaviour:** bots buy an Ogryn only when their squad has none and they are at 70+ Favour (so they stay Blessed or Veteran after spending).

## 9. Call-Ins

There are two levels of call-in: **squad call-ins** bought by squad leaders with **Squad Favour**, and **platoon call-ins** bought by the commander with **Platoon Favour**.

### 9.1 Squad Favour
- Every point of Favour a squad member earns (8.1) **also** adds the same amount to the squad's **Squad Favour** pool. Spending Squad Favour never touches anyone's personal tier.
- A squad of 10 earns roughly **10–13 Squad Favour per minute** in active fighting, so a squad that saves can afford a Leman Russ in about 15–20 minutes.
- Calling in needs:
  1. The squad leader alive and not Downed.
  2. The **squad vox-operator within 25 m** (or the leader carrying the vox-set).
  3. A valid deployment point: in the leader's line of sight or marked on the map within 150 m.
- Call-in costs are set so the squad leader has to choose between **spending now** (zombies, hounds) and **saving** (Chaos Spawn, Leman Russ).

### 9.2 Squad Call-In List

| Call-in | Cost | Cooldown (per squad) | Arrives | Lasts |
|---|---|---|---|---|
| **Plague Zombie Horde** | 25 | 3 min | 5 s, from the ground behind the squad | Until killed, or 4 min (they rot away) |
| **Plague Hounds** | 40 | 4 min | 3 s, from the squad leader's position | Until killed, or 3 min |
| **Chaos Spawn** | 80 | 6 min | 5 s, through a warp rift at the marked point | 90 s, then it dissolves |
| **Leman Russ** | 200 + commander approval | One active per platoon | ~45 s, at a depot | Until destroyed (Section 10) |

### 9.3 Commanding Zombies and Hounds
After arrival, the squad leader can give **simple orders** by pinging (no vox needed for orders, only for the call-in itself):

| Order | Zombies | Hounds |
|---|---|---|
| **Advance** (paint a path) | Shamble along the path, attacking anything they meet | Run along the path, attacking anything they meet |
| **Hunt** (mark a target or area) | Swarm toward it | Hunt it down. Default priorities: isolated enemies, HWTs, snipers, fleeing units |
| **Hold** (mark an area) | Mill about the area and attack anything that enters | Guard the area |
| **Return** | Fall back to the squad | Follow the squad leader and guard them |

Bot squad leaders use the same orders.

### 9.4 Plague Zombie Horde
- **14 zombies** (rule of seven). Slow (60% speed), 40 HP, no armour, melee only.
- **Not affected by suppression.** They walk into fire, so the enemy has to spend ammo and attention on them.
- **Fear:** loyalist AI within 15 m of the horde takes extra suppression. Flamers and Priests are the enemy's counters.
- **Contagion (capped):** an enemy killed by a zombie has a 50% chance to rise as a new zombie in the horde after 7 s, up to a **cap of 21** per horde. The Pox Carrier mutation (8.6) adds zombies the same way.
- **Uses:** soaking fire before an assault, revealing enemy positions, screening a crossing, filling a trench before the squad goes in.

### 9.5 Plague Hounds
- **4 hounds.** Fast (150% speed), 120 HP, flak-level armour (1). Pounce attack knocks infantry down.
- **Tracking:** they track through smoke and darkness, and **spot** every enemy they see for the squad (10 s).
- **Uses:** clearing HWT nests and snipers, chasing down routed squads, guarding a flank or the squad leader.

### 9.6 Chaos Spawn
- One heavily mutated monster: 1,500 HP, power-armour level (3), melee attacks that kill infantry and can flip light vehicles (Sentinels).
- The squad leader marks a point. A 10 m warning circle appears for 5 s (friendlies get a HUD and audio warning), then the Spawn arrives.
- **Uncontrollable:** after it arrives it charges the nearest concentration of enemies and **attacks any living thing within 4 m, including friendlies and allied zombies**. If no enemies are within 40 m it wanders towards the nearest.
- **Uses:** breaking fortified points, bunkers and enemy HWT nests. Keep friendly troops out of its way.
- Damage it does to friendlies does **not** count as a teamkill for the squad leader (6.5).

### 9.7 Allied AI Rules
- Allied Chaos units have a **sickly green outline** on the HUD and on nameplates so they aren't confused with enemies.
- They take **full damage** from the platoon (6.5).
- Kills by allied units give **half** Squad Favour and **no** personal Favour, so call-ins can't snowball the economy.
- Allied units draw the AI Director's attention (14.3), pulling enemy focus away from players.

### 9.8 Platoon Favour and Commander Call-Ins
- **Platoon Favour:** **20%** of every point of Favour earned by anyone in the platoon also goes into a platoon pool, plus **+30** for every operation phase objective completed. This adds up to roughly **10–12 per minute**.
- Commander call-ins need the **platoon vox-operator within 30 m** of the commander and are placed from Tactical Command (Section 11).

| Call-in | Cost | Cooldown | Effect |
|---|---|---|---|
| **Carrion Flock** | 30 | 3 min | A swarm of crows circles a 150 m area for 20 s and spots every enemy in it for the platoon. |
| **Supply Drop** | 40 | 4 min | 3 crates of the commander's choice land at a marked open spot after 90 s. The vox-op's free drop per phase (4.3) is separate. |
| **Blight Fog** | 50 | 5 min | A 100 m wide fog bank lasts 60 s. Blocks sight like smoke and does light toxin damage (Moebians resist, cultists and Ogryn don't). |
| **Plague Barrage** | 70 | 6 min | Off-map traitor mortars hit a 30 m radius for 15 s with HE and toxin shells, after a 15 s delay. Full friendly fire, with a warning to anyone inside. |
| **Reinforcement Tithe** | 100 | Once per phase | +15 tickets to the reinforcement pool (13.1). |
| **Approve Leman Russ** | Free (the squad pays) | One tank active | Approves a squad's tank request (Section 10). |

- **Bot commander:** uses Carrion Flock before each assault, Supply Drop when two or more positions report Critical ammo, Plague Barrage on fortified objectives with no friendlies within 40 m, Reinforcement Tithe when the pool falls below 25%.

## 10. The Leman Russ

The Leman Russ is the biggest thing a squad can earn: a mobile fortress that the platoon has to feed, screen and repair.

### 10.1 Configuration
- **Turret:** Battle cannon (gunner)
- **Hull:** Heavy bolter (hull gunner)
- **Sponsons:** 2× heavy bolters (left and right sponson gunners)
- **Pintle:** Heavy stubber, fired by the **Tank Commander standing in the open hatch**
- All tank weapons count as braced (mounted).

### 10.2 Crew (6 seats)

| Seat | Weapon | Ammo carried | Notes |
|---|---|---|---|
| Driver | — | — | Drives. Sees through a narrow vision slit, so relies on the tank commander's callouts. Can crush infantry. |
| Gunner | Battle cannon | 24 shells (default 16 HE + 8 AP, mix set at the depot) | Turret traverse. Switch HE/AP between shots. Reload 5 s. |
| Hull Gunner | Heavy bolter | 6 boxes (40 rounds each) | Fixed forward arc (30°). |
| Left Sponson Gunner | Heavy bolter | 6 boxes | Left arc (120°). |
| Right Sponson Gunner | Heavy bolter | 6 boxes | Right arc (120°). |
| **Tank Commander** | Pintle heavy stubber | 4 belts (100 rounds each) | **Open hatch:** 360° view, marks targets for the crew and gives move orders to a bot driver, but **exposed** to small arms and snipers. Closing the hatch (1 s) gives safety but no stubber and only a periscope view. |

- Crew can switch to an empty seat inside the tank (2 s).
- **Battle cannon:** HE is Pen 3 with a 6 m blast that kills infantry. AP is Pen 6 and is for enemy armour.

### 10.3 Durability
**Strong, but needs anti-tank to kill.** Small arms and most infantry weapons can't hurt it (6.6); real threats are lascannons, melta, krak and enemy tanks. It needs infantry to screen it from enemy anti-tank teams.

| Facing | Armour | What hurts it |
|---|---|---|
| Front | 6 (heavy) | Lascannon, melta, battle cannon AP. Krak at ×0.6. |
| Side | 5 | Above plus krak at full; autocannon at ×0.6. |
| Rear | 4 | Above plus autocannon at full; **engine deck takes ×1.5 damage**. |
| Top | 4 | Plunging fire and planted krak/demolition charges. |

- **Hull:** 3,000 HP. As a guide, about 8 lascannon hits, 5 melta hits or 20 krak grenades on the side.
- **Components** (separate HP, repaired by the enginseer, 10.6):

| Component | When damaged |
|---|---|
| Tracks | Immobilised |
| Turret ring | Turret jams (can't traverse) |
| Engine | Catches fire: 30 HP per second until put out by the crew (5 s from inside) or the enginseer |
| Each weapon mount | That weapon can't fire |
| Vision blocks | Driver or gunner view cracked and blurred |

- **Knocked out:** at 0 HP the tank burns. The crew have **5 s to bail out** before the ammo cooks off (8 m explosion). Bailed-out crew get out at their current tier with their personal kit.
- The tank commander in the open hatch can be shot like any infantry. Snipers will try.

### 10.4 Earning and Calling In
1. The squad builds **200 Squad Favour** (9.2).
2. The squad leader (with the vox-op in range) sends a **Tank Request** to the commander.
3. The commander **approves** in Tactical Command and picks an arrival point: the rear depot's **motor pool**, or a forward depot with a **vehicle bay** (built with one extra Fortification crate, 12.3).
4. The tank and its enginseer arrive after ~45 s, with a rumble and audio cue. Arrival costs **10 reinforcement tickets** (13.1).
5. Only **one Leman Russ** per platoon at a time. After a tank is lost, the platoon can't request another for **5 minutes**.
- The AI Director reacts to the tank arriving by sending anti-tank threats over the next few minutes (lascannon teams, melta veterans, enemy armour; 14.4).

### 10.5 Crewing
Seats fill in this order, so the tank is always fully useful but humans get first pick:
1. **Respawning humans from the calling squad** can choose a tank seat from the respawn screen.
2. **Any respawning human** in the platoon.
3. **Living humans** can walk up and board at any time.
4. **After 30 s**, any seats still empty are filled by **respawning bots** (bot riflemen only, calling squad first). This keeps leaders, vox-ops and HWT gunners in their jobs.
- **Humans replace bots:** a human who boards or picks a seat a bot holds takes it. The bot gets out and goes back to its squad as a rifleman.
- **Role slots:** a player in the tank keeps their role slot. A squad leader or other key role can crew (for example the squad leader in the commander's hatch), but the UI warns their squad that the role is off the line.
- **Bot crew behaviour:**
  - **Driver:** follows the tank commander's move pings. If the tank commander is also a bot, it advances about 30 m behind the calling squad, keeps the front armour toward the biggest threat and stops in hull-down positions.
  - **Gunner:** AP on vehicles, HE on infantry groups and HWT nests. Won't fire HE within 8 m of friendlies.
  - **Heavy bolter and pintle gunners:** engage infantry in their arc, prioritising anti-tank teams.

### 10.6 The Enginseer (AI)
Every Leman Russ arrives with a **traitor Enginseer**, a rust-eaten tech-priest of the Plague God. It is an AI unit only, not a player slot.
- **Stats:** 150 HP, carapace (2), laspistol and a servo-arm for melee.
- **Behaviour:** stays behind the tank, out of the main line of fire, and moves to repair when needed. The tank commander can ping it to "Repair now" or "Hold back".
- **Repairs:**
  - Components (tracks, turret ring, weapons, vision blocks) in 10–20 s each.
  - Engine fires in 5 s.
  - Hull: 20 HP per second while the tank has been stationary for 5 s, **up to 75%** of max hull. Above 75% needs a depot.
- **Vulnerable:** enemy AI target it on purpose. If it dies, a new one arrives with the tank's next depot visit, after a 3-minute delay.
- Players should protect it. A tank with no enginseer has to drive back to a depot for every repair.

### 10.7 Tank Logistics
- **Ammo only** (no fuel).
- **At a depot:** full resupply and full hull repair in 30 s.
- **In the field:** a **Tank Munitions crate** (two-man or Ogryn carry, 12.1) restores 6 shells, 1 box per heavy bolter and 1 stubber belt. Crates are handed over at the tank's rear hatch.
- Losing the tank refunds nothing. It is a big swing in momentum both ways.

## 11. Platoon Commander: Tactical Command

### 11.1 The Data-Slate
- The commander opens **Tactical Command** by raising a **data-slate** (1 s). The map fills about 75% of the screen. The world stays visible around the edges and all game audio keeps playing, so the commander can still notice nearby threats.
- **While the slate is up** the commander can't use a weapon and can only move at a slow crouch-walk (50% speed). They are vulnerable, which is part of why the Command Section veterans stay close.
- **Dropping the slate** to draw a pistol takes 0.5 s.
- Taking a hit makes the slate jolt, flashes the screen edge red and plays an alarm.
- Every other player has a simpler **map screen** (view only, plus pings). Only the commander can give orders from it, and the acting commander when the commander is dead (4.3).

### 11.2 The Map
- **Layers** the commander can toggle: terrain and sectors, objectives, friendly units, supply (depots, the hauler, crates, requests), threats (spotted enemies, last-known positions, intercepted attack directions), call-in areas.
- **Zoom** from the whole operation area down to a single street.
- **Fog of war:** platoon sight only (11.5).

### 11.3 Orders
Orders can target the **platoon**, a **squad**, a **fire team** (Alpha or Bravo), an **HWT**, the **tank** or a **depot**. There is no control of individual bots.

| Order | Target | Effect |
|---|---|---|
| **Move To** | Squad / fire team / HWT / tank | Waypoint on the unit's HUD and compass. |
| **Secure Objective** | Squad | Marks an objective. Completing it while ordered gives the Followed Orders bonus (11.6). |
| **Hold / Dig In** | Squad / fire team / HWT | Defence bonus inside the zone: faster sandbag building, +15% suppression resistance. |
| **Assault** | Squad / fire team | "Fury of the Damned": +15% sprint speed and suppression resistance for 30 s while charging the target area. 3 min cooldown per squad. |
| **Fall Back** | Squad / fire team / HWT | Retreat to a point. Suppression builds 25% slower while moving away. |
| **Overwatch Lane** | HWT / tank | Draws a fire lane. The unit gets +10% accuracy inside it. |
| **Escort / Screen** | Squad or fire team → HWT / tank / supply team | Links units. Shows escort status on the map. |
| **Rally on Icon** | Platoon | Marks the Standard Bearer's planted icon as the regroup point. |
| **Supply Priority** | Depot | Sets which requests the depot fills first (12.7). |
| **Supply Detail** | Bot riflemen of a squad | Assigns up to 3 bot riflemen to run supplies between a depot and a position until cancelled. |
| **Establish Forward Depot** | Location | Needs the platoon vox-op and a secured objective (12.3). |
| **Approve Tank** | Tank Request | Approves or denies Leman Russ requests (10.4). |
| **Platoon Call-In** | Map location | Places a commander call-in bought with Platoon Favour (9.8). |
| **Ping / Mark** | Anywhere | Marks enemy positions, threats or routes for the whole platoon. |

### 11.4 How Orders Flow
- **Delivery:** instant with the platoon vox-op within range of the commander (Platoon Link, 4.3); otherwise through the squad vox-op with a 5 s delay. A squad with no vox-set alive gets **no orders** until someone picks it up.
- **Order states:** Issued → Acknowledged → In Progress → Complete or Cancelled. Human squad leaders acknowledge with one key press; bots acknowledge automatically.
- **Limits:** each squad has one active squad order, plus one fire team order. A new order replaces the old one.
- **Chain of command:**
  - **Bot-led squads** carry out commander orders directly.
  - **Human-led squads:** the order appears as a task for the squad leader. Bots in that squad follow their squad leader's waypoints, not the commander's. A fire team order to Bravo goes straight to Bravo's bots, but the human squad leader can override it.
- **Orders are information plus reward.** Humans are never forced to follow them (11.6).

### 11.5 Information and Fog of War
- **Platoon sight only:** the commander sees what the platoon sees or has recently spotted.
- **Spotting:** an enemy is spotted when a player pings it, when a bot sees it, or by hounds, auspex, the Command Auspex and Carrion Flock.
- **Decay:** spotted infantry stay on the map for 30 s, vehicles for 60 s. After that a greyed-out last-known-position marker stays for another 60 s.
- **Vox Intercept** (platoon vox-op) adds arrows showing the direction of upcoming enemy attacks (14.4).
- **Status panels:**
  - **Squads:** strength (alive / downed / dead), human or bot leader, ammo state (Full / Low / Critical), Squad Favour, call-ins ready, vox-op alive.
  - **HWTs:** weapon type, braced or moving, reloads left.
  - **Tank:** crew, hull %, damaged components, ammo, enginseer alive.
  - **Supply:** requests (type, where, who's carrying, ETA), depot health, hauler status and cargo.
  - **Platoon:** reinforcement pool, Platoon Favour, phase objectives and timer.
- **Alerts:** a notification feed for supply requests, tank requests, Critical ammo, icon under attack, depot under attack and squad wipes. Each alert jumps the map to the location.

### 11.6 Rewards for Following Orders
Reward only, no penalties.
- **Followed Orders:** +3 Favour to each squad member present when an ordered objective is completed (8.1).
- **On Task:** +0.2 Favour per minute to anyone inside the area of an active Hold / Dig In or Overwatch order.
- **Escort bonus:** +1 Favour to each member of an escorting squad when the escorted supply team delivers.

### 11.7 Commander Rewards
The commander earns personal Favour from objectives completed under their orders and a **10% share** of all Favour earned by the platoon, so they aren't pushed to leave command to farm kills.

### 11.8 Commander Advisor (Optional)
For new commanders, an optional **advisor** uses the bot commander's logic (4.3) to suggest orders ("2nd Squad is idle", "HWT 3 has 1 reload left", "Enemy armour spotted east: move a lascannon team"). Suggestions show in the alert feed and can be accepted with one click.

## 12. Logistics and Resupply

Logistics is a main pillar, not a side activity. Depots never run dry, so the challenge is **the last stretch**: getting supplies from a depot to the positions that need them, under fire, and keeping the depots themselves alive.

### 12.1 Supply Crates

| Crate | Carriers | Contents (one crate) |
|---|---|---|
| **Small Arms Ammo** | 1 | Refills the reserves of 6 soldiers (rifles and sidearms) |
| **Grenade Crate** | 1 | 10 grenades (Frag/Krak; Toxin if unlocked), or 2 full Grenade Launcher reserves |
| **Special Munitions** | 1 | Refills 3 special weapons (bolter mags, plasma flasks, melta canisters, promethium tanks) |
| **Heavy Munitions (typed)** | 2 (1 Ogryn) | One full loader load for **one** heavy weapon type (7.3), e.g. 6 stubber belts or 3 lascannon packs |
| **Medical** | 1 | 10 Medicae charges, or treats up to 10 Wounded players at a Casualty Collection Point |
| **Fortification** | 2 (1 Ogryn) | Builds a forward depot, a vehicle bay, or 6 sandbag brace points plus wire |
| **Tank Munitions** | 2 (1 Ogryn) | 6 shells, 1 box per heavy bolter and 1 stubber belt (10.7) |

- **Carrying slows you** (Appendix D). One-man crates leave you a sidearm; two-man crates leave you nothing.
- Crates are **physical objects**. They can be dropped, handed over and picked up by others.
- **Destroying crates:** explosives destroy crates. Heavy Munitions and Tank Munitions crates **explode** (5 m) when destroyed.
- **Capturing crates:** a crate left on the ground with no friendly within 20 m, in an area enemies control, is **captured** after 60 s: enemy AI carry it away and it's lost. Killing the carrier before they reach their lines drops it again.
- HWT loaders start with a full load (7.3). After that, positions have to be fed by crate runs, gear-slot reloads (7.6) and the hauler.

### 12.2 Depots
- **All depots have unlimited supplies.** Anyone can take any crate from a depot's crate rack.
- **Rear Depot (Main Base):** spawn point, crate rack, Medical station, weapon rack (heavy weapon swaps, new tier kit), **motor pool** (Leman Russ and the hauler). Can't be destroyed or captured.
- **Forward Depot:** spawn point, crate rack, Medical station, weapon rack. A **vehicle bay** can be added with one more Fortification crate (tank arrival, tank resupply and repair).
- **Ammo Caches (light):** a squad leader can drop one small cache per life holding one Small Arms crate's worth. Caches are not depots and can run out.

### 12.3 Establishing a Forward Depot
1. The objective is secured.
2. The commander places the depot in Tactical Command (needs the platoon vox-op within 30 m of the commander).
3. A **Fortification crate** has to be delivered to the site. Building takes 20 s.
4. The depot comes online. It has **1,500 HP** and can be repaired with another Fortification crate.
5. Maximum of **2 forward depots** at once, so the commander has to choose where the line is. The commander can dismantle a depot to place a new one.

### 12.4 Losing a Forward Depot
- **Destroyed:** enemies with explosives (and enemy artillery) can bring it to 0 HP. It's gone and has to be rebuilt.
- **Captured:** if enemies hold the depot area (15 m) with **no platoon members inside for 30 s**, it's captured. A captured depot:
  - stops working for the platoon (no spawns, no crates)
  - becomes an **enemy spawn and resupply point** until retaken
  - is **retaken** by clearing the area and holding it for 30 s, which brings it back intact.
- The Standard Bearer's icon planted near a depot is the usual way to make sure it's never left empty.

### 12.5 The Hauler
The platoon has **one hauler**: an unarmed Trojan support tractor with a cargo trailer.

| Stat | Value |
|---|---|
| Seats | Driver + 1 passenger |
| Cargo | 8 crate units (one-man crate = 1, two-man crate = 2) |
| Speed | Fast on roads, slow off-road, can't enter tight urban streets or tunnels |
| Armour / HP | Light vehicle (4), 1,200 HP |
| Weapons | None |
| Respawn | At the rear depot motor pool, 4 minutes after it's destroyed |

- **Loading:** at any depot, choose a crate mix and the hauler is loaded in 15 s.
- **Unloading:** players take crates off the trailer anywhere. Or the driver can **deploy** the hauler (5 s, parked) as a **mobile cache**: nearby players draw ammo from its cargo directly, like a small depot, until the cargo runs out.
- **Capture:** an empty hauler left in an enemy-controlled area has its cargo captured after 60 s.
- **Anyone can drive.** A **Supply Detail** order (11.3) can assign a bot driver.
- **Uses:** building depots far forward, hauling Fortification and Tank Munitions crates, running a mobile cache behind an HWT line. Infantry still carry the last stretch where the hauler can't go.

### 12.6 Scavenging
- Players can **loot loyalist bodies** for small arms ammo and grenades (hold interact, 1.5 s). Each body gives up to one magazine's worth (lasgun from Guardsmen, autogun from PDF). There's a 25% chance of a frag grenade, and Veterans can carry a krak.
- **Heavy weapon, special weapon and tank ammo can't be scavenged.** Those still need the supply line.
- Bodies fade after 3 minutes (or rise as zombies, 9.4).
- Bots scavenge when their reserve is below 25% and no enemy is within 30 m.

### 12.7 Requests and Tasks
- Squad vox-ops and HWT loaders can send **Supply Requests** (type, amount, location). Bots send them automatically (4.3).
- Requests show up as **tasks** on the commander's map, on a board at each depot and on the HUD of players near a depot.
- Any player who picks up the matching crate is guided to the request. Delivering earns Favour (8.1), and escorts get a bonus (11.6).
- The commander's **Supply Priority** sets the order of requests on the depot board.
- **Request states:** Open → Claimed (someone is carrying it, ETA shown) → Delivered or Lost (carrier killed, crate captured).

### 12.8 Bot Logistics
- **Idle bot riflemen** near a depot pick up open requests nearest to them, up to one bot per request.
- **Supply Detail bots** (11.3) run a fixed route between a depot and a position, carrying whatever that position needs next.
- Bots carrying crates avoid known enemy positions and wait for escorts if the route has had contact in the last minute.

### 12.9 Why It Matters (Design Intent)
- HWTs are only as strong as their supply line. A lascannon team with no power packs is two riflemen with a heavy, useless gun.
- Depots are unlimited, so the **distance and danger between depot and position** is what matters. Where to put depots, when to move them and how to protect them are the commander's big logistics decisions.
- The AI Director (14.4) **hunts supply lines**: carriers, the hauler and depots. Escorting, choosing safe routes and keeping depots manned are real tactical decisions.
- **Dynamic response:** when a position calls "Critical ammo" under heavy attack, the platoon has to choose to send runners now or pull back. That choice is the game.

## 13. Spawning, Death and Reinforcement

### 13.1 Reinforcement Pool
The platoon shares one **reinforcement pool** of tickets for the whole operation.

| Difficulty | Starting pool |
|---|---|
| Rabble | 400 |
| Regiment | 300 |
| Crusade | 250 |
| Purgatus | 180 |

| What it costs | Tickets |
|---|---|
| Human respawn | 1 |
| **Bot respawn** | **0.5** (so matches with few humans aren't drained by bot mistakes) |
| Ogryn respawn | 3 |
| Leman Russ arrival | 10 |
| Revives (squadmate, medic, Blessed Stitching) | Free. Saving a life saves a ticket. |

- **Topping up:** completing an operation phase adds **+50**. The commander's Reinforcement Tithe adds +15 (9.8).
- The pool is shown to everyone on the HUD and map, and announced over vox at 50%, 25% and 10%.

### 13.2 Last Stand
When the pool reaches 0:
- **No more respawns.** A "No Reinforcements" warning plays for everyone.
- Players still alive keep fighting. Downed players can still be revived, and Blessed Stitching still works.
- **Completing the current phase objective** refills the pool to **25% of the starting pool** plus the normal phase bonus, and respawns come back.
- If **every** platoon member is dead, the operation **fails**.
- **Taking over bots:** during a last stand, a dead human can take control of a **living bot in their own squad** (or any squad, if theirs has none left), so humans aren't stuck spectating. The human keeps their personal Favour; the bot's kit and tier are used for that life.

### 13.3 Spawn Points and Waves
Players spawn in **waves** so groups arrive together. Every player waits at least **10 s** after death before joining any wave.

| Spawn | Who can use it | Wave interval | Conditions |
|---|---|---|---|
| **Rear Depot** | Everyone | 15 s | Always available |
| **Forward Depot** | Everyone | 15 s | Not destroyed or captured, no enemies within 30 m |
| **Rally Point** (planted icon) | Everyone | 20 s (15 s at Standard Bearer track 40, 8.5) | Icon planted, no enemies within 30 m |
| **Squad Leader** | Own squad | 30 s | Leader alive, not Downed, not damaged in the last 10 s, no enemies within 15 m. Spawn within 5 m behind the leader. |
| **Leman Russ seat** | Anyone (10.5) | Next wave at the tank's depot | Seat empty or held by a bot |

- A spawn point that becomes unavailable during a wave countdown moves waiting players to their next choice.
- Freshly spawned players don't build suppression for 3 s.

### 13.4 The Respawn Screen
A map with every spawn point, its wave timer and the fighting near it. The player chooses:
- **Spawn point**
- **Loadout** within their tier and role: weapon pattern (7.7), gear items (7.6), grenade mix
- **Ogryn**, if eligible (8.8)
- **Leman Russ seat**, if one is open (10.5)
- **Swap slot** into any bot-held role (4.4)

Notes:
- New tier kit is given on respawn (8.3).
- A gunner gets a new heavy weapon only when spawning at a depot (4.3).
- While waiting, the player can watch their squadmates or study the map.

### 13.5 Bot Respawning
- Bots respawn in the same waves and pay half a ticket.
- They pick the available spawn point closest to their squad's current objective, preferring the squad leader, then the Rally Point, then the nearest depot.
- Bot gunners without a heavy weapon spawn at a depot, or go and recover their dropped weapon if it's within 50 m of their spawn.

## 14. Enemies and the AI Director

### 14.1 Enemy Roster (Loyalist Imperial Forces)
Forces and factions are described in Section 3.4. There are **no Space Marines** in the game: the war stays Guard against traitor Guard, with the Ecclesiarchy and Sisters of Battle as the elite threat.

| Unit | Armour | Weapons | Threat | Counter |
|---|---|---|---|---|
| **PDF conscripts** | None (0) | Autoguns, stub guns | Numerous, break easily | Suppression, zombies |
| **Guardsman squad** (10, mirrors the platoon's squads) | Flak (1) | Lasguns, 1 special weapon, a vox-op | Disciplined volume infantry | Small arms, HWT suppression |
| **Sergeant** | Flak (1) | Laspistol, chainsword | Leads a squad, buffs morale | Priority target |
| **Veterans** | Carapace (2) | Hellguns, melta, krak | Elite infantry, anti-tank | Plasma, bolter, hounds |
| **Commissar** | Carapace (2) | Bolt pistol, power sword | Strong morale aura, stops retreats by executing fleeing troops | Kill to collapse local morale |
| **Officer** (Lieutenant / Captain) | Carapace (2) | Laspistol, power sword | Coordinates sector attacks (14.5) | Kill to disrupt the Director |
| **Heavy Weapons Team** | Flak (1) | Heavy bolter, autocannon, lascannon, mortar | Locks down lanes | Flank, grenades, hounds, Chaos Spawn |
| **Sniper** | Flak (1) | Long-las | Picks off leaders, vox-ops, tank commanders, the enginseer | Hounds, autocannon, smoke |
| **Forward Observer** | Flak (1) | Laspistol, vox | Calls Basilisk barrages | Kill to stop artillery (14.5) |
| **Ministorum Priest** | Flak (1) | Eviscerator or shotgun | Fanatic aura, leads zealot rushes | Flamers, focused fire |
| **Frateris Militia** | None (0) | Autoguns, clubs, torches | Zealot mobs that charge | Suppression, flamers |
| **Tempestus Scions** (elite event) | Carapace (2) | Hot-shot lasguns, plasma, melta | Deep-strike from a Valkyrie behind the platoon's lines, often on depots | Fast response, hounds |
| **Sisters of Battle squad** (elite event) | Power armour (3) | Bolters, flamers, melta | Faith buffs, strong in melee, can execute players | Plasma, melta, Chaos Spawn |
| **Penitent Engine** (climax event) | Light vehicle (4) | Twin flamers, buzz-blades | Fast walker that charges into the platoon | Autocannon, krak, lascannon |
| **Canoness** (climax event) | Power armour (3) | Inferno pistol, power sword | Leads the final Sisters' assault, buffs nearby Sisters | Everything the platoon has |
| **Sentinel** | Light vehicle (4) | Multi-laser or lascannon | Fast flanker | Autocannon, krak, missile |
| **Chimera** | Front 5, side/rear 4 | Multi-laser, heavy bolter | Carries a squad into the fight | Lascannon, melta, krak |
| **Leman Russ** | Front 6, side 5, rear 4 | As the platoon's tank | Heavy armour | Lascannon, melta, coordinated krak |
| **Basilisk battery** (off-map) | — | Earthshaker shells | Punishes static positions | Kill the forward observers, destroy the battery in a phase objective |

### 14.2 AI Squad Behaviour
- Enemy squads use the **same rules as the platoon**: fire teams, suppression and morale (6.7), vox-ops.
- They use cover, suppress and flank, throw grenades into positions they can't hit, and fall back to the next line when broken.
- Commissars stop retreats by executing fleeing troops in view of the platoon.
- Priests turn broken squads into fanatic charges.
- A squad whose vox-op is dead can't call artillery or ask for help (14.5).

### 14.3 The AI Director
**Authored and reactive.** Each phase of an operation has a hand-built defence. The Director adds pressure on top based on how the platoon is doing.

**Authored layer (designers):**
- Defence lines, bunkers, HWT nests, patrols and garrisons for each phase.
- Set-piece events (a Chimera breakthrough, a Basilisk battery, the Sisters' assault in the Basilica).
- **Spawn zones** behind the enemy's lines where reinforcements arrive.

**Reactive layer (Director):**
- Tracks **platoon stress**: casualties, ammo states, reinforcement pool, how long since the last fight, objective progress.
- Cycles intensity: **build-up → peak assault → relief**. Relief gives time for logistics, but never lasts so long that progression stalls (8.2).
- Spends a **threat budget** each minute that grows with difficulty and phase:

| Option | Budget cost |
|---|---|
| Reinforcement squad (Guardsmen or PDF) | 1 |
| Zealot mob (Priest + Frateris) | 1 |
| Raiding party against logistics (14.4) | 2 |
| Sniper or HWT moved to a new position | 2 |
| Sentinel pair | 3 |
| Basilisk barrage (needs a living forward observer) | 3 |
| Chimera with a squad | 4 |
| Coordinated counter-attack on an objective (needs a living officer or the HQ, 14.5) | 6 |
| Leman Russ | 8 |
| Tempestus Scion deep strike | 8 |
| Sisters of Battle squad | 10 |

- **Attention:** spreads pressure across squads so that no single squad is starved of action or permanently overrun.
- **Reacting to the platoon:** the Director answers what it sees. A Leman Russ arriving draws anti-tank threats. Heavy use of zombies draws flamer teams and priests. Static positions draw barrages.
- **Active enemy cap:** **100–150** enemies at once across the operation area, with up to ~60 in any one sector.

### 14.4 Director Tactics Against Logistics
- **Raiding parties** target the hauler, supply carriers and dropped crates.
- **Depot assaults** on forward depots that are low on defenders, to destroy or capture them (12.4).
- **Infiltrators** go after HWT positions and the commander while in Tactical Command.
- **Barrages** target positions that haven't moved for a long time (anti-turtling).
- The Director **telegraphs** major attacks (vox chatter, flares, engine noise) so the platoon has a chance to respond. The platoon vox-op's Intercept gives earlier warning and the direction (4.3).

### 14.5 Enemy Command Structure
The loyalists have a chain of command the platoon can attack.

| Element | What it enables | Taking it out |
|---|---|---|
| **Sector HQ** (command bunker with a vox mast, one per phase area) | Coordinated counter-attacks, a faster reinforcement rate, Basilisk barrages through observers | Destroying the vox mast (demolition charges, lascannon or the battle cannon) or capturing the bunker. For **5 minutes**: no barrages, no coordinated counter-attacks, reinforcements 50% slower. Often a phase objective. |
| **Officer** (one per sector, guarded) | Coordinated counter-attacks in their sector, nearby squads +morale | Killing them: nearby enemy squads take a big morale hit, and the Director can't buy coordinated counter-attacks in that sector for **3 minutes**. A new officer arrives after that. |
| **Forward Observers** | Basilisk barrages on what they can see | Each one killed removes barrages from its area until a new one moves up (2 minutes). |
| **Squad vox-ops** | Squads calling for help and artillery | A squad with no vox-op fights alone. |

- Officers and observers are marked when spotted, and the platoon vox-op's Intercept can reveal their approximate location.
- This gives the commander a strategic choice: push the objective, or first raid the HQ or hunt the officer to make the next fight easier.

### 14.6 Scaling
- Enemy strength scales with **difficulty and phase**, not with the number of humans. Bots fill the platoon, so it's always 45 strong.
- Higher difficulties raise the threat budget, enemy accuracy and the share of elites, and shorten the Director's relief periods.

## 15. Missions and Maps

### 15.1 Operation Structure
- An operation lasts **45–60 minutes** and has **4 phases** of roughly 12–15 minutes each.
- Each operation covers one region of Varrus Secundus (3.3). Phases move the front forward through the map's **sectors**, which unlock in order so 45 players stay on a coherent front.
- **Typical phase flow:** objective revealed → approach and contact → assault → objective secured → consolidation (move depots and the icon up, resupply) → next phase.
- Completing a phase gives +50 reinforcement tickets (13.1) and +30 Platoon Favour (9.8).

### 15.2 Soft Phase Timers
Each phase has a **target time**. Going over it never fails the operation. Instead the loyalists bring up more and more force.

| Time over target | Director escalation |
|---|---|
| Under target | **Bonus:** +15 Platoon Favour on completion |
| +0–2 min | Normal |
| +2 min | Threat budget +25% |
| +5 min | A guaranteed elite event (Scion deep strike or Sisters squad) |
| +8 min | **Purge Order:** continuous Basilisk barrages on the platoon's rear, threat budget +50% |

The target time and countdown are shown on the HUD and in Tactical Command.

### 15.3 Map Scale
- About **1.5×1.5 km to 2.5×2.5 km** per map, sized for a 45–60 minute push.
- Each map has 4 phase sectors, a rear depot area, and enemy spawn zones behind each defence line.
- Routes matter: every sector offers at least **three approaches** (for example, a main road for the tank and hauler, a covered infantry route and a flanking route) so the commander has real choices.

### 15.4 Variation Between Plays

| Variable | Options |
|---|---|
| **Time of day** | Dawn, day, dusk, night (lumen lamps, flares, muzzle flashes matter at night) |
| **Weather** (per region) | Ashfields: **ash storms** (visibility cut to ~80 m, Basilisk observers can't spot). Hab-Sprawl: **acid rain** (light damage in the open for anyone without carapace). Refinery Nine: **smog** and spreading fires. Agri-Belt: **ground fog** at dawn. The Sump: **flooding** in low tunnels. Basilica: clear, with smoke from burning districts. |
| **Objective variants** | Each phase has **2–3 authored versions** of its objective (different locations or types), picked at random. For example, the Basilisk battery can be in the quarry or the rail yard. |
| **Director** | The reactive layer (14.3) makes every fight play differently. |

### 15.5 First Release: Two Operations
The project starts with **1–2 operations** and adds regions over time.

#### Operation 1: Breaking the Ashfields
Trench warfare on the ash wastes outside the hive. Shows off every core system.

| Phase | Target time | Objective (variants) | Focus |
|---|---|---|---|
| 1. **Breach** | 12 min | Take the first trench line (centre bunker **or** the flanking redoubt) and build the first forward depot | Assault under fire, HWT overwatch, first depot |
| 2. **Silence the Guns** | 15 min | Destroy the Basilisk battery (quarry **or** rail yard). The sector HQ and forward observers are optional targets (14.5). | Long approach, artillery, the commander's choice of raiding the HQ first |
| 3. **Hold the Line** | 12 min | Survive an armoured counter-attack on the captured second line until the timer ends | HWTs, anti-tank, logistics under pressure, tank versus tank |
| 4. **Desecrate the Gate** | 15 min | Plant the icon at the shrine on the hive gate (inner courtyard **or** gate tower) and defend it for 5 minutes | Final push, everything the platoon has |

#### Operation 2: The Fall of Karsten Hab-Sprawl
Dense urban fighting through hab-blocks. Tests close-quarters play, short but dangerous supply runs and verticality.

| Phase | Target time | Objective (variants) | Focus |
|---|---|---|---|
| 1. **Into the Sprawl** | 12 min | Capture the transit plaza (plaza **or** market hall) and build a depot | Street fighting, snipers in hab windows |
| 2. **Burn the Barracks** | 15 min | Clear a PDF barracks block floor by floor, or sabotage the armoury (variant) | Flamers, Ogryn, room clearing, zombies through corridors |
| 3. **Cut the Vox** | 12 min | Destroy the sector HQ's vox mast on a hab-tower roof | Vertical assault, HWTs on rooftops covering the climb |
| 4. **Sermon's End** | 15 min | Assassinate the Ministorum Confessor leading the zealot militia at the chapel, then hold the chapel against a final Frateris surge | Zealot mobs, Priests, a Sisters elite event |

#### Later Operations
Refinery Nine, Hollowmere Agri-Belt, The Sump and the Basilica of Saint Vorena (the Sisters' climax with the Canoness and Penitent Engines) follow after the first release.

### 15.6 Objective Types
| Type | Description |
|---|---|
| **Capture / Hold** | Take an area and keep it for a set time. |
| **Destroy** | Destroy a target: artillery battery, vox mast, ammo dump, fuel depot. |
| **Desecrate** | The Standard Bearer plants the icon at a holy site and the platoon defends it. |
| **Sabotage** | Plant demolition charges on several points. |
| **Assassinate** | Kill a named enemy leader (Commissar-General, Confessor, Canoness). |
| **Survive** | Hold a position against waves until a timer ends. |
| **Escort** | Protect a slow allied unit (a plague cauldron, a traitor sorcerer) to a destination. |

### 15.7 Difficulty
| Level | Name | Changes |
|---|---|---|
| 1 | Rabble | Generous pool, low enemy accuracy, slow Director escalation |
| 2 | Regiment | Baseline |
| 3 | Crusade | Higher threat budget, more elites, shorter relief periods |
| 4 | Purgatus | Low pool, more Sisters and Scion events, harsher logistics (crates hold less, faster crate capture) |

### 15.8 End of Operation
- **Victory:** all four phases complete. **Defeat:** every platoon member dead during a last stand (13.2).
- The results screen shows platoon stats (kills, deliveries, revives, call-ins, tanks lost), each player's highest tier and mutation, and a few awards (most deliveries, best HWT team, longest-surviving tank commander).
- Meta-progression XP is given for the operation (Section 19), with a bonus for victory and difficulty.

## 16. Communication

### 16.1 Voice Channels
Every player hears **proximity voice** plus their **unit channel**. Leaders also get the **command net**.

| Channel | Who | Notes |
|---|---|---|
| **Proximity** | Anyone within ~30 m (a **shout** key doubles the range) | Heard in the world, muffled by walls. Enemies don't react to it. |
| **Squad radio** | The 10 members of a squad | Works anywhere on the map. |
| **HWT net** | All 10 heavy weapons team members | The Heavy Weapons Section's own channel. |
| **Command Section net** | The commander and the 4 veterans | |
| **Command net** | Commander, squad leaders, HWT gunners, tank commander, hauler driver | Squad leaders are on it **only through their squad vox-op** (if the vox-op is dead, the leader loses the net until someone picks up the vox-set). HWT gunners, the tank commander and the hauler driver are on it within 40 m of any vox-op or the commander. |
| **All-call** | Commander speaks to the whole platoon | Needs the Platoon Link (platoon vox-op nearby, 4.3). |
| **Tank intercom** | The 6 crew while aboard | Added on top of their unit channel. |

- Push-to-talk, a separate key per channel. A speaker indicator shows who is talking and on which channel.

### 16.2 Vox Degradation
- Radio audio is filtered, and gets noisier with distance from the speaker's vox-op.
- **Jamming:** while an enemy sector HQ stands (14.5), the Director can trigger jamming that adds heavy static to the command net and all-call for 60 s. Destroying the HQ stops it.
- A squad whose vox-op is dead keeps squad radio but loses the command net, orders (11.4) and call-ins (9.1).

### 16.3 Pings and Wheels
- **Ping** (one key, context-sensitive): enemy, vehicle, move here, defend here, need ammo, need medic, crate here, brace point. Pings show on the compass, the map and in the world.
- **Comms wheel** (everyone): yes, no, thanks, need ammo, need medic, reloading, cover me, follow me, sorry.
- **Squad command wheel** (squad leaders): follow me, hold here, move there, suppress that, grenade that, regroup, Bravo flank left/right. Bots follow these straight away; humans see them as prompts.
- **Call-in wheel** (squad leaders and commander): call-ins and their orders (9.3).

### 16.4 Bot Voice
- Bots use **short voiced callouts**: contact with direction and distance, reloading, frag out, need ammo, medic, man down, acknowledging orders, "brace point here", "tank coming up".
- Callouts have a priority and cooldown system so they don't spam. A slider sets bot chatter volume.
- **Voices change with tier:** cultists rant and pray, Moebians are clipped and military through rebreathers, Ogryn are slow and simple.
- Bots respond to pings and the command wheels (16.3).
- **Enemy barks:** loyalist AI shout callouts too ("Heretics on the left!", "Grenade!"). Players can learn to read enemy intent from them.

### 16.5 Text and Accessibility
- Squad and platoon text chat, plus the comms wheel as quick chat.
- **Subtitles** for all callouts, vox and enemy barks, with speaker name and channel.
- Mute and volume per player and per channel.

## 17. UI and HUD

### 17.1 Principles
- **Minimal by default, with toggles.** Eyes stay on the world.
- **No minimap.** A compass bar at the top and a full map screen on a key (17.4).
- Health, suppression and wounds are shown mostly through screen effects and body status, not numbers.

### 17.2 HUD Elements

| Element | Default | Options |
|---|---|---|
| Compass bar with markers (waypoints, pings, objectives) | On | — |
| Magazine bar + reserve number | On | Exact rounds in magazine |
| Grenades and gear icons | On | — |
| Favour tick and tier progress bar | On (small) | Hide |
| Squad status strip (alive / downed / dead, human or bot) | On | Hide |
| Objective, phase timer (15.2), reinforcement pool | On | — |
| Friendly nameplates when aiming at a friendly (50 m) | On | Always show within 20 m |
| 3D world markers (pings, objectives) | On | Off |
| Health | Screen effects and a body-status icon (wounded, limb hits) | Health bar |
| Damage direction indicator | On | Off |
| Suppression vignette | Always | — |

- **Presets:** *Assisted* (all options on), *Recommended* (defaults), *Hardcore* (no world markers, no nameplates, no squad strip).
- **No hitmarkers** in any preset: kills are confirmed by the fly-buzz and Favour tick (6.9).

### 17.3 Role Extras
| Role | Extra HUD |
|---|---|
| Squad leader | Squad Favour, call-in readiness and cooldowns, distance to the squad vox-op |
| Commander | Alert feed, Platoon Favour (the full view is on the data-slate, Section 11) |
| Medic | Downed players on the compass with their bleed-out timers, satchel charges |
| HWT gunner and loader | Brace indicator (valid brace surfaces glow on approach, the sight only appears when braced), reloads left for the team |
| Tank seats | Weapon arc, hull %, damaged components, ammo, enginseer status |
| Hauler driver | Cargo contents |
| Anyone carrying a crate | Destination of the matching request and the route to it |

### 17.4 Map Screen (Everyone)
- Full-screen map on a key, showing what the platoon has spotted (11.5), objectives, depots, the icon, the hauler, the tank and supply requests.
- Players can ping from the map but can't give orders (only the commander can, Section 11).

### 17.5 Other Screens
- **Respawn screen:** Section 13.4.
- **Tactical Command:** Section 11.
- **Results screen:** Section 15.8.

### 17.6 Readability and Accessibility
- Friends and enemies are distinguished first by art (3.4), then by nameplates.
- Allied Chaos units have a sickly green outline (9.7).
- Colour-blind modes change marker and outline colours.
- Text size and HUD scale options.

## 18. Art and Audio Direction
- **Art:** gritty grimdark realism. Muted palettes (greys and rust) with sickly green and yellow corruption accents. Imperial structures in gothic stone and brass. Corruption spreads across the map visually as the platoon advances (rot, fungal growth and flies on captured sectors).
- **Audio:** heavy, mechanical weapons; deep thumps for the autocannon and battle cannon; the lascannon's charge whine as a warning cue. Plague call-ins are introduced by droning flies and wet growls. Loyalist hymns and vox chatter give enemy AI a personality.

## 19. Meta-Progression
Unlocks outside a match, kept **horizontal** so 45-player co-op stays balanced:
- **Toxin Grenades** (unlocked at Regiment Rank X; also need in-match Blessed tier). This covers "unlock later".
- Alternative weapon patterns (e.g., Accatran-pattern lasgun, Mars-pattern autocannon) with sidegrade stats.
- Cosmetics: mutation choices, tattered regalia, icons, helmet variants.
- Role mastery badges and titles.
- **No monetisation of any kind** (fan project). All unlocks are earned by playing.

## 20. Technical Considerations
- **Engine:** Unreal Engine 5 recommended (proven for large-scale shooters, strong networking base, World Partition for large maps).
- **Networking:** dedicated, server-authoritative servers. 45 players plus 150–300 AI agents needs:
  - Network relevancy and replication LOD by distance.
  - AI LOD: full behaviour near players, simplified "abstract combat" in distant sectors.
  - Plague zombies simulated as lightweight crowd agents (Mass Entity / ECS-style).
- **Target performance:** 60 FPS on recommended PC specs; 30 Hz server tick minimum, 60 Hz target.
- **Physics:** crates and backblast are physical. Destruction is limited to authored destructible cover to keep replication costs down.
- **Bots:** AI bots fill every empty player slot, including the commander (Section 21). Bots are a core system, not a fallback: the game must be playable with 1 human and 44 bots. Bots use the same role logic and respond to the commander's orders like players do.

## 21. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| **Filling 45-player lobbies** | Long queues and dead matches | **Current plan: AI bots fill all empty slots**, including a commander bot that issues basic orders. Humans drop in and replace a bot in their chosen role mid-match. A smaller 25-player "Detachment" mode stays an option. |
| **Logistics feels like chores** | Players skip it and positions starve | Favour for deliveries, Ogryn carry synergy, short and readable routes, the hauler for long hauls, a dramatic Director that makes supply runs tense, crates delivered to a request highlighted as a team "win". |
| **Commander quality varies** | Bad commander ruins a 45-player match | Squad-level autonomy (squad leaders can set their own objectives), commander vote-kick/swap, onboarding tutorial for the role. |
| **Tank pulls too many players** | Infantry hollowed out | Seats fill from the respawn queue first; tank can run partially crewed; one tank cap. |
| **Snowballing Favour** | Late game trivial or new joiners useless | Death progress penalty, half Favour from AI allies, call-in cooldowns, Director scales threat with platoon power. |
| **Performance (many AI)** | Low framerate and desync | AI LOD, crowd systems for zombies, sector-based simulation. |
| **IP takedown** | Fan project gets shut down | Stay strictly non-commercial, make all assets in-house, credit Games Workshop with an unofficial/not-endorsed notice, keep content data-driven so it can be reskinned. |

## 22. Open Questions
_None open right now._

**Decided:** proximity voice plus vox channels that depend on living vox-ops (16.1); bots give voiced callouts (16.4); minimal HUD with toggles and presets (17.2); no minimap (17.1); operations last 45–60 minutes in 4 phases (15.1); first release has 1–2 operations, Ashfields and Hab-Sprawl (15.5); soft phase timers that escalate instead of failing (15.2); random time of day, weather and objective variants (15.4); no Space Marines (14.1); 100–150 enemies active at once (14.3); authored defences plus a reactive Director (14.3); loyalists have officers and sector HQs the platoon can attack (14.5); bot respawns cost half a ticket (13.1); spawns come in waves of 15–30 s (13.3); an empty pool means a last stand, refilled by completing the phase (13.2); squad leaders are a spawn point when out of combat (13.3); one unarmed hauler per platoon (12.5); all depots have unlimited supplies (12.2); enemies can destroy and capture crates, depots and the hauler's cargo (12.1, 12.4); small arms ammo and grenades can be scavenged from enemy dead (12.6); Tactical Command is a data-slate with the world visible around it (11.1); orders go to squads, fire teams, HWTs, the tank and depots but not individual bots (11.3); following orders is rewarded, never punished (11.6); commander sees platoon sight only (11.5); Leman Russ seats fill with humans first, then respawning bots after 30 s (10.5); the tank is strong but killable by anti-tank (10.3); ammo only, no fuel (10.7); a traitor Enginseer bot comes with the tank and repairs it (10.6); squad leaders give simple orders to zombies and hounds (9.3); the Chaos Spawn is uncontrollable (9.6); zombie contagion capped at 21 (9.4); the commander has platoon call-ins from a Platoon Favour pool (9.8); carapace in ~15 min for an average player (8.2); death costs 25% of progress toward the next tier (8.4); Blessed mutations are pick 1 of 3 random (8.6); the Ogryn is bought with 30 personal Favour (8.8); pooled ammo for small arms and special weapons, discrete reloads for heavy weapons (7.1); plasma overcharge can kill (7.4); weapon patterns instead of attachments (7.7); any soldier can carry one heavy weapon reload in a gear slot (7.6); mid-sim combat, first-person, full friendly fire, simple lethal melee (Section 6); the commander fights normally (4.3); the loader or anyone can man a dropped heavy weapon (4.3); HWTs pick weapons at spawn and swap at depots (4.3); fixed role slots, swap into bot-held slots while dead (4.4); enemy is the loyalist Guard (3.4); Nurgle only (3.2); one invented world, Varrus Secundus (3.3); standalone operations with in-match progression reset each match (3.5); AI bots fill empty slots (20, 21); free non-commercial fan project (3.7).

## 23. Roadmap

| Phase | Goal | Content |
|---|---|---|
| **Prototype** (3–4 months) | Prove fire-and-bracing and the logistics loop | 1 squad + 1 HWT + depot, greybox map, basic AI Guardsmen, first friendly bots for squad slots |
| **Vertical Slice** (6–8 months) | Full platoon structure at 45 players | All roles, Tactical Command, Favour tiers, 2 call-ins, Operation 1 (Ashfields) |
| **Alpha** | Feature complete | Leman Russ, Ogryn, all call-ins, full enemy roster, AI Director, bot backfill |
| **Beta** | Content and scale | Operation 2 (Karsten Hab-Sprawl), difficulty tiers, meta-progression, stress tests at 45 players |
| **First release** | — | 2 operations (Ashfields, Hab-Sprawl), cosmetics |
| **Post-release** | New regions | Refinery Nine, Hollowmere Agri-Belt, The Sump, Basilica of Saint Vorena |

---

## Appendix: Tuning Tables

### A. Role Limits

| Constraint | Value |
|---|---|
| Special weapons per squad | 2 (no duplicates of Melta or Plasma in one squad) |
| Platoon-wide Lascannons | Max 2 |
| Platoon-wide Missile Launchers | Max 2 |
| Platoon-wide Heavy Stubbers / Heavy Bolters / Autocannons | No cap (at most 5 HWTs anyway) |
| Ogryn | 1 per squad, 3 per platoon |
| Leman Russ | 1 per platoon |
| Forward depots | 2 |

### B. Starting Ammo (per life)

| Role | Primary (magazine + reserve) | Grenades |
|---|---|---|
| Cultist | Autogun 30 + 120, or stub rifle 6 + 36 | 1 Frag |
| Moebian Trooper | Lasgun 40 + 160 | 1 Frag, 1 Krak |
| Moebian Veteran | Lasgun 40 + 240 | 2 Frag, 1 Krak |
| Blessed | Lasgun 40 + 240 | 2 Frag, 1 Krak, 1 Toxin* |
| Special Weapons | Per weapon (7.4) | 1 Frag |
| HWT Loader | Reloads per weapon (7.3), lasgun 40 + 120 | 1 Frag, 1 Krak |
| Ogryn | Ripper gun 12 + 72 | 2 Frag bombs |

\* Toxin only if unlocked through meta-progression.

### C. Call-In Costs

| Call-in | Pool | Cost | Cooldown |
|---|---|---|---|
| Plague Zombie Horde | Squad | 25 | 180 s |
| Plague Hounds | Squad | 40 | 240 s |
| Chaos Spawn | Squad | 80 | 360 s |
| Leman Russ | Squad | 200 + approval | 1 active |
| Carrion Flock | Platoon | 30 | 180 s |
| Supply Drop | Platoon | 40 | 240 s |
| Blight Fog | Platoon | 50 | 300 s |
| Plague Barrage | Platoon | 70 | 360 s |
| Reinforcement Tithe | Platoon | 100 | Once per phase |

### D. Carry Speeds

| Load | Speed modifier |
|---|---|
| Unencumbered | 100% |
| HWT gunner with weapon (unbraced) | 75% |
| One-man crate | 80% |
| Two-man crate (each carrier) | 60% |
| Ogryn with two-man crate | 100% |
| Ogryn with two one-man crates | 90% |
