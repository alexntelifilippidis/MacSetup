#!/bin/bash

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
MACHINE_NAME=$(podman machine list --format "{{.Name}}" | head -n 1)

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

# Append registry configuration to /etc/containers/registries.conf in podman machine
echo -e "${YELLOW}⏳ Updating registry configuration inside Podman machine...${RESET}"

# Copy the registries.conf to the podman machine's tmp directory
podman machine ssh $MACHINE_NAME "cat > /tmp/registries_mirror.conf" < "$REGISTRIES_CONF"

# SSH into podman machine and append the configuration
podman machine ssh $MACHINE_NAME << 'EOF'
    # Backup original registries.conf if not already backed up
    if [ ! -f /etc/containers/registries.conf.bak ]; then
        sudo cp /etc/containers/registries.conf /etc/containers/registries.conf.bak
        echo "✅ Backed up original registries.conf"
    fi

    # Check if our mirror is already configured
    if ! sudo grep -q "registry.kaizengaming.eu/docker-hub-proxy" /etc/containers/registries.conf; then
        echo "" | sudo tee -a /etc/containers/registries.conf > /dev/null
        echo "# Custom Docker Hub Mirror" | sudo tee -a /etc/containers/registries.conf > /dev/null
        sudo cat /tmp/registries_mirror.conf | sudo tee -a /etc/containers/registries.conf > /dev/null
        sudo rm -f /tmp/registries_mirror.conf
        echo "✅ Registry mirror configuration added"
    else
        sudo rm -f /tmp/registries_mirror.conf
        echo "✅ Registry mirror already configured"
    fi
EOF

echo ""
echo -e "${GREEN}🎉 Podman Setup Complete! 🎉${RESET}"
echo -e "${CYAN}Registry mirror: registry.kaizengaming.eu/docker-hub-proxy${RESET}"
echo ""
