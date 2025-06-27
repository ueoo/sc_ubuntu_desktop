# SC Ubuntu Desktop

A Docker-based Ubuntu desktop environment with NVIDIA GPU acceleration and KDE Plasma desktop. Based on CUDA 12.4.1 and Ubuntu 20.04, providing complete GPU computing and graphics acceleration support.

This docker image is dedicated to the Stanford Compute cluster.

## Features

- 🖥️ **KDE Plasma Desktop Environment** - Modern Linux desktop experience
- 🎮 **NVIDIA GPU Support** - Complete GPU acceleration support, with CUDA 12.4.1 and cuDNN
- 🌐 **Web Interface Access** - Access desktop through browser
- 🔧 **Easy Configuration** - Simple scripts and configuration files
- 📦 **Containerized Deployment** - Deploy using Docker

## System Requirements

> All components are preinstalled on the SC cluster.
- Docker
- NVIDIA Container Toolkit
- NVIDIA Driver
- NVIDIA GPU support

### Docker Group Setup

Before using this container, ensure your SC user account is in the docker group:

```bash
# Add current user to docker group (check with Jimmy)
sudo usermod -aG docker $USER

# Log out and log back in for changes to take effect
# Or run: newgrp docker
```

## Quick Start

### 1. Build Image

```bash
# Build with default settings (based on CUDA 12.4.1)
./build.sh

# Build with custom tag
./build.sh -t v1.0

# View build options
./build.sh --help
```

### 2. Run Container

```bash
# Run with default settings
./run.sh

# Run with custom port
./run.sh -p 9090

# Run with custom resolution
./run.sh -w 2560 -h 1440

# Run with custom password
./run.sh --passwd mypassword
```

### 3. Access Desktop

After the container starts, open your browser and visit:

**On Campus:**
- **URL**: `http://{SC_NODENAME}:8080`

**Off Campus:**
- **SSH Tunnel**: `ssh -L 8080:localhost:8080 {SC_USERNAME}@{SC_NODENAME}`
- **URL**: `http://localhost:8080`

**Login Credentials:**
- **Username**: `ubuntu`
- **Password**: `mypasswd` (or your custom password)

### SSH Configuration (Optional)

For convenient access, you can add the following to your `~/.ssh/config`:

```bash
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_rsa
    # ControlMaster auto
    # ControlPath ~/.ssh/multiplex/%r@%h:%p
    # ControlPersist 1h
    ServerAliveInterval 60
    ServerAliveCountMax 50
    ConnectTimeout 60
    SetEnv TERM=xterm-256color

Host SCDT
    HostName scdt.stanford.edu
    User {YOUR_USERNAME}
    ForwardAgent yes

Host SC
    HostName sc.stanford.edu
    User {YOUR_USERNAME}
    ProxyJump SCDT
    ForwardAgent yes

Host {SC_NODENAME}
    User {YOUR_USERNAME}
    ProxyCommand ssh -W %h:%p SC
```

**Note**: Replace `{YOUR_USERNAME}` with your actual SC username.

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWD` | mypasswd | User password |
| `DISPLAY_SIZEW` | 1920 | Display width |
| `DISPLAY_SIZEH` | 1080 | Display height |
| `DISPLAY_REFRESH` | 60 | Refresh rate |
| `DISPLAY_DPI` | 96 | DPI setting |
| `DISPLAY_CDEPTH` | 24 | Color depth |
| `VIDEO_PORT` | DFP | Video port |
| `MOUNT` |  | Host path to container path mount |

### Command Line Options

```bash
./run.sh [OPTIONS]

Options:
  -p, --port PORT       Set host port (default: 8080)
  -w, --width WIDTH     Set display width (default: 1920)
  -h, --height HEIGHT   Set display height (default: 1080)
  -r, --refresh RATE    Set refresh rate (default: 60)
  -d, --dpi DPI         Set DPI (default: 96)
  -c, --depth DEPTH     Set color depth (default: 24)
  -v, --video-port PORT Set video port (default: DFP)
  -m, --mount HOST:CONTAINER  Mount host path to container path
  --passwd PASSWORD     Set user password (default: mypasswd)
  --help                Show help information
```

## Usage Examples

### Basic Usage

```bash
# Build image
./build.sh

# Run container
./run.sh

# Access http://localhost:8080
```

### Advanced Configuration

```bash
# Use high resolution
./run.sh -w 2560 -h 1440 -r 144

# Use custom port and password
./run.sh -p 9090 --passwd mysecurepass

# Use environment variables
PASSWD=mysecret ./run.sh -w 1920 -h 1080

# Mount host directory to container
./run.sh -m /home/user/data:/home/ubuntu/data

# Mount with custom port and resolution
./run.sh -p 9090 -w 1920 -h 1080 -m /host/path:/container/path
```

### Multi-Container Deployment

```bash
# Run first container
./run.sh -p 8080 --passwd pass1

# Run second container
./run.sh -p 8081 --passwd pass2
```

## CUDA and GPU Support

### Verify CUDA Installation

```bash
# Enter container
docker exec -it sc_ubuntu_desktop bash

# Check CUDA version
nvcc --version

# Check GPU status
nvidia-smi

# Run CUDA samples
cd /usr/local/cuda/samples/1_Utilities/deviceQuery
make
./deviceQuery
```

### GPU Computing Environment

Container includes the following GPU computing tools:
- **CUDA 12.4.1** - NVIDIA parallel computing platform
- **cuDNN** - Deep neural network library
- **NVIDIA Driver** - Complete GPU driver support
- **OpenCL** - Open computing language support
- **Vulkan** - Modern graphics API

## Container Management

### Development Environment Setup

For better container management experience, we recommend installing the **Docker** extensions in VS Code or Cursor:

#### VS Code/Cursor Docker Extension

1. **Install Docker Extension**:
   - Open VS Code/Cursor
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Docker" by Microsoft
   - Install the extension

2. **Features provided**:
   - **Container Management**: View, start, stop, and remove containers
   - **Image Management**: Build, push, and pull Docker images
   - **Volume Management**: Manage Docker volumes
   - **Network Management**: Configure Docker networks
   - **Logs Viewing**: Real-time container logs
   - **File Explorer**: Browse container filesystem
   - **Terminal Integration**: Direct terminal access to containers
   - **Docker Compose Support**: Manage multi-container applications

3. **Benefits**:
   - **Visual Interface**: No need to remember Docker commands
   - **Integrated Development**: Manage containers directly from your IDE
   - **Debugging Support**: Easy access to container logs and files
   - **Resource Monitoring**: View container resource usage
   - **Quick Actions**: Right-click menus for common operations

This extension will significantly improve your workflow when working with Docker containers, especially for development and debugging purposes.

### View Container Status

```bash
# View running containers
docker ps

# View all containers
docker ps -a
```

### View Logs

```bash
# View container logs
docker logs sc_ubuntu_desktop

# View logs in real-time
docker logs -f sc_ubuntu_desktop
```

### Stop and Remove

```bash
# Stop container
docker stop sc_ubuntu_desktop

# Remove container
docker rm sc_ubuntu_desktop

# Stop and remove
docker rm -f sc_ubuntu_desktop
```

### Enter Container

```bash
# Enter container shell
docker exec -it sc_ubuntu_desktop bash

# Enter as root user
docker exec -it -u root sc_ubuntu_desktop bash
```

## Troubleshooting

### Common Issues

1. **Container cannot start**
   - Check if Docker is running
   - Check if NVIDIA Container Toolkit is properly installed
   - View container logs: `docker logs sc_ubuntu_desktop`

2. **GPU not available**
   - Confirm host has NVIDIA GPU
   - Confirm NVIDIA driver is installed
   - Confirm NVIDIA Container Toolkit is configured
   - Check CUDA compatibility: `nvidia-smi`

3. **Web interface not accessible**
   - Check if port is occupied
   - Confirm firewall settings
   - Check if container is running properly

4. **Performance issues**
   - Increase shared memory: `--shm-size 8g`
   - Adjust KasmVNC thread count
   - Check GPU usage

### Debug Commands

```bash
# Check GPU status
nvidia-smi

# Check container GPU access
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu20.04 nvidia-smi

# Check port usage
netstat -tlnp | grep 8080

# Check container resource usage
docker stats sc_ubuntu_desktop

# Check CUDA installation
docker exec -it sc_ubuntu_desktop nvcc --version
```

## File Structure

```
sc_ubuntu_desktop/
├── Dockerfile             # Docker image definition (based on CUDA 12.4.1)
├── build.sh               # Build script
├── run.sh                 # Run script
├── entrypoint.sh          # Container startup script
├── entrypoint-kasmvnc.sh  # KasmVNC startup script
├── supervisord.conf       # Process management configuration
└── README.md              # Documentation
```

## Technical Specifications

- **Base Image**: nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04
- **CUDA Version**: 12.4.1
- **cuDNN Version**: Included in base image
- **Desktop Environment**: KDE Plasma
- **Web Interface**: KasmVNC
- **GPU Support**: Complete NVIDIA GPU acceleration

## License

This project is open source under the [Mozilla Public License 2.0](LICENSE).

## Acknowledgments

This project is based on the following open source projects:
- [NVIDIA CUDA](https://developer.nvidia.com/cuda-zone)
- [docker-nvidia-glx-desktop](https://github.com/selkies-project/docker-nvidia-glx-desktop)
- [KasmVNC](https://github.com/kasmtech/KasmVNC)
- [KDE Plasma](https://kde.org/plasma-desktop/)
