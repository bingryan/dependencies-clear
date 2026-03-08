# Dependencies Clear (dclear)

A tool to clean up project dependency directories, Docker resources, and free up disk space.

## Features

- 🔍 Automatically scan various dependency directories (node_modules, venv, target, etc.)
- 📊 Display size of each directory, sorted by size
- 👀 **Dry-run mode**: Preview what will be deleted without actually deleting
- 📏 **Size threshold**: Only process directories larger than specified size
- 📁 **Configurable depth**: Adjust scan depth for deeply nested projects
- 🐳 **Docker cleanup**: Clean images, containers, volumes, and build cache
- 🔒 **Safe confirmation**: Interactive confirmation to prevent accidental deletion
- 🌈 Colorful output, clear and readable
- 💻 **Cross-platform**: Works on macOS and Linux

## Supported Directory Types

### Project Dependencies

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

### Docker Resources

`dclear --docker` cleans the following Docker resources:

| Resource | Description | Safety |
|----------|-------------|--------|
| **Dangling Images** | Untagged intermediate images from builds | ✅ Safe |
| **Stopped Containers** | Exited containers no longer running | ✅ Safe |
| **Unused Volumes** | Volume data not attached to any container | ⚠️ Review first |
| **Build Cache** | Docker build cache | ✅ Safe |

## Installation

```shell
./install.sh
```

This will install both `dclear` and `dclear-docker` to `/usr/local/bin` or `/usr/bin`.

## Usage

### Basic Usage

```shell
# Clean project dependencies
dclear                    # Scan current directory with interactive confirmation
dclear ~/projects         # Scan specified directory

# Clean Docker resources only
dclear --only-docker      # Skip directory scan, only clean Docker
```

### Advanced Options

```shell
# Directory cleanup options
dclear -h                      # Show help
dclear -d                      # Dry-run mode (preview only)
dclear -s 100                  # Only process directories > 100MB
dclear -y                      # Auto confirm without interaction
dclear -s 50 -y                # Auto delete directories > 50MB
dclear ~/code -d -s 100        # Preview directories > 100MB in ~/code
dclear -m 7 ~/projects         # Scan up to 7 levels deep (default: 5)

# Docker cleanup options
dclear --docker                # Clean dependencies + Docker resources
dclear --docker -y             # Auto-confirm all cleanups
dclear -d --docker             # Preview Docker cleanup only
dclear --only-docker           # Only clean Docker (skip directory scan)
dclear --only-docker -y        # Clean Docker only, auto-confirm
dclear ~/projects --docker -y  # Full cleanup with auto-confirm
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-d, --dry-run` | Preview mode, only show what will be deleted |
| `-y, --yes` | Auto confirm without interaction |
| `-s N, --size N` | Only process directories larger than N MB |
| `-m N, --maxdepth N` | Maximum directory depth to scan (default: 5) |
| `--docker` | Also clean up Docker resources after directory cleanup |
| `--only-docker` | **Only** clean Docker resources, skip directory scanning |
| `--no-parallel` | Disable parallel size calculation |

## Example Output

### Directory Cleanup

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

### Docker Cleanup

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

## Docker Cleanup Explained

### What Gets Cleaned

1. **Dangling Images** - Intermediate build layers without tags
   - Safe to remove
   - Usually created during `docker build`

2. **Stopped Containers** - Containers in "Exited" state
   - Safe to remove
   - Data in volumes is preserved

3. **Unused Volumes** - Not attached to any container
   - ⚠️ Review before deleting
   - May contain important data

4. **Build Cache** - Docker builder cache
   - Safe to remove
   - Will slow down future builds slightly

### Order of Operations

Docker cleanup happens in this order (important for dependencies):
1. Remove dangling images
2. Remove stopped containers
3. Remove unused volumes (after containers are gone)
4. Remove build cache

### Preview Before Cleaning

Always use dry-run first to see what would be deleted:
```shell
dclear --only-docker -d     # Preview Docker cleanup
dclear -d                   # Preview directory cleanup
dclear --docker -d          # Preview both
```

## Safety Tips

- **Always use `-d` first**: Preview what will be deleted before actually deleting
- **Interactive confirmation**: Required by default to prevent accidental deletion
- **Nested directories skipped**: Automatically skips nested dependency directories (e.g., node_modules inside node_modules)
- **Size threshold**: Use `-s` to avoid deleting small directories
- **Docker volumes**: Review the list before confirming - volumes may contain important data

## Platform Compatibility

- **macOS**: Fully supported (uses `du -sk` for compatibility)
- **Linux**: Fully supported
- **bash 3.2+**: Compatible with older bash versions
- **Docker**: Optional - only needed for `--docker` flag or `--only-docker`

## dclear-docker (Standalone Tool)

For more granular Docker cleanup control, use the included `dclear-docker` script:

### Installation

```shell
cp dclear-docker /usr/local/bin/
```

### Commands

```shell
# Clean specific resources
dclear-docker images              # Remove dangling images (safe intermediate layers)
dclear-docker images -a           # Remove all unused images (not just dangling)
dclear-docker containers          # Remove stopped containers
dclear-docker volumes             # Remove unused volumes (uses --all flag)
dclear-docker networks            # Remove unused networks
dclear-docker cache               # Clean build cache
dclear-docker all                 # Clean everything (images, containers, volumes, networks)
dclear-docker system              # Docker system prune (comprehensive cleanup)

# Options
dclear-docker -d images           # Preview what would be deleted
dclear-docker -y containers       # Auto-confirm without prompting
dclear-docker -d -a images        # Preview removing all unused images
```

### Key Differences from `dclear --docker`

| Feature | `dclear --docker` | `dclear-docker` |
|---------|-------------------|-----------------|
| Scope | Part of dclear workflow | Standalone tool |
| Images cleaned | Dangling only | Dangling or all (with `-a`) |
| Volumes | Uses `--all` flag | Uses `--all` flag |
| Interactive | Step-by-step prompts | Per-command confirmation |

### Example: Clean Everything

```shell
# Preview first
dclear-docker -d all

# Actually clean
dclear-docker all -y
```

## License

MIT
