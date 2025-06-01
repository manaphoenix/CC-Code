# CC-Code Repository

A repository for all the code developed for ComputerCraft, including addons and forks.

---

## gfetch App

A powerful GitHub fetch utility for ComputerCraft that supports aliases, batch downloads, automatic base64 decoding, and tab completions.

### 🔧 Installation

```bash
wget https://raw.githubusercontent.com/manaphoenix/CC-Code/refs/heads/main/apps/gfetch.lua gfetch.lua
```

---

## 📦 Usage

### Basic File Download

```bash
gfetch owner/repo/branch/path/to/file.lua [output_path]
```

* **owner/repo/branch/path** — Required. Full path to the GitHub file.
* **output\_path** — Optional. Defaults to saving at the same relative path locally.

### Using Aliases

You can define repository aliases in `.gfetch.conf`:

```lua
{
  gfetch_dir = "config",
  aliases = {
    cc = "manaphoenix/CC-Code/main"
  }
}
```

Then fetch files like so:

```bash
gfetch cc/lib/linq.lua
```

### Batch Mode

Use a `.gfetch` batch file to define multiple files to download:

```gfetch
# manaphoenix/CC-Code/main
./lib/linq.lua lib/linq.lua
./utils/parallelActions.lua utils/parallelActions.lua
```

Run with:

```bash
gfetch --batch myfiles.gfetch
```

Remote URLs for `.gfetch` files are also supported.

---

### Alias Management

```bash
gfetch --alias add myalias owner/repo/branch
gfetch --alias remove myalias
```

Adds or removes entries from your `.gfetch.conf`.

---

## 🧠 Features

* ✅ Raw GitHub file fetching via GitHub API
* ✅ Aliases for reusable repo+branch targets
* ✅ `.gfetch` batch files for grouped installs
* ✅ Remote or local batch file support
* ✅ Auto base64 decoding of file contents
* ✅ Smart path resolution & completions support

Completions work in the ComputerCraft shell when `gfetch` is run directly.

---

### 🔗 Example

```bash
gfetch manaphoenix/CC-Code/main/lib/linq.lua lib/linq.lua
```

---

Visit the project page: [CC-Code](https://manaphoenix.github.io/CC-Code/)
