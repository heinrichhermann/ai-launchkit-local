#!/usr/bin/env python3
"""
start_services_local.py

Local network version of the service startup script.
This script starts services for local network access (IP:PORT) instead of domain-based access.
No SSL certificates, no Caddy reverse proxy, no domain configuration needed.
"""

import os
import subprocess
import shutil
import time
import argparse
import platform
import sys
import yaml
from dotenv import dotenv_values

def check_port_conflicts():
    """Check for port conflicts in the range 8000-8099 before starting services."""
    print("Checking for port conflicts in range 8000-8099...")
    
    conflicting_ports = []
    
    # Check each port in our range
    for port in range(8000, 8100):
        try:
            result = subprocess.run(
                ["netstat", "-tuln"], 
                capture_output=True, 
                text=True, 
                check=False
            )
            if f":{port} " in result.stdout:
                conflicting_ports.append(port)
        except Exception:
            # If netstat fails, continue anyway
            pass
    
    if conflicting_ports:
        print(f"⚠️ Warning: Ports in use: {conflicting_ports}")
        print("Some services may fail to start due to port conflicts.")
        print("Consider stopping conflicting services or changing ports.")
        
        response = input("Continue anyway? (y/N): ").lower()
        if response != 'y':
            print("Installation cancelled.")
            sys.exit(1)
    else:
        print("✅ No port conflicts detected.")

def is_supabase_enabled():
    """Check if 'supabase' is in COMPOSE_PROFILES in .env file."""
    env_values = dotenv_values(".env")
    compose_profiles = env_values.get("COMPOSE_PROFILES", "")
    return "supabase" in compose_profiles.split(',')

def is_dify_enabled():
    """Check if 'dify' is in COMPOSE_PROFILES in .env file."""
    env_values = dotenv_values(".env")
    compose_profiles = env_values.get("COMPOSE_PROFILES", "")
    return "dify" in compose_profiles.split(',')

def get_all_profiles(compose_file):
    """Get all profile names from a docker-compose file."""
    if not os.path.exists(compose_file):
        return []
    
    with open(compose_file, 'r') as f:
        compose_config = yaml.safe_load(f)

    profiles = set()
    if 'services' in compose_config:
        for service_name, service_config in compose_config.get('services', {}).items():
            if service_config and 'profiles' in service_config:
                for profile in service_config['profiles']:
                    profiles.add(profile)
    return list(profiles)

def run_command(cmd, cwd=None):
    """Run a shell command and print it."""
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, cwd=cwd, check=True)

def clone_supabase_repo():
    """Clone the Supabase repository for local network deployment."""
    if not is_supabase_enabled():
        print("Supabase is not enabled, skipping clone.")
        return
        
    if not os.path.exists("supabase"):
        print("Cloning the Supabase repository...")
        run_command([
            "git", "clone", "--filter=blob:none", "--no-checkout",
            "https://github.com/supabase/supabase.git"
        ])
        os.chdir("supabase")
        run_command(["git", "sparse-checkout", "init", "--cone"])
        run_command(["git", "sparse-checkout", "set", "docker"])
        run_command(["git", "checkout", "master"])
        os.chdir("..")
    else:
        print("Supabase repository already exists, updating...")
        os.chdir("supabase")
        run_command(["git", "pull"])
        os.chdir("..")

def prepare_supabase_env():
    """Create proper Supabase .env for local network (HTTP-only)."""
    if not is_supabase_enabled():
        print("Supabase is not enabled, skipping env preparation.")
        return
    
    supabase_docker_dir = os.path.join("supabase", "docker")
    
    # Copy the example file
    env_example_path = os.path.join(supabase_docker_dir, ".env.example")
    env_path = os.path.join(supabase_docker_dir, ".env")
    
    if os.path.exists(env_example_path):
        print(f"Creating {env_path} from {env_example_path}...")
        shutil.copyfile(env_example_path, env_path)
    
    # Load values from root .env
    root_env = dotenv_values(".env")
    
    # Get required values
    postgres_password = root_env.get("POSTGRES_PASSWORD", "")
    jwt_secret = root_env.get("JWT_SECRET", "")
    anon_key = root_env.get("ANON_KEY", "")
    service_key = root_env.get("SERVICE_ROLE_KEY", "")
    
    # Update Supabase .env with local network configuration
    with open(env_path, 'r') as f:
        lines = f.readlines()
    
    new_lines = []
    for line in lines:
        if line.startswith("POSTGRES_PASSWORD="):
            new_lines.append(f"POSTGRES_PASSWORD={postgres_password}\n")
        elif line.startswith("JWT_SECRET="):
            new_lines.append(f"JWT_SECRET={jwt_secret}\n")
        elif line.startswith("ANON_KEY="):
            new_lines.append(f"ANON_KEY={anon_key}\n")
        elif line.startswith("SERVICE_ROLE_KEY="):
            new_lines.append(f"SERVICE_ROLE_KEY={service_key}\n")
        elif line.startswith("DASHBOARD_USERNAME="):
            new_lines.append(f"DASHBOARD_USERNAME=admin\n")
        elif line.startswith("DASHBOARD_PASSWORD="):
            dashboard_pass = root_env.get("DASHBOARD_PASSWORD", "admin123")
            new_lines.append(f"DASHBOARD_PASSWORD={dashboard_pass}\n")
        # Override URLs to use HTTP (no SSL)
        elif line.startswith("SITE_URL="):
            new_lines.append("SITE_URL=http://localhost:8100\n")
        elif line.startswith("API_EXTERNAL_URL="):
            new_lines.append("API_EXTERNAL_URL=http://localhost:8100\n")
        else:
            new_lines.append(line)
    
    # Write back
    with open(env_path, 'w') as f:
        f.writelines(new_lines)
    
    print("Supabase .env prepared for local network deployment (HTTP-only).")

def clone_dify_repo():
    """Clone the Dify repository for local network deployment."""
    if not is_dify_enabled():
        print("Dify is not enabled, skipping clone.")
        return
        
    if not os.path.exists("dify"):
        print("Cloning the Dify repository...")
        run_command([
            "git", "clone", "--filter=blob:none", "--no-checkout",
            "https://github.com/langgenius/dify.git"
        ])
        os.chdir("dify")
        run_command(["git", "sparse-checkout", "init", "--cone"])
        run_command(["git", "sparse-checkout", "set", "docker"])
        run_command(["git", "checkout", "main"])
        os.chdir("..")
    else:
        print("Dify repository already exists, updating...")
        os.chdir("dify")
        run_command(["git", "pull"])
        os.chdir("..")

def prepare_dify_env():
    """Create dify/docker/.env for local network deployment."""
    if not is_dify_enabled():
        print("Dify is not enabled, skipping env preparation.")
        return

    dify_docker_dir = os.path.join("dify", "docker")
    if not os.path.isdir(dify_docker_dir):
        print(f"Warning: Dify docker directory not found at {dify_docker_dir}")
        return

    # Find env example file
    env_example_candidates = [
        os.path.join(dify_docker_dir, "env.example"),
        os.path.join(dify_docker_dir, ".env.example"),
    ]
    env_example_path = next((p for p in env_example_candidates if os.path.exists(p)), None)

    if env_example_path is None:
        print(f"Warning: Could not find env.example in {dify_docker_dir}")
        return

    env_path = os.path.join(dify_docker_dir, ".env")
    print(f"Creating {env_path} from {env_example_path}...")
    
    with open(env_example_path, 'r') as f:
        env_content = f.read()

    # Load values from root .env
    root_env = dotenv_values(".env")
    
    # Configure for local network
    lines = env_content.splitlines()
    new_lines = []
    
    for line in lines:
        if line.startswith("SECRET_KEY="):
            secret_key = root_env.get("DIFY_SECRET_KEY", "")
            new_lines.append(f"SECRET_KEY={secret_key}")
        elif line.startswith("EXPOSE_NGINX_PORT="):
            new_lines.append("EXPOSE_NGINX_PORT=8101")
        elif line.startswith("EXPOSE_NGINX_SSL_PORT="):
            new_lines.append("EXPOSE_NGINX_SSL_PORT=")  # Disable SSL
        else:
            new_lines.append(line)
    
    # Add local network specific configuration
    new_lines.append("EXPOSE_NGINX_PORT=8101")
    new_lines.append("WEB_API_CORS_ALLOW_ORIGINS=*")  # Allow all origins for local network
    new_lines.append("CONSOLE_CORS_ALLOW_ORIGINS=*")

    with open(env_path, 'w') as f:
        f.write("\n".join(new_lines) + "\n")
    
    print("Dify .env prepared for local network deployment.")

def stop_existing_containers():
    """Stop and remove existing containers for the unified project 'localai'."""
    print("Stopping and removing existing containers for project 'localai'...")
    
    # Stop with all possible compose files
    base_cmd = ["docker", "compose", "-p", "localai"]
    
    # Main docker-compose file
    cmd = base_cmd + ["-f", "docker-compose.local.yml"]
    
    # Add profiles to ensure all services are stopped
    all_profiles = get_all_profiles("docker-compose.local.yml")
    for profile in all_profiles:
        cmd.extend(["--profile", profile])
    
    # Check for external compose files
    if os.path.exists("supabase/docker/docker-compose.yml"):
        cmd.extend(["-f", "supabase/docker/docker-compose.yml"])
    
    if os.path.exists("dify/docker/docker-compose.yaml"):
        cmd.extend(["-f", "dify/docker/docker-compose.yaml"])

    cmd.append("down")
    
    try:
        run_command(cmd)
    except subprocess.CalledProcessError:
        print("Warning: Some containers may not have been running.")

def start_supabase():
    """Start Supabase services with local network configuration."""
    if not is_supabase_enabled():
        print("Supabase is not enabled, skipping start.")
        return
        
    print("Starting Supabase services for local network...")
    
    # Start database first
    run_command([
        "docker", "compose", "-p", "localai", "-f", "supabase/docker/docker-compose.yml", 
        "up", "-d", "db"
    ])
    
    # Wait for db
    time.sleep(5)
    
    # Start all services
    run_command([
        "docker", "compose", "-p", "localai", "-f", "supabase/docker/docker-compose.yml", 
        "up", "-d"
    ])
    
    # Override Kong port mapping for local network access
    print("Configuring Kong Gateway for port 8100...")
    try:
        # Stop Kong to reconfigure it
        run_command([
            "docker", "compose", "-p", "localai", "-f", "supabase/docker/docker-compose.yml", 
            "stop", "kong"
        ])
        
        # Create Kong override for local network
        kong_override = """
version: '3.8'
services:
  kong:
    ports:
      - "8100:8000"
    environment:
      - KONG_PROXY_LISTEN=0.0.0.0:8000
"""
        
        with open("supabase-local-override.yml", "w") as f:
            f.write(kong_override)
            
        # Start Kong with override
        run_command([
            "docker", "compose", "-p", "localai", 
            "-f", "supabase/docker/docker-compose.yml",
            "-f", "supabase-local-override.yml",
            "up", "-d", "kong"
        ])
        
        print("✅ Supabase configured for local network access on port 8100")
        
    except Exception as e:
        print(f"Warning: Kong port override failed: {e}")
        print("Supabase may not be accessible on port 8100")

def start_dify():
    """Start Dify services with local network configuration."""
    if not is_dify_enabled():
        print("Dify is not enabled, skipping start.")
        return
    
    print("Starting Dify services for local network...")
    
    # Start database first
    print("Starting Dify database...")
    run_command([
        "docker", "compose", "-p", "localai", "-f", "dify/docker/docker-compose.yaml", 
        "up", "-d", "db"
    ])
    
    # Wait for database
    print("Waiting for Dify database to be ready...")
    time.sleep(5)
    
    # Create dify_plugin database if needed
    try:
        subprocess.run([
            "docker", "exec", "localai-db-1", "psql", "-U", "postgres", 
            "-c", "CREATE DATABASE dify_plugin;"
        ], capture_output=True, check=False)
        print("dify_plugin database created.")
    except Exception:
        print("Note: dify_plugin database may already exist.")
    
    # Start all Dify services
    print("Starting remaining Dify services...")
    run_command([
        "docker", "compose", "-p", "localai", "-f", "dify/docker/docker-compose.yaml", 
        "up", "-d"
    ])
    
    print("✅ Dify configured for local network access on port 8101")

def start_local_ai():
    """Start the main AI LaunchKit services using local docker-compose."""
    print("Starting AI LaunchKit services for local network...")

    # Build services first
    print("Building services and checking for updates...")
    try:
        build_cmd = ["docker", "compose", "-p", "localai", "-f", "docker-compose.local.yml", "build", "--pull"]
        run_command(build_cmd)
    except subprocess.CalledProcessError:
        print("Warning: Build step failed, continuing with existing images...")

    # Start services
    print("Starting all selected services...")
    up_cmd = ["docker", "compose", "-p", "localai", "-f", "docker-compose.local.yml", "up", "-d"]
    run_command(up_cmd)
    
    print("✅ AI LaunchKit services started for local network")

def generate_searxng_secret_key():
    """Generate a secret key for SearXNG and configure for local network."""
    print("Configuring SearXNG for local network...")

    settings_path = os.path.join("searxng", "settings.yml")
    settings_base_path = os.path.join("searxng", "settings-base.yml")

    # Create settings.yml from base if it doesn't exist
    if not os.path.exists(settings_path) and os.path.exists(settings_base_path):
        print(f"Creating SearXNG settings.yml from base...")
        shutil.copyfile(settings_base_path, settings_path)

    if not os.path.exists(settings_path):
        print("Warning: SearXNG settings files not found.")
        return

    print("Generating SearXNG secret key and configuring for local network...")

    try:
        # Generate secret key
        random_key = subprocess.check_output(["openssl", "rand", "-hex", "32"]).decode('utf-8').strip()
        
        # Update settings for local network
        system = platform.system()
        
        if system == "Darwin":  # macOS
            sed_cmd = ["sed", "-i", "", f"s|ultrasecretkey|{random_key}|g", settings_path]
            subprocess.run(sed_cmd, check=True)
            # Set base URL for local network
            sed_cmd2 = ["sed", "-i", "", "s|base_url: false|base_url: 'http://127.0.0.1:8089'|g", settings_path]
            subprocess.run(sed_cmd2, check=True)
        else:  # Linux
            sed_cmd = ["sed", "-i", f"s|ultrasecretkey|{random_key}|g", settings_path]
            subprocess.run(sed_cmd, check=True)
            # Set base URL for local network
            sed_cmd2 = ["sed", "-i", "s|base_url: false|base_url: 'http://127.0.0.1:8089'|g", settings_path]
            subprocess.run(sed_cmd2, check=True)

        print("✅ SearXNG configured for local network access.")

    except Exception as e:
        print(f"Error configuring SearXNG: {e}")

def wait_for_services():
    """Wait for key services to start and report status."""
    print("Waiting for services to initialize...")
    time.sleep(10)
    
    # Check key services
    key_services = [
        ("n8n", 8000),
        ("postgres", 8001),
        ("redis", 8002),
        ("flowise", 8022),
        ("grafana", 8003)
    ]
    
    print("\nChecking service health:")
    for service, port in key_services:
        try:
            # Check if container is running
            result = subprocess.run(
                ["docker", "ps", "--filter", f"name={service}", "--format", "{{.Names}}"],
                capture_output=True, text=True, check=False
            )
            
            if service in result.stdout:
                print(f"✅ {service} container is running")
                
                # Test port connectivity
                port_test = subprocess.run(
                    ["nc", "-z", "localhost", str(port)],
                    capture_output=True, check=False
                )
                
                if port_test.returncode == 0:
                    print(f"   🌐 Port {port} is responding")
                else:
                    print(f"   ⚠️ Port {port} not yet ready (may need more time)")
            else:
                print(f"❌ {service} container not found")
                
        except Exception as e:
            print(f"❌ Error checking {service}: {e}")

def main():
    print("🚀 AI LaunchKit - Local Network Startup")
    print("======================================")
    
    # Check for port conflicts first
    check_port_conflicts()
    
    # Prepare external repositories if needed
    if is_supabase_enabled():
        clone_supabase_repo()
        prepare_supabase_env()
    
    if is_dify_enabled():
        clone_dify_repo()
        prepare_dify_env()
    
    # Configure SearXNG for local network
    generate_searxng_secret_key()
    
    # Stop any existing containers
    stop_existing_containers()
    
    # Start services in order
    if is_supabase_enabled():
        start_supabase()
        print("Waiting for Supabase to initialize...")
        time.sleep(10)
    
    if is_dify_enabled():
        start_dify()
        print("Waiting for Dify to initialize...")
        time.sleep(10)
    
    # Start main AI LaunchKit services
    start_local_ai()
    
    # Wait and check service health
    wait_for_services()
    
    print("\n🎉 Local network service startup completed!")
    print("Check the final report for all service access URLs.")

if __name__ == "__main__":
    main()
