#!/bin/bash
#
# Generate landing page with correct SERVER_IP
# This replaces SERVER_IP placeholders with the actual IP from .env
#

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Check for .env file
if [ ! -f ".env" ]; then
  log_error ".env file not found in project root."
  exit 1
fi

# Load SERVER_IP from .env
source .env

if [ -z "$SERVER_IP" ]; then
  log_error "SERVER_IP not set in .env file"
  exit 1
fi

log_info "Generating landing page with SERVER_IP: $SERVER_IP"

# Create output directory if it doesn't exist
mkdir -p ./website

# Copy template and replace SERVER_IP
sed "s/SERVER_IP/${SERVER_IP}/g" templates/landing-page.html > ./website/index.html

log_success "Landing page generated at ./website/index.html"
log_info "The dashboard will serve this file at http://${SERVER_IP}/"
