# 🐋 Podman Quick Reference

## SSH Commands

### Connect to Podman Machine
```bash
# Interactive SSH session
podman machine ssh

# Execute single command
podman machine ssh -- "command_here"

# Check registries.conf
podman machine ssh -- "sudo cat /etc/containers/registries.conf"

# Check if mirror is configured
podman machine ssh -- "sudo grep -A 2 'docker.io' /etc/containers/registries.conf"
```

## Machine Management

### Start/Stop Machine
```bash
# Start machine
podman machine start

# Stop machine
podman machine stop

# Restart machine
podman machine stop && podman machine start

# List machines
podman machine list

# Get machine details
podman machine inspect
```

### Machine Status
```bash
# Check if machine is running
podman machine list --format "{{.Name}}: {{.Running}}"

# Get machine info
podman machine info
```

## Registry Configuration

### View Current Configuration
```bash
# From host machine
podman machine ssh -- "sudo cat /etc/containers/registries.conf"

# From inside the VM (after podman machine ssh)
sudo cat /etc/containers/registries.conf
```

### Check Backup
```bash
# View backup of original config
podman machine ssh -- "sudo cat /etc/containers/registries.conf.bak"
```

### Verify Mirror is Active
```bash
# Pull an image and check logs
podman pull --log-level=debug hello-world 2>&1 | grep registry
```

## Container Operations

### Basic Commands
```bash
# Pull an image (uses mirror automatically)
podman pull nginx

# Run a container
podman run -d --name mynginx -p 8080:80 nginx

# List running containers
podman ps

# List all containers
podman ps -a

# Stop a container
podman stop mynginx

# Remove a container
podman rm mynginx

# Remove an image
podman rmi nginx
```

### Check Container Logs
```bash
podman logs <container-name-or-id>
```

## Troubleshooting

### TLS Handshake Failure
If you get `tls: handshake failure` errors when pulling images or running `docker-compose`:

```bash
# 1. Verify registry configuration is correct
podman machine ssh -- "sudo cat /etc/containers/registries.conf | tail -10"

# Expected output should show:
# [[registry]]
# prefix = "docker.io"
# location = "docker.io"
# 
# [[registry.mirror]]
# location = "registry.kaizengaming.eu/docker-hub-proxy"
# insecure = true

# 2. If configuration is missing or incorrect, re-run setup
bash podman/setup_podman.sh

# 3. If issue persists, manually restart the machine
podman machine stop
podman machine start

# 4. Test with a simple image pull
podman pull hello-world

# 5. If using docker-compose, ensure DOCKER_HOST is set correctly
echo $DOCKER_HOST  # Should show the socket path
# If empty or incorrect:
export DOCKER_HOST=unix:///var/run/docker.sock
```

**Root Cause:** The `insecure = true` flag must be set for the registry mirror to allow HTTP connections. Without it, TLS handshake failures occur.

### Reset Everything
```bash
# Stop and remove machine
podman machine stop
podman machine rm

# Remove all containers and images
podman system reset

# Re-run setup
bash podman/setup_podman.sh
```

### Check Machine Logs
```bash
# View machine logs
podman machine ssh -- "sudo journalctl -u podman"
```

### Network Issues
```bash
# Restart machine network
podman machine stop
podman machine start

# Check machine connectivity
podman machine ssh -- "ping -c 3 8.8.8.8"
```

## File Transfer

### Copy Files to/from Machine
```bash
# Get machine connection details
podman machine ssh -- "pwd"

# Use podman cp (for containers)
podman cp <container>:/path/to/file /local/path
podman cp /local/path <container>:/path/to/file
```

## Advanced

### Execute Multiple Commands
```bash
podman machine ssh << 'EOF'
sudo cat /etc/containers/registries.conf
echo "---"
sudo systemctl status podman
EOF
```

### Edit Configuration Manually
```bash
# SSH into machine
podman machine ssh

# Edit registries.conf
sudo vi /etc/containers/registries.conf

# Restart podman service (if needed)
sudo systemctl restart podman

# Exit SSH session
exit
```

## Setup Commands

### Initial Setup
```bash
# Run full Mac setup (includes Podman)
bash setup.sh

# Run only Podman setup
bash podman/setup_podman.sh

# Or using Make
make podman-setup
```

### Re-apply Registry Configuration
```bash
# If you need to re-run just the registry setup
bash podman/setup_podman.sh
# The script is idempotent and won't duplicate configuration
```
