# Postiz Social Media Providers Setup Guide

This guide explains how to configure social media providers for Postiz to enable posting to various platforms.

## 🎯 Overview

Postiz supports 16 social media providers. Each requires creating an app/bot in the provider's developer portal and adding the credentials to your `.env` file.

## 📋 Quick Reference Table

| Provider | Developer Portal | Required Credentials | Redirect URL Pattern |
|----------|-----------------|---------------------|---------------------|
| **Bluesky** | [bsky.app](https://bsky.app/settings/app-passwords) | Username + App Password | N/A (Direct auth) |
| **Discord** | [Discord Developer Portal](https://discord.com/developers/applications) | CLIENT_ID, CLIENT_SECRET, BOT_TOKEN | `${FRONTEND_URL}/integrations/social/discord` |
| **Dribbble** | [Dribbble Developers](https://dribbble.com/account/applications/new) | CLIENT_ID, CLIENT_SECRET | `${FRONTEND_URL}/integrations/social/dribbble` |
| **Facebook** | [Meta for Developers](https://developers.facebook.com/apps) | APP_ID, APP_SECRET | `${FRONTEND_URL}/integrations/social/facebook` |
| **Instagram** | [Meta for Developers](https://developers.facebook.com/apps) | Uses Facebook APP_ID/SECRET | `${FRONTEND_URL}/integrations/social/instagram` |
| **LinkedIn** | [LinkedIn Developers](https://www.linkedin.com/developers/apps) | CLIENT_ID, CLIENT_SECRET | `${FRONTEND_URL}/integrations/social/linkedin` |
| **LinkedIn Page** | [LinkedIn Developers](https://www.linkedin.com/developers/apps) | Uses same LinkedIn credentials | `${FRONTEND_URL}/integrations/social/linkedin-page` |
| **Mastodon** | Your Mastodon Instance | CLIENT_ID, CLIENT_SECRET, Instance URL | `${FRONTEND_URL}/integrations/social/mastodon` |
| **Pinterest** | [Pinterest Developers](https://developers.pinterest.com/apps/) | CLIENT_ID, CLIENT_SECRET | `${FRONTEND_URL}/integrations/social/pinterest` |
| **Reddit** | [Reddit Apps](https://www.reddit.com/prefs/apps) | CLIENT_ID, CLIENT_SECRET | `${FRONTEND_URL}/integrations/social/reddit` |
| **Slack** | [Slack API](https://api.slack.com/apps) | ID, SECRET, SIGNING_SECRET | `${FRONTEND_URL}/integrations/social/slack` |
| **Telegram** | [Telegram BotFather](https://t.me/BotFather) | Bot Token | N/A (Bot token auth) |
| **Threads** | [Meta for Developers](https://developers.facebook.com/apps) | APP_ID, APP_SECRET | `${FRONTEND_URL}/integrations/social/threads` |
| **TikTok** | [TikTok Developers](https://developers.tiktok.com/) | CLIENT_ID, CLIENT_SECRET | `${FRONTEND_URL}/integrations/social/tiktok` |
| **X (Twitter)** | [X Developer Portal](https://developer.x.com/en/portal/dashboard) | API_KEY, API_SECRET | `${FRONTEND_URL}/integrations/social/x` |
| **YouTube** | [Google Cloud Console](https://console.cloud.google.com/) | CLIENT_ID, CLIENT_SECRET | `${FRONTEND_URL}/integrations/social/youtube` |

## 🔧 Configuration Steps

### Step 1: Create App in Provider Portal

Visit the provider's developer portal (see table above) and create a new app/bot.

### Step 2: Get Credentials

Copy the CLIENT_ID, CLIENT_SECRET (and any additional tokens) from the provider's dashboard.

### Step 3: Configure OAuth Redirect URL

For your AI LaunchKit installation, the redirect URL pattern is:
```
http://192.168.178.151:8060/integrations/social/{provider}
```

Replace `{provider}` with the provider name from the table.

### Step 4: Add to .env File

Edit your `.env` file on the server:
```bash
nano ~/ai/ai-launchkit-local/.env
```

Add the credentials (example for Discord):
```bash
DISCORD_CLIENT_ID="your_client_id_here"
DISCORD_CLIENT_SECRET="your_client_secret_here"
DISCORD_BOT_TOKEN_ID="your_bot_token_here"
```

Save: `Ctrl+X`, `Y`, `Enter`

### Step 5: Restart Postiz

**IMPORTANT:** Use `down` + `up`, not `restart` to load new environment variables:
```bash
cd ~/ai/ai-launchkit-local && \
docker compose -p localai -f docker-compose.local.yml down postiz && \
docker compose -p localai -f docker-compose.local.yml up -d postiz && \
sleep 60 && \
echo "✅ Postiz restarted with new provider credentials"
```

### Step 6: Connect in Postiz UI

1. Open Postiz: `http://192.168.178.151:8060`
2. Go to **Settings → Channels**
3. Click **"Add Channel"**
4. Select your provider
5. Follow OAuth flow

## 📖 Detailed Provider Setup Guides

### Discord

**Portal:** [Discord Developer Portal](https://discord.com/developers/applications)

**Steps:**
1. Click "New Application"
2. Name your app
3. Upload app icon (1024x1024px max) - Required!
4. Go to **OAuth2** section
5. Copy **Client ID** and **Client Secret**
6. Add redirect URL: `http://192.168.178.151:8060/integrations/social/discord`
7. Go to **Bot** section
8. Click "Reset Token" and copy the Bot Token
9. Enable required bot permissions

**Environment Variables:**
```bash
DISCORD_CLIENT_ID="your_client_id"
DISCORD_CLIENT_SECRET="your_client_secret"
DISCORD_BOT_TOKEN_ID="your_bot_token"
```

**Required Bot Permissions:**
- Send Messages
- Embed Links
- Attach Files
- Read Message History

---

### LinkedIn

**Portal:** [LinkedIn Developers](https://www.linkedin.com/developers/apps)

**Steps:**
1. Click "Create app"
2. Fill in app details
3. Go to **Auth** tab
4. Copy **Client ID** and **Client Secret**
5. Add redirect URL: `http://192.168.178.151:8060/integrations/social/linkedin`
6. Go to **Products** tab
7. Request access to "Share on LinkedIn" and "Sign In with LinkedIn"

**Environment Variables:**
```bash
LINKEDIN_CLIENT_ID="your_client_id"
LINKEDIN_CLIENT_SECRET="your_client_secret"
```

**Note:** LinkedIn Page uses the same credentials.

---

### YouTube

**Portal:** [Google Cloud Console](https://console.cloud.google.com/)

**Steps:**
1. Create new project
2. Enable **YouTube Data API v3**
3. Go to **Credentials** → Create **OAuth 2.0 Client ID**
4. Application type: **Web application**
5. Add redirect URI: `http://192.168.178.151:8060/integrations/social/youtube`
6. Copy **Client ID** and **Client Secret**

**Environment Variables:**
```bash
YOUTUBE_CLIENT_ID="your_client_id"
YOUTUBE_CLIENT_SECRET="your_client_secret"
```

**Required Scopes:**
- `https://www.googleapis.com/auth/youtube.upload`
- `https://www.googleapis.com/auth/youtube.force-ssl`

---

### X (Twitter)

**Portal:** [X Developer Portal](https://developer.x.com/en/portal/dashboard)

**Steps:**
1. Apply for developer access (if not already done)
2. Create new app
3. Go to **Keys and tokens**
4. Copy **API Key** and **API Secret**
5. Generate **Access Token** and **Access Token Secret**
6. Enable OAuth 1.0a
7. Add callback URL: `http://192.168.178.151:8060/integrations/social/x`

**Environment Variables:**
```bash
X_API_KEY="your_api_key"
X_API_SECRET="your_api_secret"
```

---

### Facebook

**Portal:** [Meta for Developers](https://developers.facebook.com/apps)

**Steps:**
1. Click "Create App"
2. Choose app type: **Business**
3. Add **Facebook Login** product
4. Go to **Settings → Basic**
5. Copy **App ID** and **App Secret**
6. Go to **Facebook Login → Settings**
7. Add redirect URI: `http://192.168.178.151:8060/integrations/social/facebook`

**Environment Variables:**
```bash
FACEBOOK_APP_ID="your_app_id"
FACEBOOK_APP_SECRET="your_app_secret"
```

**Note:** Instagram uses the same Facebook App credentials.

---

### Reddit

**Portal:** [Reddit Apps](https://www.reddit.com/prefs/apps)

**Steps:**
1. Scroll to "developed applications"
2. Click "create another app"
3. Choose type: **web app**
4. Redirect URI: `http://192.168.178.151:8060/integrations/social/reddit`
5. Copy **client id** (under app name) and **secret**

**Environment Variables:**
```bash
REDDIT_CLIENT_ID="your_client_id"
REDDIT_CLIENT_SECRET="your_client_secret"
```

---

### Slack

**Portal:** [Slack API](https://api.slack.com/apps)

**Steps:**
1. Click "Create New App"
2. Choose "From scratch"
3. Go to **OAuth & Permissions**
4. Add redirect URL: `http://192.168.178.151:8060/integrations/social/slack`
5. Add Bot Token Scopes (chat:write, files:write, etc.)
6. Go to **Basic Information**
7. Copy **Client ID**, **Client Secret**, and **Signing Secret**

**Environment Variables:**
```bash
SLACK_ID="your_client_id"
SLACK_SECRET="your_client_secret"
SLACK_SIGNING_SECRET="your_signing_secret"
```

---

### Telegram

**Portal:** [Telegram BotFather](https://t.me/BotFather)

**Steps:**
1. Open Telegram and search for **@BotFather**
2. Send `/newbot` command
3. Follow prompts to create bot
4. Copy the **Bot Token** provided
5. Optional: Set bot username and profile picture

**Environment Variables:**
```bash
# Telegram doesn't use CLIENT_ID - uses Bot Token directly
# Configure through Postiz UI with Bot Token
```

**Note:** Telegram authentication is done through the Postiz UI, not environment variables.

---

### TikTok

**Portal:** [TikTok Developers](https://developers.tiktok.com/)

**Steps:**
1. Register as developer
2. Create new app
3. Add **Login Kit** product
4. Copy **Client Key** and **Client Secret**
5. Add redirect URI: `http://192.168.178.151:8060/integrations/social/tiktok`

**Environment Variables:**
```bash
TIKTOK_CLIENT_ID="your_client_key"
TIKTOK_CLIENT_SECRET="your_client_secret"
```

---

### Pinterest

**Portal:** [Pinterest Developers](https://developers.pinterest.com/apps/)

**Steps:**
1. Create new app
2. Go to app settings
3. Copy **App ID** and **App Secret**
4. Add redirect URI: `http://192.168.178.151:8060/integrations/social/pinterest`

**Environment Variables:**
```bash
PINTEREST_CLIENT_ID="your_app_id"
PINTEREST_CLIENT_SECRET="your_app_secret"
```

---

### Threads

**Portal:** [Meta for Developers](https://developers.facebook.com/apps)

**Steps:**
1. Use existing Facebook App or create new one
2. Add **Threads** product
3. Use same **App ID** and **App Secret** as Facebook
4. Add redirect URI: `http://192.168.178.151:8060/integrations/social/threads`

**Environment Variables:**
```bash
THREADS_APP_ID="your_facebook_app_id"
THREADS_APP_SECRET="your_facebook_app_secret"
```

---

### Instagram

**Portal:** [Meta for Developers](https://developers.facebook.com/apps)

**Steps:**
1. Use your Facebook App
2. Add **Instagram Basic Display** or **Instagram Graph API** product
3. Use same **App ID** and **App Secret** as Facebook
4. Add redirect URI: `http://192.168.178.151:8060/integrations/social/instagram`

**Environment Variables:**
```bash
# Instagram uses Facebook credentials
FACEBOOK_APP_ID="your_app_id"
FACEBOOK_APP_SECRET="your_app_secret"
```

---

### Dribbble

**Portal:** [Dribbble Developers](https://dribbble.com/account/applications/new)

**Steps:**
1. Create new application
2. Fill in application details
3. Copy **Client ID** and **Client Secret**
4. Add redirect URI: `http://192.168.178.151:8060/integrations/social/dribbble`

**Environment Variables:**
```bash
DRIBBBLE_CLIENT_ID="your_client_id"
DRIBBBLE_CLIENT_SECRET="your_client_secret"
```

---

### Mastodon

**Portal:** Your Mastodon Instance (e.g., [mastodon.social](https://mastodon.social))

**Steps:**
1. Go to **Settings → Development**
2. Click "New application"
3. Set application name
4. Add redirect URI: `http://192.168.178.151:8060/integrations/social/mastodon`
5. Select required scopes (read, write, follow)
6. Copy **Client ID** and **Client Secret**

**Environment Variables:**
```bash
MASTODON_URL="https://mastodon.social"  # or your instance
MASTODON_CLIENT_ID="your_client_id"
MASTODON_CLIENT_SECRET="your_client_secret"
```

---

### Bluesky

**Portal:** [Bluesky App](https://bsky.app/settings/app-passwords)

**Steps:**
1. Log in to Bluesky
2. Go to **Settings → App Passwords**
3. Click "Add App Password"
4. Name it (e.g., "Postiz")
5. Copy the generated password

**Configuration:**
```bash
# Bluesky uses direct authentication through Postiz UI
# Add account through: Settings → Channels → Add Channel → Bluesky
# Enter your @handle and app password
```

**Note:** No environment variables needed - configure through Postiz UI.

---

## 🔄 Adding Providers After Installation

### Method 1: Manual Configuration

1. **Edit .env file:**
   ```bash
   nano ~/ai/ai-launchkit-local/.env
   ```

2. **Add provider credentials:**
   ```bash
   # Example for Discord
   DISCORD_CLIENT_ID="abc123xyz"
   DISCORD_CLIENT_SECRET="def456uvw"
   DISCORD_BOT_TOKEN_ID="ghi789rst"
   ```

3. **Save and exit:** `Ctrl+X`, `Y`, `Enter`

4. **Restart Postiz** (MUST use down+up, not restart):
   ```bash
   cd ~/ai/ai-launchkit-local && \
   docker compose -p localai -f docker-compose.local.yml down postiz && \
   docker compose -p localai -f docker-compose.local.yml up -d postiz
   ```

5. **Wait 1 minute** for Postiz to fully start

6. **Connect in Postiz UI:**
   - Open `http://192.168.178.151:8060`
   - Go to **Settings → Channels**
   - Click **Add Channel**
   - Select your provider
   - Follow OAuth flow

### Method 2: All Providers at Once

Edit your `.env` and add all providers you want to use:

```bash
# Social Media Providers
DISCORD_CLIENT_ID=""
DISCORD_CLIENT_SECRET=""
DISCORD_BOT_TOKEN_ID=""

LINKEDIN_CLIENT_ID=""
LINKEDIN_CLIENT_SECRET=""

YOUTUBE_CLIENT_ID=""
YOUTUBE_CLIENT_SECRET=""

X_API_KEY=""
X_API_SECRET=""

REDDIT_CLIENT_ID=""
REDDIT_CLIENT_SECRET=""

FACEBOOK_APP_ID=""
FACEBOOK_APP_SECRET=""

THREADS_APP_ID=""
THREADS_APP_SECRET=""

TIKTOK_CLIENT_ID=""
TIKTOK_CLIENT_SECRET=""

PINTEREST_CLIENT_ID=""
PINTEREST_CLIENT_SECRET=""

SLACK_ID=""
SLACK_SECRET=""
SLACK_SIGNING_SECRET=""

DRIBBBLE_CLIENT_ID=""
DRIBBBLE_CLIENT_SECRET=""

MASTODON_URL="https://mastodon.social"
MASTODON_CLIENT_ID=""
MASTODON_CLIENT_SECRET=""
```

Fill in only the providers you want to use, then restart Postiz.

## 🎯 OAuth Redirect URLs for AI LaunchKit

For your installation, use these redirect URLs when configuring apps:

| Provider | Redirect URL |
|----------|--------------|
| Discord | `http://192.168.178.151:8060/integrations/social/discord` |
| LinkedIn | `http://192.168.178.151:8060/integrations/social/linkedin` |
| YouTube | `http://192.168.178.151:8060/integrations/social/youtube` |
| X | `http://192.168.178.151:8060/integrations/social/x` |
| Facebook | `http://192.168.178.151:8060/integrations/social/facebook` |
| Instagram | `http://192.168.178.151:8060/integrations/social/instagram` |
| Reddit | `http://192.168.178.151:8060/integrations/social/reddit` |
| Slack | `http://192.168.178.151:8060/integrations/social/slack` |
| TikTok | `http://192.168.178.151:8060/integrations/social/tiktok` |
| Pinterest | `http://192.168.178.151:8060/integrations/social/pinterest` |
| Threads | `http://192.168.178.151:8060/integrations/social/threads` |
| Dribbble | `http://192.168.178.151:8060/integrations/social/dribbble` |
| Mastodon | `http://192.168.178.151:8060/integrations/social/mastodon` |

**Note:** Replace `192.168.178.151` with your actual SERVER_IP if different.

## 🐛 Troubleshooting

### Provider doesn't appear in Postiz UI

**Cause:** Credentials not loaded by container

**Solution:** 
- Verify credentials in `.env` file
- Restart using `down` + `up` (not `restart`)
- Check Postiz logs: `docker logs postiz`

### OAuth redirect error

**Cause:** Redirect URL mismatch

**Solution:**
- Verify redirect URL in provider portal matches exactly
- Check `FRONTEND_URL` in Postiz environment matches your access URL
- Ensure `NOT_SECURED=true` is set for HTTP

### "Client ID not found" error

**Cause:** CLIENT_ID empty or not loaded

**Solution:**
```bash
# Verify CLIENT_ID in .env:
cat ~/ai/ai-launchkit-local/.env | grep "DISCORD_CLIENT_ID"

# Verify loaded in container:
docker exec postiz printenv | grep "DISCORD_CLIENT_ID"

# If not loaded, restart with down+up
```

### 404 errors when adding channel

**Causes:**
- **Discord:** App icon not uploaded (1024x1024px required)
- **Discord:** Bot token not set
- **Other providers:** Incomplete app setup in provider portal

**Solution:** Complete all required steps in provider's developer portal

### Provider connected but posting fails

**Causes:**
- Insufficient permissions/scopes
- Token expired
- API rate limits exceeded

**Solution:**
- Check bot/app permissions in provider portal
- Reconnect provider in Postiz UI
- Check provider API status

## 📝 Environment Variables Reference

### Complete list of Postiz provider variables:

```bash
# Discord
DISCORD_CLIENT_ID=""
DISCORD_CLIENT_SECRET=""
DISCORD_BOT_TOKEN_ID=""

# LinkedIn
LINKEDIN_CLIENT_ID=""
LINKEDIN_CLIENT_SECRET=""

# YouTube (Google)
YOUTUBE_CLIENT_ID=""
YOUTUBE_CLIENT_SECRET=""

# X (Twitter)
X_API_KEY=""
X_API_SECRET=""

# Reddit
REDDIT_CLIENT_ID=""
REDDIT_CLIENT_SECRET=""

# Facebook & Instagram & Threads
FACEBOOK_APP_ID=""
FACEBOOK_APP_SECRET=""
THREADS_APP_ID=""    # Can use same as Facebook
THREADS_APP_SECRET=""  # Can use same as Facebook

# TikTok
TIKTOK_CLIENT_ID=""
TIKTOK_CLIENT_SECRET=""

# Pinterest
PINTEREST_CLIENT_ID=""
PINTEREST_CLIENT_SECRET=""

# Slack
SLACK_ID=""
SLACK_SECRET=""
SLACK_SIGNING_SECRET=""

# Dribbble
DRIBBBLE_CLIENT_ID=""
DRIBBBLE_CLIENT_SECRET=""

# Mastodon
MASTODON_URL="https://mastodon.social"  # Your instance URL
MASTODON_CLIENT_ID=""
MASTODON_CLIENT_SECRET=""

# GitHub (if supported)
GITHUB_CLIENT_ID=""
GITHUB_CLIENT_SECRET=""

# Beehiiv (newsletter platform)
BEEHIIVE_API_KEY=""
BEEHIIVE_PUBLICATION_ID=""
```

## ✅ Testing Providers

After configuring a provider:

1. **Verify environment loaded:**
   ```bash
   docker exec postiz printenv | grep "DISCORD_CLIENT_ID"
   ```

2. **Check Postiz logs for errors:**
   ```bash
   docker logs postiz --tail 50 | grep -i "discord\|error"
   ```

3. **Test in UI:**
   - Go to Settings → Channels
   - Click "Add Channel"
   - Provider should appear in list
   - Click provider → OAuth flow should start

4. **Post a test:**
   - Create a simple post
   - Select connected channel
   - Click "Post Now"
   - Verify appears on social media

## 🔗 Additional Resources

- [Postiz Official Providers Documentation](https://docs.postiz.com/providers)
- [Configuration Reference](https://docs.postiz.com/configuration/reference)
- [Postiz GitHub Issues](https://github.com/gitroomhq/postiz-app/issues)

## 📌 Important Notes

1. **Security:** Never commit `.env` file to git - it contains sensitive API keys
2. **Restart Required:** Always use `docker compose down` + `up` after changing `.env`
3. **Rate Limits:** Each provider has API rate limits - check provider documentation
4. **OAuth:** Most providers require publicly accessible redirect URLs for OAuth
5. **HTTP vs HTTPS:** For local network (HTTP), ensure `NOT_SECURED=true` is set in Postiz

## 🎯 Recommended Starting Providers

For testing and getting started, we recommend:

1. **Discord** - Easy setup, no app review required
2. **Reddit** - Simple OAuth flow
3. **LinkedIn** - Professional network, straightforward setup

These three are good for initial testing before configuring others.

---

**Need Help?** Check the [Postiz Support page](https://docs.postiz.com/support) or open an issue on the AI LaunchKit repository.
