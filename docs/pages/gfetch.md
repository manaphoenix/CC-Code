---
layout: codepage
title: GFetch
tags: [Application, Utility, Downloader, GitHub]
description: >
  A powerful file downloader for ComputerCraft that fetches files from GitHub repositories,
  with support for batch downloads, aliases, and configuration files.
permalink: /pages/gfetch.html
overview: >
  GFetch is a command-line utility for downloading files from GitHub repositories.
  It supports single file downloads, batch processing with .gfetch files, and features
  like aliases for frequently used repositories and configurable download directories.
installation: "manaphoenix/CC-Code/main/apps/gfetch.lua"
basic_usage_description: >
  GFetch can be used to download individual files or process batch files containing
  multiple download instructions. It supports GitHub's API and handles authentication
  through the standard GitHub token mechanism if needed.
basic_usage_language: bash
basic_usage: |
  # Download a single file
  gfetch owner/repo/branch/path/to/file [output_path]

  # Process a batch file
  gfetch --batch path/to/.gfetch

  # Create an alias for a repository
  gfetch --alias add myalias owner/repo/branch

  # Use an alias
  gfetch myalias/path/to/file

examples:
  - title: "Basic File Download"
    language: bash
    code: |
      # Download a file
      gfetch manaphoenix/CC-Code/main/apps/gfetch.lua gfetch.lua

      # Download to default filename
      gfetch manaphoenix/CC-Code/main/lib/logger.lua

  - title: "Batch Processing"
    language: bash
    code: |
      # Process a local .gfetch file
      gfetch --batch my_files.gfetch

      # Process a remote .gfetch file
      gfetch --batch https://example.com/files.gfetch

  - title: "Alias Management"
    language: bash
    code: |
      # Add an alias
      gfetch --alias add mylib manaphoenix/CC-Code/main

      # Use the alias
      gfetch mylib/apps/gfetch.lua

      # Remove the alias
      gfetch --alias remove mylib

  - title: "Configuration Example"
    code: |
      -- Default config location: /.gfetch.conf or /config/.gfetch.conf
      {
          gfetch_dir = "downloads",  -- Directory to look for .gfetch files
          aliases = {
              mylib = "owner/repo/branch"
          }
      }

  - title: ".gfetch File Format"
    code: |
      # owner/repo/branch

      -- Comments start with --

      -- Relative to the base repo
      ./path/to/file1.lua

      -- With custom output path
      ./lib/logger.lua /lib/logger.lua

      -- Absolute path (overrides base repo)
      otheruser/otherrepo/main/file.txt /data/file.txt

advanced:
  - title: "Creating a Self-Contained Installer"
    code: |
      -- install.lua
      local gf = http.get("https://raw.githubusercontent.com/manaphoenix/CC-Code/main/apps/gfetch.lua")
      if not gf then error("Failed to download gfetch") end

      local f = fs.open("gfetch", "w")
      f.write(gf.readAll())
      f.close()

      print("Installing required files...")
      shell.run("gfetch --batch https://example.com/your-project.gfetch")

      print("Installation complete!")

  - title: "Troubleshooting: Invalid .gfetch Format"
    code: |
      -- Correct format:
      # owner/repo/branch
      ./relative/path.txt
      ./src/file.lua /destination/file.lua
      other/repo/main/file.txt /output/file.txt
---
