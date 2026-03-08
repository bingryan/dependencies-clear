# Dependencies Clear (dclear)

A tool to clean up project dependency directories and free up disk space.

## Features

- 🔍 Automatically scan various dependency directories (node_modules, venv, target, etc.)
- 📊 Display size of each directory, sorted by size
- 👀 **Dry-run mode**: Preview what will be deleted without actually deleting
- 📏 **Size threshold**: Only process directories larger than specified size
- 📁 **Configurable depth**: Adjust scan depth for deeply nested projects
- 🔒 **Safe confirmation**: Interactive confirmation to prevent accidental deletion
- 🌈 Colorful output, clear and readable
- 💻 **Cross-platform**: Works on macOS and Linux

## Supported Directory Types

| Type | Directories |
|------|-------------|
| Node.js | `node_modules`, `.next`, `.nuxt`, `.turbo`, `storybook-static`, `coverage` |
| Python | `.venv`, `venv`, `env`, `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`, `.tox` |
| Rust | `target` |
| Tauri | `src-tauri/target`, `src-tauri/gen`, `src-tauri/WixTools` |
| Java/Kotlin | `build`, `.gradle` |
| Go | `bin`, `vendor` |
| .NET | `bin`, `obj` |
| General | `dist`, `dist-ssr`, `out`, `.cache`, `.parcel-cache` |

## Installation

```shell
./install.sh
```

This will copy the `dclear` script to `/usr/local/bin` or `/usr/bin`.

## Usage

### Basic Usage

```shell
dclear                    # Scan current directory with interactive confirmation
dclear ~/projects         # Scan specified directory
```

### Advanced Options

```shell
dclear -h                 # Show help
dclear -d                 # Dry-run mode, only preview
dclear -s 100             # Only process directories larger than 100MB
dclear -y                 # Auto confirm without interaction
dclear -s 50 -y           # Auto delete dependency directories larger than 50MB
dclear ~/code -d -s 100   # Preview directories larger than 100MB in ~/code
dclear -m 7 ~/projects    # Scan up to 7 levels deep (default: 5)
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-d, --dry-run` | Preview mode, only show directories to be deleted |
| `-y, --yes` | Auto confirm without interaction |
| `-s N, --size N` | Only process directories larger than N MB |
| `-m N, --maxdepth N` | Maximum directory depth to scan (default: 5) |
| `--no-parallel` | Disable parallel size calculation |

## Example Output

```
Scan directory: /Users/xxx/projects
Size threshold: 0MB
Max depth: 5

🔍 Scanning for dependency directories...
📊 Calculating directory sizes...

============================================
           Directories to Clean
============================================
Size         Path
--------------------------------------------
2.3GB        /Users/xxx/projects/app1/node_modules
856.2MB      /Users/xxx/projects/app2/target
324.5MB      /Users/xxx/projects/app3/.venv
--------------------------------------------
3.5GB        Total
============================================

Confirm deletion of all directories above? [y/N]: y

🗑️  Deleting...
✓ 2.3GB - /Users/xxx/projects/app1/node_modules
✓ 856.2MB - /Users/xxx/projects/app2/target
✓ 324.5MB - /Users/xxx/projects/app3/.venv

============================================
Space freed: 3.5GB
Successfully deleted: 3 directories
============================================
```

## Scan Depth Explained

The script uses `-maxdepth` to control how deep it scans. The default is **5 levels**.

```
Level 1: ~/work/
Level 2: ~/work/company-a/
Level 3: ~/work/company-a/project-1/
Level 4: ~/work/company-a/project-1/frontend/
Level 5: ~/work/company-a/project-1/frontend/node_modules/  ← detected with default
Level 6: (deeper nesting)
Level 7: ~/work/company/team/product/web/app/node_modules/  ← use -m 7
```

**When to increase depth:**
```shell
# Your projects are deeply nested
dclear -m 7 ~/work

# Only scan immediate subdirectories
dclear -m 2 ~/projects
```

## Safety Tips

- **Always use `-d` first**: Preview what will be deleted before actually deleting
- **Interactive confirmation**: Required by default to prevent accidental deletion
- **Nested directories skipped**: Automatically skips nested dependency directories (e.g., node_modules inside node_modules)
- **Size threshold**: Use `-s` to avoid deleting small directories

## Platform Compatibility

- **macOS**: Fully supported (uses `du -sk` for compatibility)
- **Linux**: Fully supported
- **bash 3.2+**: Compatible with older bash versions

## License

MIT
