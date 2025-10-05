#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

export DEBIAN_FRONTEND=noninteractive

log_info "Checking NVIDIA GPU availability..."

# Check if nvidia-smi exists (NVIDIA driver installed)
if ! command -v nvidia-smi &> /dev/null; then
    log_error "NVIDIA GPU drivers not found!"
    log_info "Please install NVIDIA drivers first:"
    log_info "  https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/"
    log_info ""
    log_info "You can also install via:"
    log_info "  sudo ubuntu-drivers install"
    exit 1
fi

# Check if GPU is accessible
if ! nvidia-smi &> /dev/null; then
    log_error "nvidia-smi failed - GPU not accessible"
    log_info "Check driver installation: nvidia-smi"
    exit 1
fi

log_success "✅ NVIDIA GPU detected:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | while read line; do
    log_info "  - $line"
done

# Check if NVIDIA Container Toolkit already installed
if command -v nvidia-ctk &> /dev/null; then
    log_success "✅ NVIDIA Container Toolkit already installed"
    nvidia-ctk --version
    
    # Verify Docker configuration
    if docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
        log_success "✅ Docker GPU access verified"
    else
        log_warning "⚠️ Docker GPU access test failed, reconfiguring..."
        nvidia-ctk runtime configure --runtime=docker
        systemctl restart docker
        sleep 3
    fi
    
    exit 0
fi

log_info "Installing NVIDIA Container Toolkit..."
echo ""
log_info "This will:"
log_info "  1. Add NVIDIA Container Toolkit repository"
log_info "  2. Install nvidia-container-toolkit packages"
log_info "  3. Configure Docker for GPU access"
log_info "  4. Restart Docker daemon"
log_info "  5. Verify GPU access with test container"
echo ""

# Configure the production repository
log_info "Adding NVIDIA Container Toolkit repository..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package list
log_info "Updating package list..."
apt-get update -qq

# Install NVIDIA Container Toolkit
log_info "Installing NVIDIA Container Toolkit packages..."
apt-get install -y nvidia-container-toolkit

log_success "✅ NVIDIA Container Toolkit installed"

# Configure Docker runtime
log_info "Configuring Docker for GPU access..."
nvidia-ctk runtime configure --runtime=docker

# Restart Docker to apply changes
log_info "Restarting Docker daemon..."
systemctl restart docker
sleep 5

# Wait for Docker to be ready
log_info "Waiting for Docker to be ready..."
timeout=30
elapsed=0
while ! docker info > /dev/null 2>&1; do
    sleep 1
    elapsed=$((elapsed + 1))
    if [ $elapsed -gt $timeout ]; then
        log_error "Docker failed to start after configuration"
        exit 1
    fi
done

log_success "✅ Docker daemon restarted successfully"

# Verify GPU access in Docker
log_info "Verifying GPU access in Docker containers..."
if docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi; then
    echo ""
    log_success "✅ NVIDIA Container Toolkit successfully configured!"
    log_success "✅ Docker can now access your GPUs"
else
    log_error "GPU access test failed"
    log_info "Try manually: docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi"
    exit 1
fi

exit 0
