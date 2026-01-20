# Sprint System – Modular & Event-Driven

This sprint system is built with scalability, clarity, and production use in mind.
Rather than being a simple input-to-speed toggle, the system is designed as a decoupled architecture
where input, state, and behavior are isolated and communicate through signals.

The goal is to allow sprinting to act as a core gameplay mechanic that can safely evolve over time
without requiring rewrites to existing logic.

---

## Architecture Overview

The system is split into clear responsibilities:

- Input Layer  
  Handles raw player input and converts it into intent (e.g. sprint start / sprint end).
  This layer does not modify movement or player state directly.

- Sprint State Controller  
  Owns the authoritative sprint state.
  It decides when sprinting is active and exposes state changes through signals.

- Behavior / Consumers  
  Movement, stamina, UI, camera effects, animations, or modifiers subscribe to sprint state
  changes without tight coupling.

All communication is handled through signals, making the system predictable, testable,
and easy to extend.

---

## Configuration

The system includes a dedicated configuration layer (Configure) to avoid hardcoded values.

Through configuration you can:

- Adjust sprint behavior without touching core logic
- Enable or disable modifiers
- Tune values for different characters or game modes
- Reuse the same system across multiple projects with different parameters

This keeps iteration fast and reduces the risk of regressions.

---

## Design Goals

- Fully modular and reusable
- Event-driven with no hidden dependencies
- Easy to extend with stamina, buffs, debuffs, or abilities
- Safe for large-scale or narrative-driven projects
- Clean separation of concerns
- Production-ready structure suitable for long-term maintenance

---

## Intended Use

This system is designed to be:

- Integrated into larger gameplay frameworks
- Used as a foundation for complex movement systems
- Studied as a reference for modular Luau architecture

It is not a one-off script, but a reusable system meant to scale with project complexity.

---

## License

This project is licensed under the Mozilla Public License 2.0 (MPL 2.0).

You are free to use and integrate this system into your projects, provided that attribution
is preserved and modifications to the original source files remain open under the same license.

---

# 🏃 Sprint System – Setup & Architecture Guide

This sprint system is built with a layered architecture that separates
input handling (Client) and movement authority (Server) for security,
scalability, and clean code organization.

---

## 📁 1. ReplicatedStorage (Shared Modules)

Files inside ReplicatedStorage are accessible by both the Server and
Client. These modules do not run on their own and must be required
by other scripts.

Structure:

```text
ReplicatedStorage
└── Modules
 ├── CalculatingOfWSModuleScript.luau
 │ - ModuleScript
 │ - Responsible for all movement speed calculations
 │ (walking speed, sprint speed, smoothing, stamina logic).
 │
 ├── FreshBodyModuleScript.luau
 │ - ModuleScript
 │ - Resets character-related properties when the player dies
 │ or respawns to ensure a clean state.
 │
 └── InputModuleScript.luau
```

- ModuleScript
- Handles input logic (Shift, Ctrl, etc.)
- Fires sprint-related signals without directly changing speed.

```text
ReplicatedStorage
└── ConfigModule.luau
```

- ModuleScript
- Centralized configuration file.
- Controls values such as sprint speed, stamina limits,
  drain/recovery rates, and tuning variables.
- Allows global behavior changes without touching core logic.

---

## 🛡️ 2. ServerScriptService (Server-Side Logic)

Scripts here run only on the server. This layer is responsible for
authoritative changes to player movement to prevent exploits
and desynchronization.

Structure:

```text
ServerScriptService
└── Sprint System
 └── SprintServer.luau
```

- Script (RunContext: Server)
- Listens for sprint requests coming from the client.
- Applies the actual WalkSpeed changes on the server.
- Ensures all players see consistent movement behavior.

Why Server-Side?

- Prevents client-side speed hacking.
- Ensures replication consistency.
- Keeps movement logic authoritative and secure.

---

## 💻 3. StarterPlayerScripts (Client-Side Logic)

Scripts placed here are cloned to each player's client when they join
the game.

Structure:

```text
StarterPlayer
└── StarterPlayerScripts
 └── main.luau
```

- LocalScript
- Acts as the client-side controller.
- Listens to player input (e.g. Shift key).
- Communicates sprint intent to the server.
- Does NOT directly modify movement speed.

Why Client-Side?

- Instantly captures user input.
- Keeps input handling responsive.
- Avoids unnecessary server polling.

---

### 🛠️ Installation Summary

| File / Folder Name | Type         | Location             |
| ------------------ | ------------ | -------------------- |
| main.luau          | LocalScript  | StarterPlayerScripts |
| SprintServer.luau  | Script       | ServerScriptService  |
| Modules (Folder)   | Folder       | ReplicatedStorage    |
| ConfigModule.luau  | ModuleScript | ReplicatedStorage    |

---

### ✅ Design Goals

- Fully modular architecture
- Clear separation of responsibilities
- Server-authoritative movement
- Easy configuration via a single config module
- Scalable for large or narrative-driven projects
