# Cal.com Setup and Integration Guide

## Table of Contents
- [Initial Setup](#initial-setup)
- [Google Calendar Integration](#google-calendar-integration)
- [Other Integrations](#other-integrations)
- [Troubleshooting](#troubleshooting)
- [Configuration Options](#configuration-options)

## Initial Setup

After AI LaunchKit installation, Cal.com is available at `https://cal.yourdomain.com`

### First Steps
1. **Create Admin Account**: The first user to register becomes the admin
2. **Complete Profile**: Add name, timezone, and availability
3. **Create Event Types**: Set up meeting types (15min, 30min, 60min)
4. **Share Booking Link**: `https://cal.yourdomain.com/YOUR-USERNAME`

### Email Configuration
Cal.com uses AI LaunchKit's mail system automatically:
- **Development**: Mailpit captures all emails locally
- **Production**: Postal sends real emails (requires DNS setup)

## Google Calendar Integration

Google Calendar integration allows:
- Automatic availability checking
- Event creation in Google Calendar
- Conflict prevention across calendars

### Prerequisites
- Google Account
- Access to Google Cloud Console
- Cal.com instance running

### Step-by-Step Setup

#### 1. Create Google Cloud Project

1. Navigate to [Google Cloud Console](https://console.cloud.google.com)
2. Click **Select a project** → **New Project**
3. Name: `Cal.com Integration`
4. Click **Create**

#### 2. Enable Google Calendar API

1. In your project, go to **APIs & Services** → **Library**
2. Search for "Google Calendar API"
3. Click on it and press **ENABLE**
4. Wait for activation

#### 3. Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. User Type: Select **External**
3. Fill in the required fields:
   - App name: `Cal.com`
   - User support email: Your email
   - Authorized domains: Add your domain (e.g., `yourdomain.com`)
   - Developer contact: Your email
4. Click **Save and Continue**
5. **Scopes**: Click **Add or Remove Scopes**
   - Search and select:
     - `.../auth/calendar`
     - `.../auth/calendar.events`
   - Click **Update**
6. **Test users**: Add your email
7. **Save and Continue**

#### 4. Create OAuth 2.0 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Application type: **Web application**
4. Name: `Cal.com OAuth`
5. **Authorized redirect URIs** - Add BOTH:
   ```
   https://cal.yourdomain.com/api/integrations/googlecalendar/callback
   https://cal.yourdomain.com/api/auth/callback/google
   ```
6. Click **Create**
7. **IMPORTANT**: Save the Client ID and Client Secret

#### 5. Add Credentials to Cal.com

##### Method A: Environment Variables (Rebuild Required)

1. Stop Cal.com:
   ```bash
   sudo docker compose -p localai stop calcom
   ```

2. Add to your `.env` file:
   ```bash
   GOOGLE_CLIENT_ID=your_client_id_here
   GOOGLE_CLIENT_SECRET=your_client_secret_here
   ```

3. Update build script to include Google credentials:
   ```bash
   cd ~/ai-launchkit
   nano scripts/build_calcom.sh
   ```

   Add after the PostgreSQL password extraction:
   ```bash
   # Google Calendar Integration
   GOOGLE_CLIENT_ID=$(sed -n "s/^GOOGLE_CLIENT_ID=//p" ../.env | sed "s/['\"]//g")
   GOOGLE_CLIENT_SECRET=$(sed -n "s/^GOOGLE_CLIENT_SECRET=//p" ../.env | sed "s/['\"]//g")
   
   if [[ -n "$GOOGLE_CLIENT_ID" && -n "$GOOGLE_CLIENT_SECRET" ]]; then
       echo "# Google Calendar Integration" >> .env
       echo "GOOGLE_API_CREDENTIALS='{\"web\":{\"client_id\":\"${GOOGLE_CLIENT_ID}\",\"client_secret\":\"${GOOGLE_CLIENT_SECRET}\",\"redirect_uris\":[\"https://cal.${DOMAIN}/api/integrations/googlecalendar/callback\"]}}'" >> .env
   fi
   ```

4. Rebuild Cal.com:
   ```bash
   sudo bash scripts/build_calcom.sh
   sudo docker compose -p localai build --no-cache calcom
   sudo docker compose -p localai up -d calcom
   ```

##### Method B: Database Update (Advanced)

For existing installations without rebuild:
```bash
# Connect to PostgreSQL
sudo docker exec -it postgres psql -U postgres -d calcom

# Insert Google Calendar app credentials
INSERT INTO "App" (slug, keys, enabled)
VALUES (
  'google-calendar',
  '{"client_id":"YOUR_CLIENT_ID","client_secret":"YOUR_SECRET","redirect_uris":["https://cal.yourdomain.com/api/integrations/googlecalendar/callback"]}',
  true
)
ON CONFLICT (slug) DO UPDATE
SET keys = EXCLUDED.keys;
```

#### 6. Enable in Cal.com

1. Log into Cal.com as admin
2. Go to **Settings** → **Admin** → **Apps**
3. Find "Google Calendar"
4. Click **Install**
5. Authorize access to your Google account

## Other Integrations

### Zoom Integration

1. Create Zoom OAuth App at [marketplace.zoom.us](https://marketplace.zoom.us)
2. Add redirect URI: `https://cal.yourdomain.com/api/integrations/zoom/callback`
3. Add credentials to `.env`:
   ```bash
   ZOOM_CLIENT_ID=your_zoom_client_id
   ZOOM_CLIENT_SECRET=your_zoom_client_secret
   ```
4. Rebuild Cal.com

### Stripe Payment Integration

For paid bookings:
1. Get Stripe API keys from [dashboard.stripe.com](https://dashboard.stripe.com)
2. Add to `.env`:
   ```bash
   STRIPE_PUBLIC_KEY=pk_live_xxx
   STRIPE_PRIVATE_KEY=sk_live_xxx
   STRIPE_WEBHOOK_SECRET=whsec_xxx
   PAYMENT_FEE_PERCENTAGE=0.05
   PAYMENT_FEE_FIXED=30
   ```
3. Configure webhook endpoint in Stripe: `https://cal.yourdomain.com/api/webhooks/stripe`

### Microsoft Calendar (Office 365)

1. Register app in [Azure Portal](https://portal.azure.com)
2. Add redirect URI: `https://cal.yourdomain.com/api/integrations/office365calendar/callback`
3. Add to `.env`:
   ```bash
   MS_GRAPH_CLIENT_ID=your_client_id
   MS_GRAPH_CLIENT_SECRET=your_secret
   ```

## Troubleshooting

### Common Issues

#### "Invalid type in client_id" Error
**Cause**: Google credentials not properly configured
**Solution**: Follow the Google Calendar Integration steps above

#### URL redirects to "https://cal./" 
**Cause**: DOMAIN variable not set correctly during build
**Solution**: 
1. Check `.env` has both `USER_DOMAIN_NAME` and `DOMAIN` set
2. Rebuild Cal.com completely

#### "Something went wrong" on login
**Cause**: Database connection or NextAuth configuration issue
**Solution**:
1. Check PostgreSQL is running: `docker ps | grep postgres`
2. Verify NEXTAUTH_URL matches your domain
3. Check logs: `docker logs calcom`

#### Google Calendar "redirect_uri_mismatch"
**Cause**: Redirect URIs in Google Cloud don't match exactly
**Solution**: 
1. Ensure URIs in Google Cloud Console match EXACTLY (including https://)
2. No trailing slashes
3. Check for typos in domain

#### Emails not sending
**Cause**: Mail configuration incorrect
**Solution**:
1. Check mail mode: `grep MAIL_MODE .env`
2. For development: Check Mailpit at `https://mail.yourdomain.com`
3. For production: Ensure Postal is configured with proper DNS

### Debug Commands

```bash
# Check Cal.com environment variables
sudo docker exec calcom env | grep -E "NEXT_PUBLIC|DATABASE|GOOGLE"

# View Cal.com logs
sudo docker logs -f calcom --tail 100

# Check database connection
sudo docker exec postgres psql -U postgres -d calcom -c "\dt"

# Restart Cal.com
sudo docker compose -p localai restart calcom

# Force rebuild
sudo docker compose -p localai build --no-cache calcom
```

## Configuration Options

### Environment Variables

Key variables that can be configured:

```bash
# Basic Configuration
NEXT_PUBLIC_WEBAPP_URL=https://cal.yourdomain.com
NEXTAUTH_URL=https://cal.yourdomain.com
NEXTAUTH_SECRET=<auto-generated>
CALENDSO_ENCRYPTION_KEY=<auto-generated>

# Features
NEXT_PUBLIC_DISABLE_SIGNUP=false  # Set to true to disable new signups
TELEMETRY_DISABLED=1

# Integrations (all optional)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
ZOOM_CLIENT_ID=
ZOOM_CLIENT_SECRET=
STRIPE_PUBLIC_KEY=
STRIPE_PRIVATE_KEY=
MS_GRAPH_CLIENT_ID=
MS_GRAPH_CLIENT_SECRET=

# Email Configuration (uses AI LaunchKit mail system)
EMAIL_FROM=noreply@yourdomain.com
EMAIL_SERVER_HOST=mailpit  # or postal for production
EMAIL_SERVER_PORT=1025      # or 25 for postal
```

### Performance Tuning

For larger installations:
```bash
# Add to docker-compose.yml under calcom service:
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 1G
```

### Backup Strategy

Regular backups recommended:
```bash
# Backup Cal.com database
sudo docker exec postgres pg_dump -U postgres calcom > calcom_backup_$(date +%Y%m%d).sql

# Restore from backup
sudo docker exec -i postgres psql -U postgres calcom < calcom_backup_20250903.sql
```

## Additional Resources

- [Cal.com Documentation](https://cal.com/docs)
- [Cal.com GitHub](https://github.com/calcom/cal.com)
- [Cal.com Discord Community](https://discord.gg/calcom)
- [AI LaunchKit Repository](https://github.com/freddy-schuetz/ai-launchkit)

## Support

For AI LaunchKit specific issues:
- Open issue on [GitHub](https://github.com/freddy-schuetz/ai-launchkit/issues)

For Cal.com specific issues:
- Check [Cal.com GitHub Issues](https://github.com/calcom/cal.com/issues)
- Join [Cal.com Discord](https://discord.gg/calcom)
