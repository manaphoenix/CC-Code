# CC-Code (Ashgard Runtime Core)

A modular ComputerCraft / CC:Tweaked ecosystem providing:

* runtime libraries
* startup system
* utilities and apps
* theming system
* experimental Ashgard architecture components

This repository is structured around a **rootfs-based deployment model**, where `rootfs/` represents the filesystem installed onto a ComputerCraft computer.

---

## Installation

Install on a new ComputerCraft computer:

```lua
wget run https://raw.githubusercontent.com/manaphoenix/CC-Code/main/installer.lua
```

This installer deploys selected components from `rootfs/` into the local filesystem.

### Installed Components

By default, the installer includes:

* startup system (`startup/`)
* core libraries (`lib/`)
* applications (`apps/`)
* themes (`themes/`)
* type definitions (`types/`)

---

## Architecture Overview

### Rootfs Model

All runtime code is stored under:

```
rootfs/
```

This represents the **source-of-truth filesystem layout** for CC:Tweaked machines.

Installed output maps to the root filesystem of the ComputerCraft computer:

```
rootfs/apps/    → /apps/
rootfs/lib/     → /lib/
rootfs/startup/ → /startup/
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
lib/
```

These include utilities for:

* CLI handling
* event systems
* data structures
* serialization
* UI helpers
* testing utilities

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
local ThemeManager = dofile("lib/theme_manager.lua")
ThemeManager.applyTheme(term, "default")
```

---

## Folder Structure

```
rootfs/
├─ apps/        # User-facing programs
├─ lib/         # Core libraries
├─ startup/     # Boot sequence scripts
├─ themes/      # UI themes
└─ types/       # Data type definitions
```

---

## Projects

Larger standalone applications are stored under:

```
projects/
```

These are self-contained systems not installed directly by default.

---

## Development

Internal tools and experiments are located in:

```
dev/
```

This includes:

* templates
* tests
* experimental code

---

## Tools

Host-side utilities (not run inside CC) are located in:

```
tools/
```

---

## Contributing

* Add runtime code under `rootfs/`
* Add reusable libraries under `lib/`
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
