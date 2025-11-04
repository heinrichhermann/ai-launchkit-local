# Penpot MCP Integration - AI-Powered Design Workflows

## What is penpot-mcp?

The **Penpot MCP Server** is a Model Context Protocol (MCP) server that connects AI assistants (Claude, Cursor IDE) to your Penpot designs via the Penpot API.

**What it enables:**
- 🤖 AI can "see" and analyze your designs
- 🔍 Natural language design search
- 📊 Automated design documentation
- ✨ AI-powered design suggestions
- 🎯 Design system compliance checks

**GitHub:** [montevive/penpot-mcp](https://github.com/montevive/penpot-mcp)

---

## Installation Location

**⚠️ Important:** MCP Server runs on your **local machine** (not on the AI LaunchKit server)

**Why?**
- MCP connects your local IDE (VS Code/Cursor) to Penpot
- Uses your personal Penpot credentials
- Better security (credentials stay on your machine)
- Direct access to your IDE

---

## Installation (on your local machine)

### Prerequisites

- Python 3.12+ installed
- VS Code or Cursor IDE
- AI LaunchKit with Penpot running

### Install penpot-mcp

```bash
# Install via pip
pip install penpot-mcp

# Or using uvx (recommended)
uvx penpot-mcp
```

---

## Configuration

### Get Penpot Credentials

**Your Penpot Server:**
```
URL: http://YOUR-SERVER-IP:8111
Username: your-email@example.com
Password: your-penpot-password
```

### Configure for Claude Desktop

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "penpot": {
      "command": "uvx",
      "args": ["penpot-mcp"],
      "env": {
        "PENPOT_API_URL": "http://YOUR-SERVER-IP:8111/api",
        "PENPOT_USERNAME": "your-email@example.com",
        "PENPOT_PASSWORD": "your-password"
      }
    }
  }
}
```

**Replace:**
- `YOUR-SERVER-IP` with your AI LaunchKit server IP (e.g., 192.168.1.100)
- `your-email@example.com` with your Penpot account
- `your-password` with your Penpot password

### Configure for Cursor IDE

Add to Cursor settings:

```json
{
  "mcpServers": {
    "penpot": {
      "command": "uvx",
      "args": ["penpot-mcp"],
      "env": {
        "PENPOT_API_URL": "http://YOUR-SERVER-IP:8111/api",
        "PENPOT_USERNAME": "your-email@example.com",
        "PENPOT_PASSWORD": "your-password"
      }
    }
  }
}
```

---

## Usage Examples

### With Claude Desktop

**After configuration, you can ask Claude:**

**Design Analysis:**
```
"Show me all my Penpot projects"
"Analyze the design components in project 'Dashboard UI'"
"What design patterns are used in file 'Login Page'?"
```

**Component Search:**
```
"Find all button components in my designs"
"Search for components with red color"
"List all icons used in project X"
```

**Export & Documentation:**
```
"Export the main button as SVG"
"Document the design system components"
"Generate a component usage guide"
```

**Design Review:**
```
"Review this design for accessibility issues"
"Check if colors meet WCAG contrast ratios"
"Suggest improvements for mobile responsiveness"
```

### With Cursor IDE

Same as Claude Desktop, but integrated directly in your IDE while coding:

```
"Get the button styles from Penpot project 'App Design'"
"Export icons from Penpot as SVG for this component"
"Compare this React component with the Penpot design"
```

---

## Available MCP Tools

The penpot-mcp server provides these tools to AI:

### Resources
- `server://info` - Server status
- `penpot://schema` - Penpot API schema
- `penpot://tree-schema` - Object tree schema
- `penpot://cached-files` - List cached files

### Tools
- `list_projects` - List all projects
- `get_project_files` - Get files in project
- `get_file` - Get file by ID (caches it)
- `export_object` - Export as image
- `get_object_tree` - Get object structure
- `search_object` - Search by name

---

## AI Workflow Examples

### Workflow 1: Design-to-Code with AI

```
1. Design in Penpot (your server)
2. Claude analyzes design via MCP
3. Claude generates React components
4. Code matches design specs perfectly
```

**Prompt Example:**
```
"Get the Dashboard design from Penpot, 
analyze its components, 
and generate React components with Tailwind CSS"
```

### Workflow 2: Automated Design Documentation

```
1. Create designs in Penpot
2. Ask Claude to document them
3. AI generates:
   - Component list
   - Usage guidelines
   - Color palette
   - Typography scale
```

**Prompt Example:**
```
"Document all components from Penpot project 'Design System',
include usage examples and code snippets"
```

### Workflow 3: Design Consistency Check

```
1. Multiple Penpot files
2. Claude compares them
3. Reports inconsistencies
4. Suggests standardization
```

**Prompt Example:**
```
"Compare all button components across my Penpot projects,
identify inconsistencies in size, color, and spacing"
```

---

## Troubleshooting

### MCP Server Not Starting

**Check Python version:**
```bash
python3 --version  # Should be 3.12+
```

**Test penpot-mcp installation:**
```bash
uvx penpot-mcp --help
```

### Connection Issues

**CloudFlare Protection (if using penpot.app):**

If you get authentication errors:
1. Open https://design.penpot.app in browser
2. Log in
3. Complete any verification challenges
4. Try MCP connection again

**Self-hosted Penpot (AI LaunchKit):**
- Verify server IP is correct
- Check Penpot is running: `docker ps | grep penpot`
- Test API manually: `curl http://SERVER-IP:8111/api`

### Credentials Not Working

**Check .env on server:**
```bash
# On AI LaunchKit server
cd ~/ai-launchkit-local
grep PENPOT .env
```

**Test login manually:**
```bash
# On your local machine
curl -X POST http://YOUR-SERVER-IP:8111/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"your-email","password":"your-password"}'
```

---

## Security Considerations

### Credentials Storage

**MCP Config contains credentials in plain text!**

**Protect your config file:**
```bash
# macOS
chmod 600 ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Windows (PowerShell)
icacls "%APPDATA%\Claude\claude_desktop_config.json" /inheritance:r /grant:r "%USERNAME%:F"
```

### Alternative: Environment Variables

**Create .env file:**
```bash
PENPOT_API_URL=http://192.168.1.100:8111/api
PENPOT_USERNAME=your-email@example.com
PENPOT_PASSWORD=your-password
```

**Update MCP config to reference:**
```json
{
  "mcpServers": {
    "penpot": {
      "command": "uvx",
      "args": ["penpot-mcp"],
      "env": {}
    }
  }
}
```

---

## Advanced Use Cases

### Integration with n8n

**Combine Penpot MCP + n8n workflows:**

1. **Design in Penpot** - Create UI mockups
2. **Claude extracts specs** - Via MCP
3. **n8n generates code** - Automated workflow
4. **Deploy to bolt.diy** - Test implementation

**Example n8n Workflow:**
```
Webhook Trigger
  ↓
Call Penpot API (get design)
  ↓
Claude analysis (via MCP concept)
  ↓
Generate code
  ↓
Deploy to test environment
```

### Design System Automation

**Use Claude to maintain design system:**

```
"Scan all Penpot projects,
extract all button styles,
create a design tokens JSON file,
document inconsistencies"
```

**Output:**
- `design-tokens.json` - Standardized values
- `inconsistencies.md` - Issues found
- `migration-guide.md` - How to fix

---

## Limitations

### Current penpot-mcp Limitations

- **Read-only:** Can analyze but not modify designs
- **Image export:** Limited to single objects
- **Performance:** Large files may be slow
- **Caching:** Files cached locally

### Network Considerations

**Local Network Setup:**
- AI LaunchKit: On server (192.168.1.x)
- MCP Server: On your machine
- Communication: HTTP (no SSL)

**Works because:**
- Same local network
- No firewall between devices
- Standard HTTP ports

---

## Resources

### penpot-mcp Documentation
- [GitHub Repo](https://github.com/montevive/penpot-mcp)
- [PyPI Package](https://pypi.org/project/penpot-mcp/)

### Penpot API
- [API Documentation](https://help.penpot.app/technical-guide/integration/)
- [REST API Reference](https://design.penpot.app/api/docs)

### MCP Protocol
- [Model Context Protocol](https://modelcontextprotocol.io)
- [MCP Specification](https://spec.modelcontextprotocol.io/)

---

## Example Prompts

### For Designers

```
"Create a style guide from my Penpot project 'App Design'"
"List all color values used in project 'Brand Guidelines'"
"Find components that don't follow naming conventions"
"Generate a component usage report"
```

### For Developers

```
"Get button component specs from Penpot for React implementation"
"Compare Penpot design with actual implementation in codebase"
"Extract spacing values for Tailwind config"
"Generate TypeScript types from Penpot component properties"
```

### For Teams

```
"Audit all projects for brand guideline compliance"
"Find duplicate components across projects"
"Suggest component library structure"
"Generate team design system documentation"
```

---

## Support

### Issues
- penpot-mcp: [GitHub Issues](https://github.com/montevive/penpot-mcp/issues)
- Penpot: [Penpot Issues](https://github.com/penpot/penpot/issues)
- AI LaunchKit: [Integration Issues](https://github.com/heinrichhermann/ai-launchkit-local/issues)

### Community
- [Penpot Community](https://community.penpot.app/)
- [MCP Discord](https://discord.gg/modelcontextprotocol)
