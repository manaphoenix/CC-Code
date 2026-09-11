# CC-Code (Ashgard Runtime Core)

A modular ComputerCraft / CC:Tweaked ecosystem providing:

* runtime libraries
* startup system
* utilities and apps
* theming system
* experimental Ashgard architecture components

This repository is structured around a **src-based deployment model**, where `src/` represents the filesystem installed onto a ComputerCraft computer.

---

## Installation

Install on a new ComputerCraft computer:

```lua
wget run https://raw.githubusercontent.com/manaphoenix/CC-Code/main/installer.lua
```

This installer deploys selected components from `src/` into the local filesystem.

### Installed Components

By default, the installer includes:

* startup system (`startup/`)
* core libraries (`lib/core/`)
* applications (`apps/`)
* themes (`themes/`)

---

## Architecture Overview

### src/ Model

All runtime code is stored under:

```
src/
```

This represents the **source-of-truth filesystem layout** for CC:Tweaked machines.

Installed output maps to the root filesystem of the ComputerCraft computer:

```
/apps/    → /apps/sytem/
/lib/     → /lib/core/
/startup/ → /startup/
```

---

## Startup System

The startup system is a sequence of ordered scripts executed on boot.

Typical responsibilities include:

* creating required folders
* applying configuration defaults
* initializing terminal state
* setting up aliases
* preparing runtime environment

Startup behavior is modular and can be extended by adding new scripts to:

```
startup/
```

---

## Libraries

Core reusable modules are located in:

```
lib/core/
```

---

## Theme System

Themes are defined in:

```
themes/
```

Each theme provides:

* color configuration
* metadata (name, author, version)
* optional UI styling overrides

### Example usage

```lua
local ThemeManager = dofile("lib/core/theme_manager.lua")
ThemeManager.applyTheme(term, "default")
```

---

## Folder Structure

```
src/
├─ apps/        # User-facing programs & Built-in apps
├─ lib/         # Core libraries & User libraries
├─ startup/     # Boot sequence scripts
├─ themes/      # UI themes
```

---

## Contributing

* Add libraries under `lib/`
* Add applications under `apps/`
* Keep systems modular and optional

---

## Philosophy

This project follows Ashgard design principles:

* optional systems over mandatory frameworks
* capability-based design
* no global control over applications
* graceful degradation without dependencies
* explicit filesystem structure

---

## License

CC0 / Public Domain
