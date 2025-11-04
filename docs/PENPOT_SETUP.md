# Penpot - Open Source Design & Prototyping Platform

## What is Penpot?

Penpot is the first **open-source design and prototyping platform** designed for cross-domain teams. It's a complete alternative to Figma that works in the browser, with native support for SVG and web standards.

**Key Features:**
- 🎨 Design & Prototype in one tool
- 🔓 100% Open Source (MPL-2.0 license)
- 🌐 Browser-based (no installation needed)
- 📱 Real-time collaboration
- 💻 Design-to-code workflows
- 🔌 Plugin system & REST API
- 📦 Design systems & components
- 🎯 SVG/CSS/HTML export

---

## Installation

### Select in Wizard

During AI LaunchKit installation, select **"penpot"** from the service list:

```
☐ penpot - Penpot (Open Source Design & Prototyping - Figma Alternative) - Port 8111
```

**Resource Requirements:**
- RAM: ~2-3GB
- CPU: 2 cores
- Disk: 5-10GB (design assets)
- Dependencies: PostgreSQL + Redis (shared)

---

## First Access

### Open Penpot

```
http://YOUR-SERVER-IP:8111
```

**Example:** `http://192.168.1.100:8111`

### Create First Account

1. Click **"Sign up"** or **"Get Started"**
2. Enter your email
3. Choose a password
4. Click **"Create Account"**

**Note:** First user becomes admin automatically!

---

## Architecture

### Shared Resources (Smart Integration)

**PostgreSQL Database:**
```
Penpot uses: postgres/penpot database
Shared with: n8n, Baserow, NocoDB, Cal.com, Vikunja, Langfuse
```

**Redis Cache:**
```
Penpot uses: redis/1 (separate database index)
No conflict with: Other services (use redis/0)
```

**Email (Mailpit):**
```
SMTP Host: mailpit
Port: 1025
All emails captured for testing
```

---

## Use Cases for AI LaunchKit

### 1. UI/UX Design for AI Applications
- Design interfaces for your AI tools
- Prototype before development
- Export components as SVG/CSS
- Share designs with team

### 2. Design-to-Code Workflow
```
Penpot Design
  ↓
  Export SVG/CSS
  ↓
  n8n Workflow (automation)
  ↓
  bolt.diy (implement)
```

### 3. Design System Management
- Create component libraries
- Design tokens for consistency
- Variants & component states
- Maintain brand guidelines

### 4. Collaborative Design
- Real-time multi-user editing
- Comments & feedback
- Version history
- Design handoff to developers

---

## Configuration

### Environment Variables (in .env)

```bash
# Penpot Version (default: latest)
PENPOT_VERSION=latest

# Secret Key (auto-generated)
PENPOT_SECRET_KEY=<64-byte-base64-string>

# Public URL (set by wizard)
SERVER_IP=192.168.1.100
```

### Service Architecture

**4 Containers:**
```
penpot-frontend (Port 8111) - React UI
  ↓ depends on
penpot-backend - Clojure API
penpot-exporter - Export service
  ↓ both depend on
penpot-postgres-init - Database setup
```

---

## Common Tasks

### Export Designs

**SVG Export:**
1. Select object/frame
2. Right-click → "Export"
3. Choose SVG format
4. Download

**CSS Export:**
1. Enable "Inspect" mode
2. Select element
3. Copy CSS code
4. Use in your project

### Create Component Library

1. Create components in "Components" panel
2. Define variants (states, sizes)
3. Document with descriptions
4. Share library with team

### Design Handoff

1. Enable "Inspect" mode
2. Developers see:
   - CSS code
   - SVG export
   - Measurements
   - Assets

---

## AI Integration with MCP

Penpot can be integrated with AI assistants via the **penpot-mcp server**.

**Setup:** See [PENPOT_MCP_INTEGRATION.md](PENPOT_MCP_INTEGRATION.md)

**Use Cases:**
- Claude analyzes your designs
- AI suggests improvements
- Automated design documentation
- Natural language design search

---

## Troubleshooting

### Penpot Not Loading

**Check containers:**
```bash
docker ps | grep penpot
# Should show: penpot-frontend, penpot-backend, penpot-exporter
```

**Check logs:**
```bash
docker logs penpot-frontend
docker logs penpot-backend
docker logs penpot-exporter
```

**Common issues:**
- Backend initializing (wait 2-3 minutes)
- Database migration in progress
- Port 8111 already in use

### Database Connection Errors

```bash
# Check PostgreSQL
docker ps | grep postgres

# Check penpot database exists
docker exec postgres psql -U postgres -l | grep penpot

# Recreate if needed
docker exec postgres psql -U postgres -c "CREATE DATABASE penpot;"
```

### Assets Not Saving

**Check volume:**
```bash
docker volume ls | grep penpot_assets

# Inspect volume
docker volume inspect penpot_assets
```

---

## Performance Tips

### Reduce Memory Usage

Penpot is resource-intensive. For limited hardware:

1. **Close unused tabs**
2. **Limit active projects**
3. **Clear browser cache**
4. **Increase swap:**
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

### Optimize for Team Use

**Increase backend resources:**
```yaml
# In docker-compose.local.yml (future enhancement)
penpot-backend:
  deploy:
    resources:
      limits:
        memory: 2G
      reservations:
        memory: 1G
```

---

## Backup

### Automatic Backup

Penpot data is in Docker volumes:
- `penpot_assets` - Design files, images
- `postgres` - Database (shared with penpot DB)

**Backup with AI LaunchKit:**
```bash
sudo bash ./scripts/uninstall_local.sh
# Select "Yes" for backup
# Penpot data included automatically
```

### Manual Backup

**Export designs:**
```bash
# Backup volume
docker run --rm \
  -v penpot_assets:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/penpot-assets-$(date +%Y%m%d).tar.gz /data
```

**Backup database:**
```bash
docker exec postgres pg_dump -U postgres penpot > penpot-db-$(date +%Y%m%d).sql
```

---

## Updating Penpot

### Automatic Update

```bash
cd ~/ai-launchkit-local
sudo bash ./scripts/update_local.sh
```

This updates:
- ✅ Penpot Docker images
- ✅ All other services
- ✅ Scripts and configuration

### Manual Update

```bash
# Pull latest images
docker compose -p localai -f docker-compose.local.yml pull penpot-frontend penpot-backend penpot-exporter

# Restart Penpot
docker compose -p localai -f docker-compose.local.yml up -d penpot-frontend penpot-backend penpot-exporter
```

---

## Resources

### Official Documentation
- [Penpot Website](https://penpot.app)
- [User Guide](https://help.penpot.app/user-guide/)
- [Technical Guide](https://help.penpot.app/technical-guide/)
- [Community](https://community.penpot.app/)

### AI LaunchKit Integration
- [MCP Integration Guide](PENPOT_MCP_INTEGRATION.md)
- [n8n Workflow Examples](../n8n/backup/workflows/)

### Video Tutorials
- [Penpot Learning Center](https://penpot.app/learning-center)
- [YouTube Channel](https://www.youtube.com/@Penpot)

---

## Support

### Issues
- Penpot-specific: [Penpot GitHub Issues](https://github.com/penpot/penpot/issues)
- Integration issues: [AI LaunchKit Issues](https://github.com/heinrichhermann/ai-launchkit-local/issues)

### Community
- [Penpot Community](https://community.penpot.app/)
- [AI LaunchKit Forum](https://thinktank.ottomator.ai/c/local-ai/18)
