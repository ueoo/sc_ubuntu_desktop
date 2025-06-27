#!/bin/bash

# Run script for sc_ubuntu_desktop container
# This script runs the Docker container with NVIDIA GPU support and KDE desktop

set -e

# Configuration
IMAGE_NAME="sc-ubuntu-desktop"
TAG="20.04-cuda124-xgl-vnc"
CONTAINER_NAME="xgl"
HOSTNAME="ubuntu-desktop"
HOST_PORT="8080"
CONTAINER_PORT="8080"

# Default environment variables
DEFAULT_PASSWD="mypasswd"
DEFAULT_DISPLAY_SIZEW="1920"
DEFAULT_DISPLAY_SIZEH="1080"
DEFAULT_DISPLAY_REFRESH="60"
DEFAULT_DISPLAY_DPI="96"
DEFAULT_DISPLAY_CDEPTH="24"
DEFAULT_VIDEO_PORT="DFP"
DEFAULT_MOUNT=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if image exists
check_image() {
    if ! docker image inspect "${IMAGE_NAME}:${TAG}" &> /dev/null; then
        print_error "Image ${IMAGE_NAME}:${TAG} not found. Please build it first using: ./build.sh"
        exit 1
    fi
}

# Check if container is already running
check_container() {
    if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
        print_warning "Container ${CONTAINER_NAME} is already running."
        print_info "You can access it at: http://localhost:${HOST_PORT}"
        print_info "To stop it, run: docker stop ${CONTAINER_NAME}"
        print_info "To view logs, run: docker logs ${CONTAINER_NAME}"
        exit 0
    fi

    if docker ps -aq -f name="${CONTAINER_NAME}" | grep -q .; then
        print_warning "Container ${CONTAINER_NAME} exists but is not running. Removing it..."
        docker rm "${CONTAINER_NAME}" > /dev/null 2>&1 || true
    fi
}

# Parse environment variables from command line
parse_env_vars() {
    # Set default values
    PASSWD="${PASSWD:-$DEFAULT_PASSWD}"
    DISPLAY_SIZEW="${DISPLAY_SIZEW:-$DEFAULT_DISPLAY_SIZEW}"
    DISPLAY_SIZEH="${DISPLAY_SIZEH:-$DEFAULT_DISPLAY_SIZEH}"
    DISPLAY_REFRESH="${DISPLAY_REFRESH:-$DEFAULT_DISPLAY_REFRESH}"
    DISPLAY_DPI="${DISPLAY_DPI:-$DEFAULT_DISPLAY_DPI}"
    DISPLAY_CDEPTH="${DISPLAY_CDEPTH:-$DEFAULT_DISPLAY_CDEPTH}"
    VIDEO_PORT="${VIDEO_PORT:-$DEFAULT_VIDEO_PORT}"
    MOUNT="${MOUNT:-$DEFAULT_MOUNT}"
}

# Run the container
·() {
    print_status "Starting container: ${CONTAINER_NAME}"

    # Build docker run command
    DOCKER_CMD="docker run"
    DOCKER_CMD="$DOCKER_CMD --name ${CONTAINER_NAME}"
    DOCKER_CMD="$DOCKER_CMD --hostname ${HOSTNAME}"
    DOCKER_CMD="$DOCKER_CMD --gpus all"
    DOCKER_CMD="$DOCKER_CMD --tmpfs /dev/shm:rw"
    DOCKER_CMD="$DOCKER_CMD -p ${HOST_PORT}:${CONTAINER_PORT}"
    DOCKER_CMD="$DOCKER_CMD -e TZ="America/Los_Angeles""
    DOCKER_CMD="$DOCKER_CMD -e DISPLAY_SIZEW=${DISPLAY_SIZEW}"
    DOCKER_CMD="$DOCKER_CMD -e DISPLAY_SIZEH=${DISPLAY_SIZEH}"
    DOCKER_CMD="$DOCKER_CMD -e DISPLAY_REFRESH=${DISPLAY_REFRESH}"
    DOCKER_CMD="$DOCKER_CMD -e DISPLAY_DPI=${DISPLAY_DPI}"
    DOCKER_CMD="$DOCKER_CMD -e DISPLAY_CDEPTH=${DISPLAY_CDEPTH}"
    DOCKER_CMD="$DOCKER_CMD -e VIDEO_PORT=${VIDEO_PORT}"
    DOCKER_CMD="$DOCKER_CMD -e PASSWD=${PASSWD}"
    DOCKER_CMD="$DOCKER_CMD -e SELKIES_ENABLE_BASIC_AUTH=true"
    DOCKER_CMD="$DOCKER_CMD -e SELKIES_BASIC_AUTH_PASSWORD=${PASSWD}"

    # Add mount if specified
    if [ -n "$MOUNT" ]; then
        DOCKER_CMD="$DOCKER_CMD -v ${MOUNT}"
    fi

    DOCKER_CMD="$DOCKER_CMD -d"
    DOCKER_CMD="$DOCKER_CMD ${IMAGE_NAME}:${TAG}"

    # Execute the command
    print_info "Running: $DOCKER_CMD"
    eval $DOCKER_CMD

    if [ $? -eq 0 ]; then
        print_status "Container started successfully!"
        print_info "Container name: ${CONTAINER_NAME}"
        print_info ""
        print_info "Access Desktop:"
        print_info "  On Campus: http://{SC_NODENAME}:${HOST_PORT}"
        print_info "  Off Campus: ssh -L ${HOST_PORT}:localhost:${HOST_PORT} {SC_USERNAME}@{SC_NODENAME}"
        print_info "    Then visit: http://localhost:${HOST_PORT}"
        print_info ""
        print_info "Login Credentials:"
        print_info "  Username: ubuntu"
        print_info "  Password: ${PASSWD}"
        print_info ""
        print_info "Useful commands:"
        print_info "  View logs: docker logs ${CONTAINER_NAME}"
        print_info "  Stop container: docker stop ${CONTAINER_NAME}"
        print_info "  Remove container: docker rm ${CONTAINER_NAME}"
        print_info "  Access shell: docker exec -it ${CONTAINER_NAME} bash"
    else
        print_error "Failed to start container"
        exit 1
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT       Set host port (default: 8080)"
    echo "  -w, --width WIDTH     Set display width (default: 1920)"
    echo "  -h, --height HEIGHT   Set display height (default: 1080)"
    echo "  -r, --refresh RATE    Set refresh rate (default: 60)"
    echo "  -d, --dpi DPI         Set DPI (default: 96)"
    echo "  -c, --depth DEPTH     Set color depth (default: 24)"
    echo "  -v, --video-port PORT Set video port (default: DFP)"
    echo "  -m, --mount HOST:CONTAINER  Mount host path to container path"
    echo "  --passwd PASSWORD     Set user password (default: mypasswd)"
    echo "  --help                Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  You can also set these environment variables:"
    echo "  PASSWD, DISPLAY_SIZEW, DISPLAY_SIZEH, DISPLAY_REFRESH,"
    echo "  DISPLAY_DPI, DISPLAY_CDEPTH, VIDEO_PORT, MOUNT"
    echo ""
    echo "Examples:"
    echo "  $0                                  # Run with default settings"
    echo "  $0 -p 9090                          # Run on port 9090"
    echo "  $0 -w 2560 -h 1440                  # Run with 2560x1440 resolution"
    echo "  $0 --passwd mypassword              # Set custom password"
    echo "  $0 -m /host/path:/container/path    # Mount host directory to container"
    echo "  PASSWD=mypass $0                    # Set password via environment variable"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            HOST_PORT="$2"
            shift 2
            ;;
        -w|--width)
            DISPLAY_SIZEW="$2"
            shift 2
            ;;
        -h|--height)
            DISPLAY_SIZEH="$2"
            shift 2
            ;;
        -r|--refresh)
            DISPLAY_REFRESH="$2"
            shift 2
            ;;
        -d|--dpi)
            DISPLAY_DPI="$2"
            shift 2
            ;;
        -c|--depth)
            DISPLAY_CDEPTH="$2"
            shift 2
            ;;
        -v|--video-port)
            VIDEO_PORT="$2"
            shift 2
            ;;
        -m|--mount)
            MOUNT="$2"
            shift 2
            ;;
        --passwd)
            PASSWD="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "Starting container process..."

    # Check prerequisites
    check_docker
    check_image
    check_container

    # Parse environment variables
    parse_env_vars

    # Run the container
    ·
}

# Run main function
main "$@"
