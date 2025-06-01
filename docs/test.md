````markdown
---
title: Home
---

# ComputerCraft Utilities

Welcome to the documentation site for **ComputerCraft Utilities**. Here you’ll find:

- Reusable libraries (under **Library**)
- Example applications (under **Apps**)

Use the sidebar to navigate between modules and apps.

---

## Overview

This project contains:

- **lib/**: Lua modules that can be `require()`-d in ComputerCraft.  
  - `logger.lua` – A simple logger with levels (`trace`, `debug`, `info`, `warn`, `error`, `fatal`).  
  - `blitutil.lua` – A Blit writer for rendering `{&<hex>}` color codes on term or monitor.  
  - `clocktime.lua` – Utilities for sending a nighttime chat message via a `chatBox` peripheral.

- **apps/**: Stand-alone ComputerCraft scripts that demonstrate or use the libraries.  
  - `nightAnnouncer.lua` – Sends “Night Time has Arisen” at 19:00 in-game.  
  - `chatDemo.lua` – Example of sending a formatted message to chat using `blitutil` and `logger`.

---

## Getting Started

1. **Clone or download** this repository.  
2. **Copy** the contents of `lib/` into your ComputerCraft “APIs” folder (e.g. `/rom/apis/`).  
3. **Copy** any script from `apps/` into a ComputerCraft computer (e.g. `/scripts/`).  
4. In your CC Lua programs, you can now:
   ```lua
   local logger   = require("logger")
   local blitutil = require("blitutil")
   local clocktime = require("clocktime")
````

5. To run one of the example apps, simply do:

   ```lua
   shell.run("nightAnnouncer.lua")
   ```

---

## Navigation

Use the sidebar on the left to jump to:

* **Library**

  * [Logger](lib/logger.md)
  * [BlitUtil](lib/blitutil.md)
  * [ClockTime](lib/clocktime.md)
* **Apps**

  * [Night Announcer](apps/nightAnnouncer.md)
  * [Chat Demo](apps/chatDemo.md)

Enjoy exploring the modules and samples!
