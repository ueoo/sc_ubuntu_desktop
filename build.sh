#!/bin/bash

# Build script for sc_ubuntu_desktop container
# This script builds a Docker image with NVIDIA GPU support and KDE desktop
# Based on CUDA 12.4.1 and Ubuntu 20.04

set -e

# Configuration
IMAGE_NAME="ueoo/sc-ubuntu-desktop"
TAG="20.04-cuda124-xgl-vnc"
DOCKERFILE="Dockerfile"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if NVIDIA Container Toolkit is available
check_nvidia() {
    if ! command -v nvidia-smi &> /dev/null; then
        print_warning "NVIDIA drivers not detected on host. Container may not work properly."
    fi

    if ! docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu20.04 nvidia-smi &> /dev/null; then
        print_warning "NVIDIA Container Toolkit not properly configured. GPU access may not work."
    fi
}

# Build the image
build_image() {
    print_status "Building Docker image: ${IMAGE_NAME}:${TAG}"
    print_status "Base image: nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04"

    # Build the image
    docker build \
        --tag "${IMAGE_NAME}:${TAG}" \
        --file "${DOCKERFILE}" \
        .

    if [ $? -eq 0 ]; then
        print_status "Successfully built ${IMAGE_NAME}:${TAG}"
        print_status "Image size: $(docker images ${IMAGE_NAME}:${TAG} --format 'table {{.Size}}' | tail -n 1)"
    else
        print_error "Failed to build image"
        exit 1
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG         Set image tag (default: latest)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build with default settings"
    echo "  $0 -t v1.0           # Build with tag v1.0"
    echo ""
    echo "Note: This image is based on CUDA 12.4.1 and Ubuntu 20.04"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -h|--help)
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
    print_status "Starting build process..."
    print_status "Building SC Ubuntu Desktop with CUDA 12.4.1 support"

    # Check prerequisites
    check_docker
    check_nvidia

    # Build the image
    build_image

    print_status "Build completed successfully!"
    print_status "You can now run the container using: ./run.sh"
    print_status ""
    print_status "To verify CUDA installation:"
    print_status "  docker run --rm --gpus all ${IMAGE_NAME}:${TAG} nvcc --version"
    print_status "  docker run --rm --gpus all ${IMAGE_NAME}:${TAG} nvidia-smi"
}

# Run main function
main "$@"
