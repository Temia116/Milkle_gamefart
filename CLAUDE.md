# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.4 game project called "milk ball s" - a Peggle-style physics ball game. The game involves launching balls from a cannon to hit pegs and earn points. The goal is to hit all orange pegs to complete the level.

## Development Commands

### Running the Game
- Open the project in Godot Engine 4.4
- Press F5 or click "Play" to run the main scene
- Main scene: `Main.tscn`

### Building/Exporting
- Use Godot's Project -> Export menu
- Web export preset is configured to export to `../Builds/Temia/index.html`
- Export presets are defined in `export_presets.cfg`

## Code Architecture

### Core Game Components

**Main Scene Structure (`Main.tscn`)**
- Main Node2D with `game.gd` script (legacy scoring)
- GameManager Node with `GameManager.gd` script (primary game logic)
- Launcher (cannon) instance
- Multiple Peg instances positioned throughout the scene
- StaticBody2D walls for ball collision boundaries

**Key Scripts:**

**GameManager.gd** - Primary game state management
- Handles scoring system with signals
- Tracks orange peg count for win condition
- Manages peg destruction events
- Emits `score_changed` and `orange_peg_hit` signals

**ball.gd** - Physics ball behavior
- RigidBody2D with bounce physics and lifetime management
- Configurable bounce damping, max bounces, and lifetime
- Collision detection with `hit_by_ball()` method calls
- Debug logging for launch parameters

**cannon.gd** - Player input and ball launching
- Mouse-controlled aiming with angle constraints (±75°)
- Visual aim line and trajectory preview
- Ball instantiation and launch velocity calculation
- Shooting cooldown system

**peg.gd** - Target objects
- StaticBody2D pegs with orange/blue variants
- Hit detection and visual feedback animations
- Score awarding and game manager notification
- Self-destruction after being hit

### Signal System
- GameManager uses signals for loose coupling
- `score_changed(new_score: int)` for UI updates
- `orange_peg_hit()` for level progression tracking

### Physics Configuration
- Ball physics: gravity_scale=1.0, bounce=0.7, low friction
- Trajectory preview uses gravity=980 with time_step=0.02
- Ball launch speed default: 800.0 units

### Scene Organization
- Main game scene: `Main.tscn`
- Reusable components: `ball.tscn`, `cannon.tscn`, `peg.tscn`
- Game assets stored in `Game assets/` folder

## Development Notes

### Debugging
- Ball launch has extensive debug logging in `ball.gd:34-51`
- Cannon aiming shows real-time angle information in `cannon.gd:63`
- Score and peg count printed to console

### Known Issues
- Dual scoring systems exist (`game.gd` and `GameManager.gd`) - GameManager is primary
- Cannon script has alternative implementation commented out for different attachment scenarios

### Physics Tuning
- Ball bounce damping applies after 3 bounces
- Max 50 bounces before ball auto-removal
- 30-second ball lifetime as fallback cleanup