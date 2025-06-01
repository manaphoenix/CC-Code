# CC-Code Repository

A repository for all the code developed for ComputerCraft, including addons and forks.

---

## gfetch app

A simple Git fetch wrapper for retrieving raw Lua files from GitHub repositories.

### Installation

```bash
wget https://raw.githubusercontent.com/manaphoenix/CC-Code/refs/heads/main/apps/gfetch.lua apps/gfetch.lua
```

### Usage

```bash
gfetch Owner/Repo/[Path/]File.lua [Path]/File
```

* **Owner/Repo/\[Path/]File.lua** — The GitHub repository owner, repo, and path to the raw file.
* **\[Path]/File** — (Optional) The filename or path where you want to save the fetched file locally.

### Example

```bash
gfetch manaphoenix/CC-Code/lib/linq.lua lib/linq.lua
```

---

Visit the project page: [CC-Code](https://manaphoenix.github.io/CC-Code/)
