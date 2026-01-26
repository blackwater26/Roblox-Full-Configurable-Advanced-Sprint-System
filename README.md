# Sprint System – Modular & Event-Driven

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![Lua](https://img.shields.io/badge/Language-Lua-blueviolet.svg)](https://www.lua.org/)
[![GitHub stars](https://img.shields.io/github/stars/blackwater26/Roblox-Full-Configurable-Advanced-Sprint-System?style=social)](https://github.com/blackwater26/Roblox-Full-Configurable-Advanced-Sprint-System/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/blackwater26/Roblox-Full-Configurable-Advanced-Sprint-System?style=social)](https://github.com/blackwater26/Roblox-Full-Configurable-Advanced-Sprint-System/network/members)
[![Roblox](https://img.shields.io/badge/Made%20for-Roblox-red.svg?logo=roblox&logoColor=white)](https://www.roblox.com/)

This sprint system is built with scalability, clarity, and production use in mind.
Rather than being a simple input-to-speed toggle, the system is designed as a decoupled architecture
where input, state, and behavior are isolated and communicate through signals.

The goal is to allow sprinting to act as a core gameplay mechanic that can safely evolve over time
without requiring rewrites to existing logic.

---

# Why Github?

I prioritize privacy and data sovereignty. Unlike platforms that require extensive personal identification and KYC (Know Your Customer) procedures, GitHub allows me to share my work while maintaining my digital privacy. I believe that professional software development should be based on code quality and transparency, not on the collection of sensitive personal documents. By using GitHub, I ensure that my tools remain accessible, open-source, and free from unnecessary bureaucratic barriers.

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


# 🏃 Sprint System – Purpose & Architecture Overview

This sprint system is designed to be **modular, secure, and scalable**, allowing developers to integrate advanced sprint mechanics into their Roblox games without worrying about exploits or messy code.

---

## Core Goals

1. **Separation of Concerns**  
   - Input handling, movement logic, and configuration are clearly separated.  
   - Client handles input and intent, server handles authoritative movement.

2. **Security & Server Authority**  
   - Movement changes are applied only on the server to prevent speed hacks.  
   - Ensures all players see consistent sprint behavior.

3. **Modularity & Scalability**  
   - Each module has a specific responsibility.  
   - Easy to extend or replace functionality (stamina, sprint effects, custom triggers).  
   - Configurable through a single central module.

4. **Responsive Input Handling**  
   - Player input is captured immediately on the client.  
   - Signals are sent to the server, keeping gameplay smooth without polling.  

5. **Clean & Maintainable Code**  
   - Code is structured for readability and reusability.  
   - Minimal coupling between modules makes upgrades or fixes faster.  

6. **Customizability**  
   - Developers can easily tune sprint speed, stamina drain, recovery rates, and other parameters without touching core logic.  
   - Audio and visual feedback can be added without changing the movement logic.

7. **Robust Player Experience**  
   - Resets player properties on respawn to ensure clean behavior.  
   - Supports multiple players simultaneously with consistent mechanics.

---

## Why This Architecture Matters

- Promotes **professional development practices** on Roblox.  
- Ensures **player trust**, as speed changes cannot be exploited.  
- Simplifies **future updates and feature expansion**.  
- Provides a **foundation** for adding advanced features like sprint animations, stamina UI, or event-driven effects.

---

📬 Contact & Work Inquiries
---

If you are interested in using, customizing, or extending this sprint
system or other core gameplay mechanics for your project, feel free to
reach out.

I am available for:
- Custom core mechanic development
- System integration & optimization
- Gameplay and movement mechanics

Discord:
➡️ blackw_26

Please include a brief description of your project when contacting.

---

# Roadmap 🗺️


### Released ✅

v1.0.0 – Initial Release

v1.1.0 – UI Scalability Update

### In Progress 🚧

Break for a day!

### Upcoming 🔜

v1.1.5 – Audio Feedback Update |
Listenable audio events & customization

v1.2.0 – Visual Effects Update |
Event-driven triggers for VFX

v1.4.0 – UI Customization Update |
Expanding options of UI Customization

v1.5.0 – Mobil Support Update |
Integrating Mobil Support to our System

v1.6.0 – Audio & VFX Update |
Expanding Customization for Audio & VFX

---

## 📌 Versioning Policy

I use a tailored versioning system to track the evolution of this project clearly.

This project follows a custom versioning logic to reflect the impact and nature of each update:

  - 0.0.5 – Minor Tweaks: Small fixes, "rounding off" edges, and minor code refinements.

  - 0.1.0 – Medium Contribution: Significant updates that add new functionality or noticeable improvements.

  - 0.x.0 – Major Impact: Changes that significantly evolve the design or user experience (e.g., moving beyond the initial release design) without altering the core architecture.

  - 1.0.0+ – Core & Architecture: Major milestones, complete system overhauls, or fundamental architectural changes.

---
