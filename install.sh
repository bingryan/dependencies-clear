#!/bin/sh
#
# Installation script for dclear and dclear-docker
#

INSTALL_DIR=$(dirname $0)

bin="$INSTALL_DIR/dclear"
bin_docker="$INSTALL_DIR/dclear-docker"
binpaths="/usr/local/bin /usr/bin"

# Track installation status
main_installed=""
docker_installed=""

# Install main dclear script
for binpath in $binpaths; do
  if cp "$bin" "$binpath/dclear" 2>/dev/null; then
    chmod +x "$binpath/dclear"
    echo "✓ Installed dclear to $binpath"
    main_installed="$binpath"
    break
  fi
done

# Install dclear-docker script (optional)
if [ -f "$bin_docker" ]; then
  for binpath in $binpaths; do
    if cp "$bin_docker" "$binpath/dclear-docker" 2>/dev/null; then
      chmod +x "$binpath/dclear-docker"
      echo "✓ Installed dclear-docker to $binpath"
      docker_installed="$binpath"
      break
    fi
  done
fi

# Check results
if [ -n "$main_installed" ]; then
  echo ""
  echo "Installation complete!"
  echo ""
  echo "Usage:"
  echo "  dclear              # Clean project dependencies"
  if [ -n "$docker_installed" ]; then
    echo "  dclear --docker     # Clean dependencies + Docker"
    echo "  dclear-docker       # Advanced Docker cleanup"
  fi
  echo ""
  exit 0
fi

# Installation failed
echo ""
echo "Error: Could not install dclear to any of: $binpaths"

if [ ! -w "/usr/local/bin" ] && [ ! -w "/usr/bin" ]; then
  echo ""
  echo "It seems that we do not have the necessary write permissions."
  echo "Try running this script as a privileged user:"
  echo ""
  echo "    sudo $0"
  echo ""
fi

exit 1
