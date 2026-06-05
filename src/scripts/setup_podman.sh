#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=./lib/colors.sh
source "$REPO_ROOT/src/scripts/lib/colors.sh"

REGISTRIES_CONF="$REPO_ROOT/src/dotfiles/podman/registries.conf"

if ! command -v podman &> /dev/null; then
  echo -e "${RED}❌ Podman is not installed. Run the main setup first.${RESET}"
  exit 1
fi

if [ ! -f "$REGISTRIES_CONF" ]; then
  echo -e "${RED}❌ registries.conf not found at $REGISTRIES_CONF${RESET}"
  exit 1
fi

if ! podman machine list | grep -q "podman-machine-default"; then
  echo -e "  ${YELLOW}⏳ Initializing Podman machine...${RESET}"
  podman machine init
else
  echo -e "  ${GREEN}✅ Podman machine already initialized${RESET}"
fi

MACHINE_STATUS=$(podman machine list --format "{{.Running}}" | head -n 1)
if [ "$MACHINE_STATUS" != "true" ]; then
  echo -e "  ${YELLOW}⏳ Starting Podman machine...${RESET}"
  podman machine start
else
  echo -e "  ${GREEN}✅ Podman machine is already running${RESET}"
fi

MACHINE_NAME=$(podman machine list --format "{{.Name}}" | tail -n 1 | tr -d '*' | xargs)
echo -e "  ${CYAN}ℹ️  SSH: podman machine ssh ${MACHINE_NAME}${RESET}"
echo -e "  ${BLUE}🔧 Configuring container registry mirror...${RESET}"

# Gate the stop/start cycle on an actual config change — re-running must be fast.
LOCAL_SHA="$(shasum -a 256 "$REGISTRIES_CONF" | awk '{print $1}')"
REMOTE_SHA="$(podman machine ssh "$MACHINE_NAME" -- "sha256sum /etc/containers/registries.conf 2>/dev/null | awk '{print \$1}'" || echo "")"

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo -e "  ${CYAN}⏭️  No changes: registries.conf already up to date inside VM${RESET}"
else
  echo -e "  ${YELLOW}⏳ Updating registry configuration inside Podman machine...${RESET}"

  podman machine ssh "$MACHINE_NAME" "cat > /tmp/registries_mirror.conf" < "$REGISTRIES_CONF"

  # Quoted 'EOF' prevents local variable expansion — the whole block runs in the VM shell.
  podman machine ssh "$MACHINE_NAME" << 'EOF'
    set -euo pipefail
    if [ ! -f /etc/containers/registries.conf.bak ]; then
        sudo cp /etc/containers/registries.conf /etc/containers/registries.conf.bak
        echo "  ✅ Backed up original registries.conf"
    fi
    sudo cp /tmp/registries_mirror.conf /etc/containers/registries.conf
    sudo rm -f /tmp/registries_mirror.conf
    echo "  ✅ Registry configuration overwritten"
EOF

  echo -e "  ${YELLOW}⏳ Restarting Podman machine to apply changes...${RESET}"
  podman machine stop
  podman machine start
  echo -e "  ${GREEN}✅ Registry mirror: registry.kaizengaming.eu/docker-hub-proxy${RESET}"
fi
