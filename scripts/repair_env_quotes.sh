#!/bin/bash

# Emergency repair script for .env quotes issue
# Removes quotes from ALL variable values in .env

set -e

cd "$(dirname "$0")/.."

if [ ! -f ".env" ]; then
    echo "❌ ERROR: .env file not found"
    exit 1
fi

echo "🔧 Repairing .env file - removing quotes from all variables..."

# Create backup
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup created"

# Remove quotes from all variables
sed -i 's/^\([A-Z_]*=\)"\(.*\)"$/\1\2/' .env
sed -i "s/^\([A-Z_]*=\)'\(.*\)'$/\1\2/" .env

echo "✅ Quotes removed from .env"
echo ""
echo "Affected variables fixed:"
grep "^POSTGRES_PASSWORD\|^N8N_ENCRYPTION_KEY\|^CALCOM_" .env | head -5

echo ""
echo "🔄 Now restart ALL containers to load new values:"
echo "docker compose -p localai -f docker-compose.local.yml down"
echo "docker compose -p localai -f docker-compose.local.yml up -d"

exit 0
