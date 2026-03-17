# ?? Modular 2D Combat System Template (Godot 4.x)

A lightweight, scalable, and professional 2D combat system foundation. Designed for indie developers who need a "Clean Code" structure for Action, Platformer, or Hack & Slash games.

## ?? Key Features
- **Data-Driven Weapons:** Create weapon variations using `Resource` files.
- **Input Buffering:** Smooth combo transitions using an attack window system.
- **Inheritance-Based Enemies:** Easily create new enemy types using the `Enemy_Base` class.
- **Flexible Player Control:** Toggle gravity, movement, and jumps for cutscenes or special states.

---

## ??? Deep Dive: Variable Guide

### 1. Player & Movement (`player.gd`)
- `max_speed_val`: The standard walking speed of the player.
- `attack_max_speed_val`: Defines the player's movement speed while performing an attack.
- `attack_dash`: A simple offset/dash applied during specific attack frames. 
  - *Note:* This is triggered via the `attack_dash_offset` function, which is called directly from the AnimationPlayer.
- **State Toggles:**
  - `can_move`: Controls left/right movement.
  - `apply_grav`: Toggles gravity. If disabled, the player will float (useful for specific attack states or cutscenes).
  - `can_jump`: Toggles the ability to jump.

### 2. Animation Logic (`player_animation.gd`)
- `attack_animations` (Array[String]): List of animation names for your attack combo sequence.
- `damage_animations` (Array[String]): List of animation names played when the player takes damage.
- `my_node`: This is the target node containing your Sprites and visual elements. It handles the flipping/scaling logic based on facing direction.

### 3. Combat System (`combat_system.gd`)
- `attack_in_window_times`: Tracks how many times the attack button was pressed during an active attack.
  - *Reliability:* It is hard-capped by `current_weapon.max_attacks`, ensuring no accidental overflows.
- **Signals:**
  - `signal attackd(position)`: Emitted by the Player script. It passes the hit position, making it perfect for spawning blood particles, sparks, or screen shake effects. (Note: This is separate from the core combat signal).

### 4. Enemy System (`Enemy_Base.gd` & `enemy.gd`)
This template uses a clean **Inheritance System**:
- `Enemy_Base`: The parent class containing core logic.
- Individual Enemies (like `enemy.gd`) inherit from this base.
- **Independent Variables:** Each enemy instance has its own `attack_damage`, `attack_force`, and `damage_time`. Changing these values on one enemy type won't affect others, allowing for diverse enemy rosters.

---

## ?? How to Install
1. Copy the `Scripts` and `Resources` folders into your Godot project.
2. Attach the `CombatSystem` node to your Player scene.
3. Assign a `weapon_resource.tres` to the CombatSystem in the Inspector.
4. Set up your AnimationPlayer keys to call `attack_dash_offset` where needed.

---

## ?? PRO VERSION (Coming Soon!)
- Directional Attacks (Up/Down/Mid-air).
- Intelligent AI (Flying enemies & Pathfinding).
- Charged Attacks (Hold & Release mechanics).
- Pre-made Visual VFX & Camera Shake.

---
**Developed(OLDman)** NO AI OR CODING TOOLS

Code cleaner. Make games.*