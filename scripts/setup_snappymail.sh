#!/bin/bash
# Auto-configure SnappyMail domain after installation
# This should run after Docker containers are up

set -e
source "$(dirname "$0")/utils.sh"

# Check if SnappyMail is running
if ! docker ps | grep -q snappymail; then
    log_info "SnappyMail not running, skipping configuration"
    exit 0
fi

# Get domain from .env
BASE_DOMAIN=$(grep "^BASE_DOMAIN=" .env | cut -d'=' -f2 | tr -d '"')

if [ -z "$BASE_DOMAIN" ]; then
    log_error "BASE_DOMAIN not found in .env"
    exit 1
fi

# Check if domain already configured INSIDE container
DOMAIN_EXISTS=$(docker exec snappymail sh -c "[ -f /var/lib/snappymail/_data_/_default_/domains/${BASE_DOMAIN}.ini ] && echo 'yes' || echo 'no'" 2>/dev/null || echo "no")

if [ "$DOMAIN_EXISTS" = "yes" ]; then
    log_success "SnappyMail domain ${BASE_DOMAIN} already configured"
    exit 0
fi

log_info "Auto-configuring SnappyMail for domain: $BASE_DOMAIN"

# Wait for SnappyMail to be ready
sleep 10

# Create domain configuration file
docker exec snappymail sh -c "cat > /var/lib/snappymail/_data_/_default_/domains/${BASE_DOMAIN}.ini" << EOF
imap_host = "mailserver"
imap_port = 143
imap_secure = "None"
imap_short_login = Off
smtp_host = "mailserver"
smtp_port = 587
smtp_secure = "None"
smtp_short_login = Off
smtp_auth = On
smtp_php_mail = Off
white_list = ""
EOF

log_success "SnappyMail domain $BASE_DOMAIN configured automatically"
log_info "Users can now login with their email@${BASE_DOMAIN}"

# Show admin password for reference
echo ""
log_info "SnappyMail Admin Password (save this!):"
docker exec snappymail cat /var/lib/snappymail/_data_/_default_/admin_password.txt 2>/dev/null || echo "  (Password file not found)"
