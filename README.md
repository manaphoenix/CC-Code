# CC-Code Repository

A repository for all the code developed for **ComputerCraft / CC:Tweaked**, including startup scripts, libraries, and apps for easier setup, theming, and management.

---

## Installation

You can install CC-Code on a new computer using the installer:

```lua
wget run https://raw.githubusercontent.com/manaphoenix/CC-Code/main/installer.lua
```

This will automatically download:

* All `startup/` scripts
* `lib/theme_manager.lua`
* `themes/default.lua`

---

## Startup System

The modular startup scripts handle:

* Folder creation (`apps/`, `assets/`, `config/`, `data/`, `lib/`, `logs/`, `startup/`, `tmp/`)
* Temporary folder cleanup (`tmp/`)
* Default ComputerCraft settings (MOTD, shell path, etc.)
* Automatic peripheral management (`components` global)
* Aliases for all Lua scripts in `apps/`

All startup options are stored in `config/startup.cfg`.

---

## Theme Manager

`lib/theme_manager.lua` allows easy management of color themes:

* Apply themes to the terminal or monitors independently
* List installed themes:

  ```lua
  ThemeManager.listThemes()
  ```
* Get theme metadata (name, author, version, description)
* Download themes from raw URLs or GitHub

---

## Folder Structure

```
CC-Code/
├─ apps/         # User-run programs
├─ assets/       # Non-code resources
├─ config/       # Startup config file
├─ data/         # Persistent runtime state
├─ lib/          # Libraries (theme_manager.lua)
├─ logs/         # Logs (optional)
├─ startup/      # Modular startup scripts
├─ themes/       # Installed themes
├─ tmp/          # Temporary files
└─ tasks/        # Task definitions (future)
```

---

## Usage

* **Apply a theme programmatically:**

  ```lua
  local ThemeManager = dofile("lib/theme_manager.lua")
  ThemeManager.applyTheme(term, "default")
  ```

---

## Contributing

* Add new themes under `themes/` with `colors` and `meta` tables.
* Pull requests for new apps or improvements are welcome.

---

## License

CC0 / Public Domain

