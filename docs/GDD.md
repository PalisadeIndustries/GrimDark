# GrimDark — Game Design Document

> **Working title:** GrimDark
> **Genre:** 45-player co-op PvE tactical combined-arms shooter
> **Setting:** Warhammer 40,000, playing a fallen, Chaos-corrupted Astra Militarum regiment in the vein of the Moebian 6th
> **Document status:** Draft v0.1. All numbers are starting values to tune in playtests, not final balance.

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

- **Faction:** A fallen Astra Militarum regiment that has turned to the Plague God. Its ranks are a mix of veteran traitor Guardsmen ("Moebians") and the cultist mobs they gather from conquered hive districts. Its corruption is mainly Nurgle-aligned: plague zombies, plague hounds, toxin weapons and bloated Ogryn.
- **Tone:** Grim, filthy, darkly comedic, never heroic. The loyalists are the "heroes" of their own story, and the player is the plague moving across their world.
- **Visual arc:** Players start as rag-wrapped cultists with improvised flak. As they progress they become disciplined, gas-masked Moebian troopers in tarnished carapace, with growing marks of the Plague God such as boils, rust, flies and stitched flesh.
- **IP note:** Warhammer 40,000 is Games Workshop IP. A commercial release needs a license. Keep the systems IP-agnostic (factions, units and names sit in data tables) so the game could be reskinned to an original setting if needed.

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

### 4.2 Role Summaries

#### Platoon Commander (1)
- **Job:** Strategic decisions. Opens **Tactical Command** (Section 11) to issue orders, set objectives, assign HWTs, manage depot priorities and approve major call-ins such as the Leman Russ.
- **Kit:** Carapace, bolt pistol or laspistol, power sword or chainsword, frag/krak, a command auspex (marks targets for the platoon).
- **Unique:** The platoon's highest authority. Commander orders give "Followed Orders" Favour bonuses to the squads that carry them out.

#### Veteran Medic (1)
- Revives downed players faster and from further away than squad-level stabilisation. Can treat "Wounded" status (see 13.2).
- Carries a **Medicae Satchel** (limited charges, refilled from Medical crates at depots).
- Corrupted flavour: "Blessed Stitching" can raise a fallen trooper with a temporary toughness buff and a slow movement debuff.

#### Veteran Vox-Operator (1)
- Gives the commander platoon-wide comms range. Without the platoon vox-op nearby (about 30 m), the commander's **orders reach squads only through their squad vox-ops**, with a delay and reduced range.
- Needed for platoon-level call-ins: depot establishment, supply drops and Leman Russ authorisation.
- The vox-set is a physical backpack. If the operator dies it can be picked up by anyone in the Command Section.

#### Veteran Standard Bearer (1)
- Carries the **Icon of Corruption**. Planting it creates a **Rally Point** (a forward spawn, see 13) and a morale/suppression-resistance aura.
- Carrying the icon gives a smaller moving aura.
- The icon can be **desecrated** by enemies if left undefended. Losing it gives a temporary platoon-wide morale penalty.

#### Veteran Special Weapons (1)
- Same special weapon choices as the squads (7.2) with carapace and an extra ammo slot.
- The commander's flexible response asset, usually a melta or plasma for anti-armour emergencies.

#### Heavy Weapons Teams (5 × 2)
- **Gunner:** Fires the weapon. Cannot fire unbraced (6.3). Carries the weapon (slowed) and a sidearm.
- **Loader:** Carries ammo (a set number of reloads), reloads faster than a gunner can alone, spots, and defends with a lasgun or autogun. For the heavy stubber, the loader can act as a **human bipod** (6.3).
- Each team picks one weapon at spawn: **Autocannon, Heavy Bolter, Heavy Stubber, Missile Launcher, or Lascannon**. Platoon-wide limits may apply (Appendix A).
- Kill credit is **shared 100% between gunner and loader** so loaders progress too.

#### Squad Leader (3)
- Leads 9 players. Places squad waypoints and marks targets.
- Spends **Squad Favour** on call-ins (Section 9). Calling in needs the squad vox-op nearby.
- Acts as a mobile spawn point for their squad (13).

#### Squad Vox-Operator (3)
- Links the squad to the commander. Relays orders and enables the squad leader's call-ins.
- Can **request resupply** for the squad, which creates a supply task on the commander's map and at the depot.

#### Squad Special Weapons (6)
- Two per squad. Chosen at spawn from **Grenade Launcher, Bolter, Plasma Gun, Melta Gun, Flamer**, subject to squad limits (Appendix A).

#### Riflemen (18)
- The core of the platoon. They gain the most from **Marks of Favour** (Section 8): rifleman to Moebian to carapace veteran, and eventually the option to spawn as an **Ogryn**.
- Main labour for logistics: carrying crates, digging in, escorting HWTs.

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

### 5.3 Operation (60–90 minutes)
Several phases across a large map (Section 15). The AI Director counter-attacks, cuts supply lines and adds new threats. The platoon has to adapt, holding gains while pushing forward.

### 5.4 Progression Arc (one match)
```
Cultist → Moebian Trooper → Moebian Veteran (carapace) → Blessed → Ogryn eligibility
Squad Favour → Plague Zombies → Plague Hounds → Chaos Spawn → Leman Russ
```

## 6. Combat Systems

### 6.1 Damage and Armour
- Location-based damage (head, torso, limbs).
- Armour classes: **Rags/None < Flak < Carapace < Power Armour (enemy elites) < Vehicle armour (front/side/rear)**.
- Each weapon has **penetration** and **damage** values. Penetration against armour class sets the damage multiplier, so a lasgun can still drop carapace but needs volume of fire.

### 6.2 Suppression and Morale
- Incoming fire builds **Suppression**: screen effects, wider sway and slower ADS.
- Morale modifiers: Standard Bearer aura (+), nearby squad leader (+), Chaos call-in units nearby (+), squadmates dying nearby (−), enemy Commissar/Priest auras (affect enemy AI only).
- The AI uses the same suppression model, so pinning the enemy really stops it firing.

### 6.3 Bracing (Heavy Weapons)
**All heavy weapons must be braced to fire.** This is the defining rule of the Heavy Weapons Section.

| Brace type | Valid for | Setup time | Arc | Notes |
|---|---|---|---|---|
| **Tripod/Mount deploy** | All heavy weapons | 3–5 s (weapon dependent) | 60° | Most stable. The loader can speed up setup by 40%. |
| **Terrain brace** | All heavy weapons | 1.5 s | 30° | Needs a valid ledge, sandbag, wall or window. Shown by a context prompt. |
| **Prone/bipod** | Heavy Stubber, Heavy Bolter, Autocannon | 2 s | 25° | Heavy Bolter and Autocannon get extra recoil when bipodded. |
| **Loader's shoulder** | **Heavy Stubber only** | 1 s | 45° | The loader stands still and becomes the mount. Both players are locked in place, and the loader can turn to traverse. If the loader is hit or moves, the brace breaks. Allows high-angle fire over cover. |

- **Unbraced:** heavy weapons cannot fire. The gunner can only carry them at a slowed pace.
- Missile Launcher and Lascannon have a **backblast cone**: friendly damage and dust that gives away the position.
- **Displacement:** packing up takes time, which rewards teams that pick good positions and punishes being out-flanked.

### 6.4 Downed, Wounded and Dead
- At 0 HP you go **Downed** (bleed-out timer ~45 s). Squadmates can stabilise. The Veteran Medic can do a full revive.
- A player revived without the medic is **Wounded**: lower max HP and more sway until treated by the medic or at a depot Medical station.
- Execution, headshots or explosive overkill skip Downed and go straight to **Dead** (Section 13).

### 6.5 Friendly Fire
On, at reduced damage (35% small arms, 100% explosives, backblast and flamers). It reinforces discipline and makes call-in placement matter. Server option for private matches.

## 7. Weapons and Equipment

### 7.1 Heavy Weapons

| Weapon | Role | Pen | Ammo type | Reloads carried by loader | Setup | Notes |
|---|---|---|---|---|---|---|
| **Heavy Stubber** | Anti-infantry suppression | Low | Stubber belts | 6 | Fast | Only weapon allowed on the loader's shoulder. Highest suppression per second. |
| **Heavy Bolter** | Anti-infantry / light vehicle | Med | Bolter ammo box | 4 | Med | Explosive rounds, small AoE. |
| **Autocannon** | Anti-light-armour / anti-elite | Med-High | Autocannon clips | 5 | Med | Two-shot bursts. Strong against Sentinels and Chimeras. |
| **Missile Launcher** | Flexible: Frag or Krak missiles | Var | Missiles (Frag/Krak) | 4 (mixed) | Slow | Toggle ammo type. Backblast. |
| **Lascannon** | Anti-tank | Very High | Power packs | 3 | Slow | Charge-up shot. Backblast flash shows the position to enemies. |

### 7.2 Special Weapons

| Weapon | Role | Pen | Ammo | Notes |
|---|---|---|---|---|
| **Grenade Launcher** | Indirect, area denial | Var | Frag/Krak grenades (shared with the launcher pool) | Arcing fire over cover. Can fire Toxin rounds once unlocked. |
| **Bolter** | Precision anti-elite rifle | Med | Bolter magazines | Heavy, strong recoil. Treated as a special weapon for traitor Guard. |
| **Plasma Gun** | Anti-elite / anti-armour | High | Plasma flasks | **Overheat system:** overcharged shots can burn or kill the user. |
| **Melta Gun** | Close-range anti-tank | Extreme | Melta canisters | Very short range. Destroys vehicles in 1–3 shots. |
| **Flamer** | Clearing buildings and trenches | Ignores cover | Promethium tanks | Fire DoT, panics AI, sets terrain alight. The tank can explode if hit. |

### 7.3 Small Arms
- **Cultist:** Autogun or stub rifle, crude knife.
- **Moebian and above:** Lasgun (rechargeable power packs; recharge only at depots) with bayonet.
- **Sidearms:** Laspistol, stub revolver, bolt pistol (commander, Blessed tier).

### 7.4 Grenades

| Grenade | Availability | Effect |
|---|---|---|
| **Frag** | Default | Anti-infantry blast. |
| **Krak** | Default (limited) | Anti-armour, small radius. Can be planted on vehicles and doors. |
| **Toxin** | **Unlocked** (meta-progression, then in-match Blessed tier) | Lingering cloud: DoT, blindness, suppression. Moebians in sealed rebreathers are resistant; cultists and Ogryn are not, so careless use hurts friendlies. |

### 7.5 Gear Slots
Gear slots hold tactical items such as extra ammo pouches, an entrenching tool (build sandbag brace points), auspex, demolition charges, rebreather filters or a medi-pack (self-stabilise). Slot counts grow with Marks of Favour (Section 8).

## 8. Progression: Marks of Favour

Progression in a match is driven mainly by **kill credit**, with smaller amounts from contribution so support roles are not starved.

### 8.1 Favour Sources

| Source | Favour |
|---|---|
| Kill (infantry) | 1 |
| Kill (elite: Commissar, Veteran, Priest, Sister) | 3 |
| Kill (Space Marine) | 8 |
| Vehicle kill (shared among damage dealers) | 5–15 |
| Assist (damage or suppression on a target that dies within 10 s) | 0.5 |
| Crew-served weapon kill | Full credit to **both** gunner and loader |
| Delivering a supply crate to a requesting position | 1 |
| Revive | 0.5 |
| Completing a commander order (objective secured while ordered) | 3 to each squad member present |

Kills stay the main source. A strong rifleman progresses faster than a pure supply runner, but nobody gets stuck.

### 8.2 Personal Tiers (Riflemen, Squad Vox, Squad Special Weapons)

| Tier | Name | Threshold (personal Favour) | Armour | Grenade slots | Gear slots | Other |
|---|---|---|---|---|---|---|
| 0 | **Cultist** | Start | Rags/none | 1 (Frag) | 1 | Autogun or stub rifle. Fast sprint. |
| 1 | **Moebian Trooper** | 8 | Flak | 2 (Frag/Krak) | 2 | Lasgun, rebreather (toxin resistance). |
| 2 | **Moebian Veteran** | 20 | **Carapace** | 3 | 3 | Bayonet charge, faster brace and revive. |
| 3 | **Blessed** | 40 | Carapace + "Rot-hardened" (passive DR) | 4 (Toxin unlocked) | 3 | Visible mutation, small morale aura. |
| ★ | **Ogryn eligible** | 60 lifetime in this match | — | — | — | Can **spawn as an Ogryn** (8.4). |

- Tiers **persist through death** for the match.
- On death you lose **25% of your progress toward the next tier** (never below your current tier). This makes death matter without wiping out progress.
- Squad special weapons operators and squad vox-ops follow the same tiers, keeping their role weapon.
- Command Section veterans already start in carapace and use the **Veteran track** instead: perk unlocks at the same thresholds (for example, faster revive for the medic, a larger icon aura for the bearer).
- HWT gunner and loader use the **Weapon Team track**: faster setup, more reloads carried, and the loader gets carapace at tier 2.

### 8.3 Visual Feedback
Each tier changes the model clearly: rags → flak and gas mask → carapace → carapace with rust, boils and flies. Other players should be able to read rank at 50 m.

### 8.4 The Ogryn
- **Unlock:** at 60 personal Favour (or as set in tuning), the player can choose **Ogryn** on their next respawn.
- **Limit:** one Ogryn per squad at a time, three platoon-wide. Choosing it uses the slot. When the Ogryn dies the player goes back to their rifleman tier and the slot goes on cooldown.
- **Kit:** Ripper gun (close-range shotgun-like burst, melee bash), frag bomb bundle, huge HP pool, cannot use cover well, sprint knocks down infantry.
- **Logistics synergy:** an Ogryn can **carry a two-man crate alone** at normal speed, or **two one-man crates at once**. This is a real reason to bring one besides combat power.
- **Weakness:** big hitbox, no toxin resistance, priority target for enemy AI. Cannot board the Leman Russ.

## 9. Squad Leader Call-Ins

### 9.1 Squad Favour
- Every kill and assist by a squad member **also** adds to that squad's **Squad Favour** pool (separate from personal Favour, so nobody's tier progress is spent).
- Squad Favour is **spent** on call-ins. Calling in needs:
  1. The squad leader alive and not downed.
  2. The **squad vox-operator within 25 m** (or the leader carrying the vox set).
  3. A valid target or deployment location within line of sight or on the map.

### 9.2 Call-In List

| Call-in | Cost | Cooldown (per squad) | Behaviour |
|---|---|---|---|
| **Plague Zombie Horde** | 15 | 2 min | 12–20 shambling plague zombies spawn behind the squad and **advance ahead along a painted path**. They soak fire, show enemy positions and can carry contagion that spreads to enemy corpses (adding more zombies). Slow and fragile. |
| **Plague Hounds** | 25 | 3 min | 3–4 fast hounds. The leader **marks a target or area** and the hounds **hunt** it, prioritising isolated enemies, HWTs and fleeing units. They track enemies through smoke and tag them for the squad. |
| **Chaos Spawn** | 40 | 5 min | One heavily mutated melee monster. Drops on a marked point, charges the nearest enemy concentration and goes berserk. Can't be controlled after release (may attack friendlies who get too close). Strong at breaking fortified points. |
| **Leman Russ** | 100 + commander approval | One active per platoon | See Section 10. |

### 9.3 AI Ally Behaviour Rules
- Allied Chaos AI shows clearly on the HUD (sickly green outlines) to avoid friendly confusion.
- Zombies and hounds count as **squad assists**. Their kills give **half** Squad Favour and no personal Favour, so call-ins can't snowball the economy.
- Call-in units take the Director's "attention" (14.3), drawing enemy focus away from players.

## 10. The Leman Russ

### 10.1 Configuration
A Leman Russ battle tank with:
- **Turret:** Battle cannon (gunner)
- **Hull:** Heavy bolter (hull gunner)
- **Sponsons:** 2× heavy bolters (left and right sponson gunners)
- **Pintle:** Heavy stubber, fired by the **Tank Commander standing in the open hatch**

### 10.2 Crew (6 seats)

| Seat | Weapon | Notes |
|---|---|---|
| Driver | — | Drives. Sees through a narrow vision slit, so relies on the commander's callouts. |
| Gunner | Battle cannon | Turret traverse, HE/AP shells (toggle). Limited shell count. |
| Hull Heavy Bolter Gunner | Heavy bolter | Fixed forward arc. |
| Left Sponson Gunner | Heavy bolter | Left arc. |
| Right Sponson Gunner | Heavy bolter | Right arc. |
| **Tank Commander** | Pintle heavy stubber | **Open hatch:** 360° view, marks targets for the crew, but **exposed** to small arms and snipers. Can close the hatch (lose the stubber and wide view, gain safety). |

### 10.3 Earning and Calling In
1. The squad builds **100 Squad Favour**.
2. The squad leader (with vox-op in range) sends a **Tank Request** to the commander.
3. The commander **approves** in Tactical Command and picks an arrival point: the rear depot (motor pool) or a forward depot with a vehicle bay.
4. The tank arrives after ~45 s (rumble and audio cue).
5. Only **one Leman Russ** per platoon at a time.

### 10.4 Crewing (Recommended Rule)
Six players is a lot to pull from a 45-player platoon, so:
- When the tank arrives, **seats open first to dead or respawning members of the calling squad**, then to any respawning player in the platoon.
- Living players can also walk up and board.
- **The tank can roll with fewer crew**, but every empty seat is a dead weapon. The driver seat is the only one required for movement. Unmanned weapons do **not** fire (no AI crew), so the platoon has to decide what the tank is worth.
- The squad leader **may** take the commander's hatch, which takes them off squad leadership while aboard. The UI warns the squad.
- **Bailing out:** when the tank is disabled, crew bail out as Moebian Troopers (or their current tier).

### 10.5 Tank Logistics
- Battle cannon shells and heavy bolter ammo **must be resupplied** from a depot or by a crate team bringing a **Tank Munitions crate** (two-man or Ogryn carry).
- **Track damage** immobilises the tank. Crew must get out and repair with a tool-kit under fire.
- Losing the tank refunds nothing. It is a big swing in momentum both ways.

## 11. Platoon Commander: Tactical Command

### 11.1 The Mode
- The commander can enter **Tactical Command**, a top-down map overlay (RTS-style) that fills their screen.
- **While in Tactical Command the commander's character kneels in place and is vulnerable.** The Command Section veterans exist partly to protect them during this.
- Entering and leaving takes ~1 s. A damage indicator and audio alert warn the commander if they are hit.

### 11.2 Orders

| Order | Target | Effect |
|---|---|---|
| **Move To** | Squad / HWT | Waypoint on the squad's HUD and compass. |
| **Secure Objective** | Squad | Marks an objective. Completing it while ordered gives the "Followed Orders" Favour bonus. |
| **Hold / Dig In** | Squad / HWT | Squad gets a defence bonus (faster sandbag building, extra suppression resistance) while inside the zone. |
| **Assault** | Squad | Short-lived sprint and morale buff ("Fury of the Damned") when charging the target area. |
| **Overwatch Lane** | HWT | Draws a fire lane. The HWT gets a small accuracy bonus inside it. |
| **Escort / Screen** | Squad → HWT / Tank / Supply team | Links units. Shows escort status. |
| **Supply Priority** | Depot | Sets which requests the depot fills first (12.4). |
| **Establish Forward Depot** | Location | Needs the platoon vox-op and a secured objective (12.3). |
| **Approve Call-In** | Tank Request | Approves or denies Leman Russ requests. |
| **Ping / Mark** | Anywhere | Marks enemy positions, threats or routes for the whole platoon. |

### 11.3 Information
- **Fog of war:** the commander sees only what the platoon sees or has recently spotted (spotting decays). Hounds and auspex add intel.
- Each squad shows its strength, ammo state (Full / Low / Critical), Favour pool and whether its vox-op is alive.
- Each HWT shows its weapon type, braced or moving, and reloads left.
- Supply tasks show what is requested, where, who is carrying it and the ETA.

### 11.4 Commander Rewards
The commander earns Favour from objectives completed under their orders and a share of all platoon kills (10%), so they aren't pushed to leave command to farm kills.

## 12. Logistics and Resupply

Logistics is a main pillar, not a side activity.

### 12.1 Supply Types

| Crate | Carriers | Contents | Refills |
|---|---|---|---|
| **Small Arms Ammo** | 1 | Lasgun packs, autogun mags | Riflemen, squad vox, sidearms |
| **Grenade Crate** | 1 | Frag/Krak (Toxin if unlocked) | All grenades, Grenade Launcher |
| **Special Munitions** | 1 | Bolter mags, plasma flasks, melta canisters, promethium | Special weapons |
| **Heavy Munitions (typed)** | 2 (1 Ogryn) | Stubber belts / bolter boxes / autocannon clips / missiles / lascannon packs | One HWT weapon type per crate |
| **Medical** | 1 | Medicae charges, wound treatment | Medic, Wounded status |
| **Fortification** | 2 | Sandbags, barbed wire, brace mounts | Builds defensive positions and brace points |
| **Tank Munitions** | 2 (1 Ogryn) | Battle cannon shells + heavy bolter belts | Leman Russ |

- **Carrying slows you** (one-man crates −20%, two-man crates −40% for both carriers) and you can't use your primary weapon. Sidearm only for one-man crates, nothing for two-man crates.
- Crates are **physical objects**. They can be dropped, picked up by others, destroyed by explosives (heavy munitions crates explode) or **captured** by enemy AI.
- HWT loaders start with a fixed reload count (Section 7.1). After that, positions have to be fed by crate runs.

### 12.2 Depots
- **Rear Depot (Main Base):** infinite supply, Medical station, motor pool for the Leman Russ, spawn point. Can't be destroyed.
- **Forward Depot:** set up by the commander (12.3). Holds a **finite stock** that needs restocking from the rear by **supply convoys** (players carrying crates) or **periodic supply drops**.
- **Ammo Caches (light):** a squad leader can drop one small cache per life holding one Small Arms crate's worth.

### 12.3 Establishing a Forward Depot
1. The objective is secured.
2. The commander places the depot in Tactical Command (needs the platoon vox-op within 30 m of the commander).
3. A **Fortification crate** has to be delivered to the site to "build" it.
4. The depot comes online with a starting stock. It can be **attacked and destroyed** by the AI Director (14.4).
5. Maximum of **2 forward depots** at once, so the commander has to choose where the line is.

### 12.4 Requests and Tasks
- Squad vox-ops and HWT loaders can send **Supply Requests** (type, amount, location).
- Requests show up as **tasks** on the commander's map, at depots (diegetic board) and on the HUD of players near the depot.
- Any player who picks up the matching crate is guided to the request. Delivering earns Favour (8.1).
- The commander's **Supply Priority** sets the order of requests on the depot board.

### 12.5 Why It Matters (Design Intent)
- HWTs are only as strong as their supply line. A lascannon team with no power packs is two riflemen with a heavy, useless gun.
- The AI Director (14.4) **hunts supply lines**. Escorting convoys, choosing safe routes and placing depots well are real tactical decisions.
- **Dynamic response:** when a position calls "Critical ammo" under heavy attack, the platoon has to choose to send runners now or pull back. That choice is the game.

## 13. Spawning, Death and Reinforcement

### 13.1 Reinforcement Pool
- The platoon shares a **Reinforcement pool** (for example, 300 tickets per operation, scaling by difficulty). Each respawn costs 1, the Ogryn costs 3 and the Leman Russ costs 10 on arrival.
- The pool is topped up by completing operation phases.
- When the pool hits 0, no more respawns. The operation fails when everyone is dead or the time limit runs out.

### 13.2 Spawn Points

| Spawn | Who can use it | Conditions |
|---|---|---|
| Rear Depot | Everyone | Always |
| Forward Depot | Everyone | While the depot stands and isn't contested |
| **Rally Point (Standard Bearer's icon)** | Everyone | Icon planted and not contested. Spawn wave every 20 s. |
| **Squad Leader** | Own squad | Leader alive, not in combat (not damaged for 10 s). Spawn wave every 30 s. |

### 13.3 Respawn Choices
On respawn the player picks their role slot (locked to their squad role), spawn point, loadout within their tier and, if eligible, **Ogryn** or an open **Leman Russ** seat.

## 14. Enemies and the AI Director

### 14.1 Enemy Roster (Loyalist Imperial Forces)

| Unit | Threat | Counter |
|---|---|---|
| **Guardsman squads** | Volume infantry | Small arms, HWT suppression |
| **Sergeants / Veterans** | Squad leadership, buffs nearby AI | Priority targets |
| **Commissars** | Strong morale aura; executes fleeing troops | Kill to collapse local morale |
| **Enemy Heavy Weapons Teams** | Locks down lanes | Flank, grenades, hounds |
| **Snipers (Ratlings / Vets)** | Picks off leaders, vox-ops, tank commanders | Hounds, autocannon, smoke |
| **Sentinels** | Fast light walkers | Autocannon, krak, missile |
| **Chimeras** | APCs that drop squads | Lascannon, melta, krak |
| **Enemy Leman Russ** | Heavy armour | Lascannon, melta, coordinated krak |
| **Basilisk barrages (off-map)** | Area denial and punishment for static positions | Spread out, kill forward observers |
| **Ministorum Priests / Frateris Militia** | Zealot rushes, fanatic buff | Flamers, suppression |
| **Sisters of Battle squads** (elite event) | Power-armoured, flamers, faith buffs | Plasma, melta, Chaos Spawn |
| **Space Marine kill team** (rare climax event) | Extreme threat | Everything the platoon has |

### 14.2 AI Squad Behaviour
- Enemy AI works in fire teams with the same suppression and morale rules as players.
- It uses cover, flanks, suppresses and retreats when broken.
- Commissars stop retreats (executing fleeing troops visibly), which is worth showing to players.

### 14.3 The AI Director
A Left-4-Dead-style pacing system scaled up to platoon size:
- Tracks **platoon stress**: casualties, ammo levels, reinforcement pool and objective progress.
- Varies intensity: build-up, peak assault, relief.
- Spends a **threat budget** on spawns, counter-attacks, artillery, vehicles and elite events.
- **Attention:** spreads pressure across squads so that no single squad is starved of action or permanently overrun.

### 14.4 Director Tactics Against Logistics
- **Raiding parties** target supply convoys and isolated carriers.
- **Depot assaults** on forward depots that are low on defenders.
- **Infiltrators** go after HWT positions and the commander when in Tactical Command.
- **Barrages** target positions that haven't moved for a long time (anti-turtling).
- The Director **telegraphs** major attacks (vox intercepts, flares, engine noise) so the platoon has a chance to respond.

## 15. Missions and Maps

### 15.1 Map Scale
- Around 2×2 km to 3×3 km per map, with dense urban, hive-industrial, trench and rural/agri sections.
- Built in **sectors** that unlock in phase order so 45 players stay in a coherent front.

### 15.2 Operation Structure (example: "The Fall of Hive Varrus Secundus")
1. **Breach:** take the outer defence line (trench assault). Set up the first forward depot.
2. **Push:** advance through hab-blocks (urban CQB; flamers and Ogryn shine).
3. **Hold:** survive a combined loyalist counter-attack with armour (HWTs and logistics are tested).
4. **Desecrate:** the Standard Bearer's icon has to be planted at a Shrine of the Emperor and defended for X minutes.
5. **Extraction or Final Stand:** depends on the operation.

### 15.3 Objective Types
Capture/Hold, Destroy (artillery, vox-towers, ammo dumps), Desecrate (icon plant), Escort (sorcerer, plague cauldron), Sabotage (plant charges), Survive (wave defence), Assassinate (Commissar-General, Canoness).

### 15.4 Difficulty
| Level | Name | Changes |
|---|---|---|
| 1 | Rabble | Generous pools, low enemy accuracy |
| 2 | Regiment | Baseline |
| 3 | Crusade | Higher threat budget, more elites |
| 4 | Purgatus | Low pool, Space Marine events, harsher logistics (smaller crate capacity) |

## 16. Communication
- **Proximity voice** in the world (enemies can't hear it; it's PvE, but it adds atmosphere).
- **Squad channel** (all squad members).
- **Command channel:** commander, squad leaders and HWT gunners. Squad leaders are on it **only through their squad vox-op** (if the vox-op is dead, the leader loses the channel until someone picks up the vox-set). HWT gunners are on it while within 40 m of any vox-op or the commander.
- **Ping wheel and contextual callouts** for players without mics.
- Vox audio is filtered and degraded, and gets worse with range and enemy jamming events.

## 17. UI and HUD
- **Minimal HUD by default:** compass with waypoints, ammo count by magazine (not exact rounds), grenade and gear icons, Favour bar, squad member status.
- **Brace indicator:** for heavy weapons, the crosshair only appears when braced. Valid brace surfaces glow on approach.
- **Supply task tracker:** carried crate destination and nearby requests.
- **Tier display:** a visible mark on your character and on squadmates' nameplates.
- **Tactical Command UI:** clean, tactile map with unit markers, order drag-and-drop and a supply task panel.

## 18. Art and Audio Direction
- **Art:** gritty grimdark realism. Muted palettes (greys and rust) with sickly green and yellow corruption accents. Imperial structures in gothic stone and brass. Corruption spreads across the map visually as the platoon advances (rot, fungal growth and flies on captured sectors).
- **Audio:** heavy, mechanical weapons; deep thumps for the autocannon and battle cannon; the lascannon's charge whine as a warning cue. Plague call-ins are introduced by droning flies and wet growls. Loyalist hymns and vox chatter give enemy AI a personality.

## 19. Meta-Progression
Unlocks outside a match, kept **horizontal** so 45-player co-op stays balanced:
- **Toxin Grenades** (unlocked at Regiment Rank X; also need in-match Blessed tier). This covers "unlock later".
- Alternative weapon patterns (e.g., Accatran-pattern lasgun, Mars-pattern autocannon) with sidegrade stats.
- Cosmetics: mutation choices, tattered regalia, icons, helmet variants.
- Role mastery badges and titles.
- **No paid power.** Any monetisation is cosmetic only.

## 20. Technical Considerations
- **Engine:** Unreal Engine 5 recommended (proven for large-scale shooters, strong networking base, World Partition for large maps).
- **Networking:** dedicated, server-authoritative servers. 45 players plus 150–300 AI agents needs:
  - Network relevancy and replication LOD by distance.
  - AI LOD: full behaviour near players, simplified "abstract combat" in distant sectors.
  - Plague zombies simulated as lightweight crowd agents (Mass Entity / ECS-style).
- **Target performance:** 60 FPS on recommended PC specs; 30 Hz server tick minimum, 60 Hz target.
- **Physics:** crates and backblast are physical. Destruction is limited to authored destructible cover to keep replication costs down.
- **Bots:** AI backfill for empty player slots (see Risks) using the same role logic as the commander's orders.

## 21. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| **Filling 45-player lobbies** | Long queues and dead matches | AI bot backfill for any slot except commander (and a commander AI fallback that issues basic orders); drop-in/drop-out; smaller 25-player "Detachment" mode for low populations. |
| **Logistics feels like chores** | Players skip it and positions starve | Favour for deliveries, Ogryn carry synergy, short and readable routes, a dramatic Director that makes convoys tense, crates delivered to a request highlighted as a team "win". |
| **Commander quality varies** | Bad commander ruins a 45-player match | Squad-level autonomy (squad leaders can set their own objectives), commander vote-kick/swap, onboarding tutorial for the role. |
| **Tank pulls too many players** | Infantry hollowed out | Seats fill from the respawn queue first; tank can run partially crewed; one tank cap. |
| **Snowballing Favour** | Late game trivial or new joiners useless | Death progress penalty, half Favour from AI allies, call-in cooldowns, Director scales threat with platoon power. |
| **Performance (many AI)** | Low framerate and desync | AI LOD, crowd systems for zombies, sector-based simulation. |
| **IP licensing** | Cannot ship commercially | Pursue a license from Games Workshop early; keep content data-driven so it can be reskinned. |

## 22. Open Questions
1. Should Favour tiers persist across **multiple operations** in a campaign, or reset each match? (Current design: reset each match; meta unlocks persist.)
2. Should the **commander be able to fight** normally, or should leaving Tactical Command have a cooldown?
3. Leman Russ crewing: is the respawn-queue-first rule enough, or should the calling squad have to provide crew?
4. Should other Chaos gods be in scope (e.g., Khorne berserker call-ins), or is the platoon locked to Nurgle for a consistent identity?
5. Should **any** player be able to pick up and fire a dropped heavy weapon, or only HWT gunners?
6. Persistent campaign map (Foxhole-style world war across many sessions) as a post-launch mode?

## 23. Roadmap

| Phase | Goal | Content |
|---|---|---|
| **Prototype** (3–4 months) | Prove fire-and-bracing and the logistics loop | 1 squad + 1 HWT + depot, greybox map, basic AI Guardsmen |
| **Vertical Slice** (6–8 months) | Full platoon structure at 45 players | All roles, Tactical Command, Favour tiers, 2 call-ins, 1 operation |
| **Alpha** | Feature complete | Leman Russ, Ogryn, all call-ins, full enemy roster, AI Director, bot backfill |
| **Beta** | Content and scale | 3–4 operations, difficulty tiers, meta-progression, stress tests at 45 players |
| **Launch** | — | 4 operations, 2 environments, cosmetics |

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

| Role | Primary | Grenades |
|---|---|---|
| Cultist | 5 mags autogun | 1 Frag |
| Moebian Trooper | 6 lasgun packs | 1 Frag, 1 Krak |
| Moebian Veteran | 8 lasgun packs | 2 Frag, 1 Krak |
| Blessed | 8 lasgun packs | 2 Frag, 1 Krak, 1 Toxin* |
| Special Weapons | Per weapon (e.g., Plasma 6 flasks, Melta 4 canisters, Flamer 2 tanks) | 1 Frag |
| HWT Loader | Weapon reloads per Section 7.1 | 1 Frag |

\* Toxin only if unlocked through meta-progression.

### C. Call-In Costs (Squad Favour)

| Call-in | Cost | Cooldown |
|---|---|---|
| Plague Zombie Horde | 15 | 120 s |
| Plague Hounds | 25 | 180 s |
| Chaos Spawn | 40 | 300 s |
| Leman Russ | 100 + approval | 1 active |

### D. Carry Speeds

| Load | Speed modifier |
|---|---|
| Unencumbered | 100% |
| HWT gunner with weapon (unbraced) | 75% |
| One-man crate | 80% |
| Two-man crate (each carrier) | 60% |
| Ogryn with two-man crate | 100% |
| Ogryn with two one-man crates | 90% |
