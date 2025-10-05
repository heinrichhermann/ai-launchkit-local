#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Check for nested n8n-installer directory
current_path=$(pwd)
if [[ "$current_path" == *"/n8n-installer/n8n-installer" ]]; then
    log_info "Detected nested n8n-installer directory. Correcting..."
    cd ..
    log_info "Moved to $(pwd)"
    log_info "Removing redundant n8n-installer directory..."
    rm -rf "n8n-installer"
    log_info "Redundant directory removed."
    SCRIPT_DIR_REALPATH_TEMP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    if [[ "$SCRIPT_DIR_REALPATH_TEMP" == *"/n8n-installer/n8n-installer/scripts" ]]; then
        log_info "Re-executing install script from corrected path..."
        exec sudo bash "./scripts/install_local.sh" "$@"
    fi
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if all required scripts exist and are executable
required_scripts=(
    "01_system_preparation.sh"
    "02_install_docker.sh"
    "03_generate_secrets_local.sh"
    "04_wizard_local.sh"
    "05_run_services_local.sh"
    "06_final_report_local.sh"
)

missing_scripts=()
non_executable_scripts=()

for script in "${required_scripts[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [ ! -f "$script_path" ]; then
        missing_scripts+=("$script")
    elif [ ! -x "$script_path" ]; then
        non_executable_scripts+=("$script")
    fi
done

if [ ${#missing_scripts[@]} -gt 0 ]; then
    log_error "The following required scripts are missing in $SCRIPT_DIR:"
    printf " - %s\n" "${missing_scripts[@]}"
    exit 1
fi

# Make scripts executable if needed
if [ ${#non_executable_scripts[@]} -gt 0 ]; then
    log_warning "Making scripts executable:"
    printf " - %s\n" "${non_executable_scripts[@]}"
    chmod +x "$SCRIPT_DIR"/*.sh
fi

# Welcome message for local network deployment
echo ""
log_info "🚀 AI LaunchKit - Local Network Installation"
echo "=============================================="
echo ""
log_info "This installation configures AI LaunchKit for local network access:"
log_info "  ✅ No domain configuration needed"
log_info "  ✅ No SSL certificates required" 
log_info "  ✅ No modifications to host system"
log_info "  ✅ All services accessible via IP:PORT"
log_info "  ✅ Complete Docker containerization"
echo ""
log_info "Services will be accessible at http://SERVER_IP:PORT"
log_info "Port range: 8000-8099 (avoiding 9443 used by Portainer)"
echo ""

# Run installation steps sequentially
log_info "========== STEP 1: System Preparation =========="
bash "$SCRIPT_DIR/01_system_preparation.sh" || { log_error "System Preparation failed"; exit 1; }
log_success "System preparation complete!"

log_info "========== STEP 2: Installing Docker =========="
bash "$SCRIPT_DIR/02_install_docker.sh" || { log_error "Docker Installation failed"; exit 1; }
log_success "Docker installation complete!"

log_info "========== STEP 3: Generating Local Network Configuration =========="
bash "$SCRIPT_DIR/03_generate_secrets_local.sh" || { log_error "Local Config Generation failed"; exit 1; }
log_success "Local network configuration complete!"

log_info "========== STEP 4: Running Service Selection Wizard =========="
bash "$SCRIPT_DIR/04_wizard_local.sh" || { log_error "Service Selection Wizard failed"; exit 1; }
log_success "Service selection complete!"

log_info "========== STEP 4a: Setting up Perplexica (if selected) =========="
bash "$SCRIPT_DIR/04a_setup_perplexica.sh" || { log_error "Perplexica setup failed"; exit 1; }
log_success "Perplexica setup complete!"

log_info "========== STEP 4b: Building Cal.com (if selected) =========="
# Check if calcom profile is in COMPOSE_PROFILES
if grep -q "calcom" .env 2>/dev/null || [[ "$COMPOSE_PROFILES" == *"calcom"* ]]; then
    if [ -f "$SCRIPT_DIR/build_calcom.sh" ]; then
        log_info "Cal.com selected - preparing build..."
        bash "$SCRIPT_DIR/build_calcom.sh" || { log_error "Cal.com build preparation failed"; exit 1; }
    else
        log_warning "Cal.com selected but build script not found"
    fi
else
    log_info "Cal.com not selected, skipping build"
fi
log_success "Cal.com build step complete!"

log_info "========== STEP 5: Running Services (Local Network Mode) =========="
bash "$SCRIPT_DIR/05_run_services_local.sh" || { log_error "Running Services failed"; exit 1; }
log_success "Services started successfully!"

# NO SSL/Domain setup needed for local network
log_info "========== Skipping SSL/Domain Configuration (Local Network) =========="
log_info "SSL certificates not needed for local network access"

# NO Docker-Mailserver DKIM setup (using Mailpit for local)
log_info "========== Mail Configuration (Local Network) =========="
log_info "Using Mailpit for email capture (no external mail delivery)"
log_info "All service emails will be visible at http://SERVER_IP:8071"

log_info "========== STEP 6: Generating Local Network Access Report =========="
log_info "Installation Summary for Local Network Deployment:"
log_success "- System updated and Docker installed"
log_success "- Firewall configured for local network access"
log_success "- Local network configuration generated (.env)"
log_success "- Services launched with port-based access"
log_success "- No domain or SSL configuration needed"

bash "$SCRIPT_DIR/06_final_report_local.sh" || { log_error "Final Report Generation failed"; exit 1; }
log_success "Installation complete!"

echo ""
log_info "🎉 AI LaunchKit Local Network Installation Complete!"
echo ""
log_info "Your AI development stack is now running!"
log_info "Access your services at http://SERVER_IP:PORT"
log_info "See the final report above for all service URLs and ports"
echo ""
log_info "To change the SERVER_IP for network access:"
log_info "  1. Edit the SERVER_IP variable in .env"
log_info "  2. Restart services: docker compose -p localai -f docker-compose.local.yml restart"
echo ""

# Ensure Portainer is installed for Docker management
log_info "========== Ensuring Portainer Installation =========="
if ! docker ps -a | grep -q "portainer"; then
    log_info "Installing Portainer for Docker management..."
    
    # Create Portainer volume
    docker volume create portainer_data 2>/dev/null || true
    
    # Install Portainer
    docker run -d \
        -p 9443:9443 \
        --name=portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    
    log_success "✅ Portainer installed successfully!"
    log_info "   Access Portainer at: https://localhost:9443"
    log_info "   (Create admin account on first login)"
elif ! docker ps | grep -q "portainer"; then
    log_info "Starting existing Portainer..."
    docker start portainer
    log_success "✅ Portainer started at: https://localhost:9443"
else
    log_success "✅ Portainer already running at: https://localhost:9443"
fi

# Start background monitoring if available
if docker ps | grep -q grafana; then
    log_info "📊 Monitoring dashboard available at: http://SERVER_IP:8003"
fi

echo ""
log_info "🐳 Portainer Docker Management UI: https://localhost:9443"

exit 0
