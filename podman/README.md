# 🐋 Podman Setup

This directory contains configuration and setup scripts for Podman machine with custom registry mirror.

## Files

- **`setup_podman.sh`**: Script to initialize Podman machine and configure registry mirror
- **`registries.conf`**: Registry mirror configuration for Docker Hub
- **`QUICK_REFERENCE.md`**: Quick reference guide for common Podman commands and SSH operations

## What the Setup Does

1. **Initializes Podman Machine**: Creates a new Podman machine if not already initialized
2. **Starts Podman Machine**: Ensures the machine is running
3. **Configures SSH Access**: Sets up SSH for easy access to the Podman VM
4. **Registry Mirror**: Configures a Docker Hub mirror (`registry.kaizengaming.eu/docker-hub-proxy`) inside the Podman machine

## Usage

### Automatic Setup
The setup is automatically run when you execute the main `setup.sh` script from the root directory.

### Manual Setup
You can run the Podman setup separately:

```bash
bash podman/setup_podman.sh
```

Or using Make:
```bash
make podman-setup
```

## Registry Configuration

The setup script uses **SSH to connect to the Podman machine** and appends the registry mirror configuration to `/etc/containers/registries.conf` inside the VM.

### Configuration Details

The following configuration is appended to `/etc/containers/registries.conf`:

```toml
[[registry]]
location="docker.io"
[[registry.mirror]]
location="registry.kaizengaming.eu/docker-hub-proxy"
```

### How It Works

1. **SSH into Podman Machine**: The script uses `podman machine ssh` to connect to the VM
2. **Backup Original Config**: Creates a backup at `/etc/containers/registries.conf.bak` (if not already backed up)
3. **Check for Duplicates**: Verifies if the mirror is already configured to avoid duplication
4. **Append Configuration**: Adds the registry mirror configuration to the file
5. **Verification**: The configuration is immediately active for new container pulls

### Benefits

This configuration:
- Routes Docker Hub pulls through the Kaizen Gaming registry mirror
- Improves pull performance and reduces bandwidth usage
- Provides caching for frequently used images
- Transparent to container operations (no code changes needed)

### Verify Configuration

After setup, verify the configuration is applied:

```bash
# SSH into the machine and check the config
podman machine ssh -- "sudo cat /etc/containers/registries.conf"

# Or interactively
podman machine ssh
sudo cat /etc/containers/registries.conf
```

## SSH Access

After setup, you can SSH into the Podman machine:

```bash
# Using podman command (default machine)
podman machine ssh

# Or if you have multiple machines
podman machine ssh <machine-name>

# List all machines
podman machine list

# Get machine info
podman machine inspect
```

### SSH Connection Details

The setup script automatically configures SSH access to the Podman VM. Once configured, you can:

1. **Execute commands inside the VM**:
   ```bash
   podman machine ssh -- "sudo cat /etc/containers/registries.conf"
   ```

2. **Interactive SSH session**:
   ```bash
   podman machine ssh
   # Now you're inside the Podman VM
   ```

3. **Check SSH connectivity**:
   ```bash
   podman machine ssh -- "echo 'SSH is working!'"
   ```

## Testing the Setup

Test that Podman is working correctly:

```bash
# Pull an image (will use the mirror)
podman pull hello-world

# Run a container
podman run hello-world

# Check running containers
podman ps -a
```

## Backup

The setup script automatically creates a backup of the original `registries.conf`:
- Original: `/etc/containers/registries.conf`
- Backup: `/etc/containers/registries.conf.bak`

## Troubleshooting

### Machine won't start
```bash
# Check machine status
podman machine list

# Stop and restart
podman machine stop
podman machine start
```

### Registry mirror not working
```bash
# SSH into the machine
podman machine ssh

# Check the registry configuration
sudo cat /etc/containers/registries.conf

# Restart the machine to apply changes
exit
podman machine stop
podman machine start
```

### Remove and recreate machine
```bash
podman machine stop
podman machine rm
podman machine init
bash podman/setup_podman.sh
```
