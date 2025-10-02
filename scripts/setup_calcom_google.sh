#!/bin/bash

# Check if Google credentials are in .env
GOOGLE_CLIENT_ID=$(grep "^GOOGLE_CLIENT_ID=" .env | cut -d '=' -f2 | tr -d '"')
GOOGLE_CLIENT_SECRET=$(grep "^GOOGLE_CLIENT_SECRET=" .env | cut -d '=' -f2 | tr -d '"')
DOMAIN=$(grep "^USER_DOMAIN_NAME=" .env | cut -d '=' -f2 | tr -d '"')

if [[ -n "$GOOGLE_CLIENT_ID" && -n "$GOOGLE_CLIENT_SECRET" ]]; then
    echo "Setting up Google Calendar integration in Cal.com database..."
    
    # Wait for Cal.com to be ready
    sleep 10
    
    # Insert Google Calendar app into database
    docker exec postgres psql -U postgres -d calcom -c "
    INSERT INTO \"App\" (slug, keys, enabled, \"dirName\", \"createdAt\", \"updatedAt\")
    VALUES (
        'google-calendar',
        '{\"client_id\":\"${GOOGLE_CLIENT_ID}\",\"client_secret\":\"${GOOGLE_CLIENT_SECRET}\",\"redirect_uris\":[\"https://cal.${DOMAIN}/api/integrations/googlecalendar/callback\",\"https://cal.${DOMAIN}/api/auth/callback/google\"]}',
        true,
        'googlecalendar',
        NOW(),
        NOW()
    )
    ON CONFLICT (slug) DO UPDATE 
    SET keys = EXCLUDED.keys, 
        enabled = true,
        \"updatedAt\" = NOW();"
    
    echo "Google Calendar integration configured!"
else
    echo "No Google credentials found in .env - skipping"
fi
