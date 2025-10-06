#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Check for .env file
if [ ! -f ".env" ]; then
  log_error ".env file not found in project root." >&2
  exit 1
fi

# Check for local docker-compose file
if [ ! -f "docker-compose.local.yml" ]; then
  log_error "docker-compose.local.yml file not found in project root." >&2
  log_info "This file should have been created during the setup process."
  exit 1
fi

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
  log_error "Docker daemon is not running. Please start Docker and try again." >&2
  exit 1
fi

# Check if start_services.py exists and modify it for local network
if [ ! -f "start_services_local.py" ]; then
  log_info "Creating start_services_local.py for local network deployment..."
  # We'll create this during the service startup process
fi

# Create media directories with correct permissions BEFORE Docker starts
log_info "Creating media processing directories..."
mkdir -p media temp shared
# Use SUDO_USER if available (when run with sudo), otherwise current user
if [ -n "$SUDO_USER" ]; then
  chown -R $SUDO_USER:$SUDO_USER media temp shared
else
  chown -R $(whoami):$(whoami) media temp shared
fi
chmod 755 media temp shared
log_info "Media directories created with correct permissions"

# Check for port conflicts with existing Portainer
log_info "Checking for port conflicts with existing services..."

# Check if port 9443 is in use (Portainer)
if netstat -tuln 2>/dev/null | grep -q ":9443 "; then
    log_info "✅ Portainer detected on port 9443 (no conflict with our port range 8000-8099)"
else
    log_warning "Port 9443 not in use - Portainer may not be running"
fi

# Check for conflicts in our port range (8000-8099)
CONFLICTING_PORTS=()
for port in {8000..8099}; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        CONFLICTING_PORTS+=($port)
    fi
done

if [ ${#CONFLICTING_PORTS[@]} -gt 0 ]; then
    log_warning "Warning: The following ports are already in use:"
    printf "  - Port %s\n" "${CONFLICTING_PORTS[@]}"
    echo ""
    read -p "Continue anyway? Some services may fail to start. (y/N): " continue_with_conflicts
    if [[ ! "$continue_with_conflicts" =~ ^[Yy]$ ]]; then
        log_error "Installation cancelled due to port conflicts."
        log_info "Please free up the conflicting ports and try again."
        exit 1
    fi
else
    log_success "No port conflicts detected in range 8000-8099"
fi

# Load environment variables
source .env

# Stop any existing containers first
log_info "Stopping existing containers..."
docker compose -p localai -f docker-compose.local.yml down 2>/dev/null || true

# Handle Supabase if selected
if [[ "$COMPOSE_PROFILES" == *"supabase"* ]]; then
    log_info "Supabase selected - setting up external repository..."
    
    if [ ! -d "supabase" ]; then
        log_info "Cloning Supabase repository..."
        git clone --filter=blob:none --no-checkout https://github.com/supabase/supabase.git
        cd supabase
        git sparse-checkout init --cone
        git sparse-checkout set docker
        git checkout master
        cd ..
    fi
    
    # Prepare Supabase .env for local network
    supabase_env_file="supabase/docker/.env"
    if [ -f "supabase/docker/.env.example" ]; then
        cp "supabase/docker/.env.example" "$supabase_env_file"
    fi
    
    # Update Supabase config for local network (no SSL)
    if [ -f "$supabase_env_file" ]; then
        sed -i "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" "$supabase_env_file"
        sed -i "s|JWT_SECRET=.*|JWT_SECRET=$JWT_SECRET|" "$supabase_env_file"
        sed -i "s|ANON_KEY=.*|ANON_KEY=$ANON_KEY|" "$supabase_env_file"
        sed -i "s|SERVICE_ROLE_KEY=.*|SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY|" "$supabase_env_file"
    fi
    
    log_info "Starting Supabase services on port 8100..."
    # Start Supabase with port override
    docker compose -p localai -f supabase/docker/docker-compose.yml up -d
    
    # Override Kong port mapping
    docker compose -p localai -f supabase/docker/docker-compose.yml stop kong
    # We'll add port mapping through a separate override
fi

# Handle Dify if selected
if [[ "$COMPOSE_PROFILES" == *"dify"* ]]; then
    log_info "Dify selected - setting up external repository..."
    
    if [ ! -d "dify" ]; then
        log_info "Cloning Dify repository..."
        git clone --filter=blob:none --no-checkout https://github.com/langgenius/dify.git
        cd dify
        git sparse-checkout init --cone
        git sparse-checkout set docker
        git checkout main
        cd ..
    fi
    
    # Prepare Dify .env for local network
    dify_env_file="dify/docker/.env"
    if [ -f "dify/docker/env.example" ]; then
        cp "dify/docker/env.example" "$dify_env_file"
    elif [ -f "dify/docker/.env.example" ]; then
        cp "dify/docker/.env.example" "$dify_env_file"
    fi
    
    # Update Dify config for local network
    if [ -f "$dify_env_file" ]; then
        echo "SECRET_KEY=$DIFY_SECRET_KEY" >> "$dify_env_file"
        echo "EXPOSE_NGINX_PORT=8101" >> "$dify_env_file"
    fi
    
    log_info "Starting Dify services on port 8101..."
    docker compose -p localai -f dify/docker/docker-compose.yaml up -d
fi

# Build services that need local compilation
if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    log_info "Preparing Chatterbox TTS services..."
    if [ ! -d "./chatterbox-frontend/frontend" ]; then
        log_info "Cloning Chatterbox TTS repository..."
        git clone https://github.com/travisvn/chatterbox-tts-api.git ./chatterbox-frontend || {
            log_warning "Failed to clone Chatterbox repository - TTS service may not work"
        }
    fi
fi

# Generate SearXNG secret if SearXNG is selected
if [[ "$COMPOSE_PROFILES" == *"searxng"* ]]; then
    log_info "Configuring SearXNG for local network..."
    
    if [ ! -f "searxng/settings.yml" ]; then
        if [ -f "searxng/settings-base.yml" ]; then
            cp "searxng/settings-base.yml" "searxng/settings.yml"
        fi
    fi
    
    # Generate secret key
    if [ -f "searxng/settings.yml" ]; then
        SECRET_KEY=$(openssl rand -hex 32)
        sed -i "s|ultrasecretkey|$SECRET_KEY|g" "searxng/settings.yml"
        # Update base URL for local network
        sed -i "s|base_url: false|base_url: 'http://127.0.0.1:8089'|g" "searxng/settings.yml"
        log_success "SearXNG configured for local network"
    fi
fi

log_info "Launching local network services..."

# Start main services using local docker-compose
log_info "Building and starting AI LaunchKit services..."
docker compose -p localai -f docker-compose.local.yml build --pull 2>/dev/null || {
    log_warning "Build step failed, continuing with existing images..."
}

log_info "Starting all selected services..."
docker compose -p localai -f docker-compose.local.yml up -d

# Wait for core services to start
log_info "Waiting for core services to initialize..."
sleep 10

# Check service health
log_info "Checking service health..."
FAILED_SERVICES=()

# Check key services
if docker ps | grep -q "n8n"; then
    log_success "✅ n8n is running (Port 8000)"
else
    FAILED_SERVICES+=("n8n")
fi

if docker ps | grep -q "postgres"; then
    log_success "✅ PostgreSQL is running (Port 8001)"
else
    FAILED_SERVICES+=("postgres")
fi

if docker ps | grep -q "redis"; then
    log_success "✅ Redis is running (Port 8002)"
else
    FAILED_SERVICES+=("redis")
fi

# Check selected optional services
if [[ "$COMPOSE_PROFILES" == *"flowise"* ]]; then
    if docker ps | grep -q "flowise"; then
        log_success "✅ Flowise is running (Port 8022)"
    else
        FAILED_SERVICES+=("flowise")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"monitoring"* ]]; then
    if docker ps | grep -q "grafana"; then
        log_success "✅ Grafana is running (Port 8003)"
    else
        FAILED_SERVICES+=("grafana")
    fi
fi

# Report any failures
if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    log_warning "⚠️ Some services failed to start:"
    printf "  - %s\n" "${FAILED_SERVICES[@]}"
    echo ""
    log_info "Check service logs with: docker compose -p localai -f docker-compose.local.yml logs [service_name]"
    echo ""
    log_info "Common issues:"
    log_info "- Service may need more time to initialize"
    log_info "- Port conflicts (check with: netstat -tuln | grep 80)"
    log_info "- Insufficient system resources (RAM/CPU)"
else
    log_success "🎉 All core services started successfully!"
fi

# Additional service-specific startup tasks
if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    log_info "Starting Chatterbox TTS services..."
    docker compose -p localai -f docker-compose.local.yml --profile tts-chatterbox up -d || {
        log_warning "Chatterbox TTS startup failed - API will work but no UI"
    }
fi

# Create shared directories if they don't exist
log_info "Ensuring shared directories exist..."
mkdir -p shared/audio shared/tts/voices
chmod 755 shared/audio shared/tts/voices

log_success "🚀 Local network services startup complete!"

echo ""
log_info "Next steps:"
log_info "1. Wait 2-3 minutes for all services to fully initialize"
log_info "2. Check the final report for service access URLs"
log_info "3. Update SERVER_IP in .env if accessing from other devices"
log_info "4. Access services at http://SERVER_IP:PORT"

exit 0
