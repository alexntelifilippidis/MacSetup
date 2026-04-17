#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[0;31m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}▶▶▶ 🐋 Setting up Podman Machine & Registry ◀◀◀${RESET}"
echo -e "${CYAN}───────────────────────────────────────────────${RESET}"

# Check if podman is installed
if ! command -v podman &> /dev/null; then
  echo -e "${RED}❌ Podman is not installed. Please run the main setup.sh first.${RESET}"
  exit 1
fi

# Initialize podman machine if not already initialized
if ! podman machine list | grep -q "podman-machine-default"; then
  echo -e "${YELLOW}⏳ Initializing Podman machine...${RESET}"
  podman machine init
else
  echo -e "${GREEN}✅ Podman machine already initialized${RESET}"
fi

# Start the podman machine if not running
MACHINE_STATUS=$(podman machine list --format "{{.Running}}" | head -n 1)
if [ "$MACHINE_STATUS" != "true" ]; then
  echo -e "${YELLOW}⏳ Starting Podman machine...${RESET}"
  podman machine start
else
  echo -e "${GREEN}✅ Podman machine is already running${RESET}"
fi

# Configure SSH access
echo -e "${BLUE}🔑 Setting up SSH access to Podman machine...${RESET}"
MACHINE_NAME=$(podman machine list --format "{{.Name}}" | tail -n 1 | tr -d '*' | xargs)

echo -e "${GREEN}✅ SSH access configured for machine: $MACHINE_NAME${RESET}"
echo -e "${CYAN}   You can SSH into the machine using:${RESET}"
echo -e "${YELLOW}   podman machine ssh $MACHINE_NAME${RESET}"

# Configure container registry
echo ""
echo -e "${BLUE}🔧 Configuring container registry mirror...${RESET}"

# Copy registries.conf to the podman machine
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRIES_CONF="$SCRIPT_DIR/registries.conf"

if [ ! -f "$REGISTRIES_CONF" ]; then
  echo -e "${RED}❌ registries.conf not found at $REGISTRIES_CONF${RESET}"
  exit 1
fi

# Gate the heavy work (copy + stop/start) on an actual config change.
# Why: the previous version ALWAYS stopped and started the VM on every run,
# costing ~20s even when nothing changed. Compare checksums first so
# re-running `make mac-setup` is fast and truly idempotent.
LOCAL_SHA="$(shasum -a 256 "$REGISTRIES_CONF" | awk '{print $1}')"
REMOTE_SHA="$(podman machine ssh "$MACHINE_NAME" -- "sha256sum /etc/containers/registries.conf 2>/dev/null | awk '{print \$1}'" || echo "")"

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo -e "${CYAN}⏭️  No changes: registries.conf already up to date inside VM${RESET}"
else
  echo -e "${YELLOW}⏳ Updating registry configuration inside Podman machine...${RESET}"

  # Quoting "$MACHINE_NAME" is required — unquoted vars break on whitespace
  # and trip shellcheck SC2086. Stream the config into the VM's /tmp.
  podman machine ssh "$MACHINE_NAME" "cat > /tmp/registries_mirror.conf" < "$REGISTRIES_CONF"

  # Apply inside the VM. Quoted 'EOF' means variables are NOT expanded locally —
  # the whole block runs as the remote shell, which is exactly what we want.
  podman machine ssh "$MACHINE_NAME" << 'EOF'
        set -euo pipefail
        # Backup original registries.conf on first run so an uninstall script
        # (or manual revert) can restore the stock Podman behaviour.
        if [ ! -f /etc/containers/registries.conf.bak ]; then
            sudo cp /etc/containers/registries.conf /etc/containers/registries.conf.bak
            echo "✅ Backed up original registries.conf"
        fi

        sudo cp /tmp/registries_mirror.conf /etc/containers/registries.conf
        sudo rm -f /tmp/registries_mirror.conf
        echo "✅ Registry configuration overwritten"
EOF

  # Only restart when config actually changed — see gating above.
  echo ""
  echo -e "${YELLOW}⏳ Restarting Podman machine to apply changes...${RESET}"
  podman machine stop
  podman machine start
fi

echo ""
echo -e "${GREEN}🎉 Podman Setup Complete! 🎉${RESET}"
echo -e "${CYAN}Registry mirror: registry.kaizengaming.eu/docker-hub-proxy${RESET}"
echo ""
