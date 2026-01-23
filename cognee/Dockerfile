# Cognee MCP Server with CORS Patch for AI LaunchKit
# This Dockerfile patches the CORS configuration to allow external origins
# instead of the hardcoded localhost:3000
#
# The patch modifies server.py to read CORS_ALLOWED_ORIGINS from environment
# This is necessary because:
# 1. cognee-mcp has CORS hardcoded to localhost:3000
# 2. The cognee backend (cognee/api/client.py) supports CORS_ALLOWED_ORIGINS env var
# 3. But the MCP server (server.py) does NOT read this env var
#
# Solution: Patch server.py at build time to read CORS_ALLOWED_ORIGINS env var
# This allows the frontend to connect with credentials: "include"

FROM cognee/cognee-mcp:main

USER root

# Patch CORS in server.py to read from environment variable
# The original code has:
#   allow_origins=["http://localhost:3000"]
#   allow_credentials=True
# We change it to:
#   allow_origins=os.environ.get("CORS_ALLOWED_ORIGINS", "http://localhost:3000").split(",")
#   allow_credentials=True  (keep True for cookie/auth support)
#
# This allows the frontend to connect with credentials: "include"
RUN find /app -name "server.py" -type f | while read f; do \
        echo "Patching CORS in: $f"; \
        # Add os import at the top if not present
        grep -q "^import os" "$f" || sed -i '1i import os' "$f"; \
        # Replace hardcoded origins with env var reading
        sed -i 's/allow_origins=\["http:\/\/localhost:3000"\]/allow_origins=os.environ.get("CORS_ALLOWED_ORIGINS", "http:\/\/localhost:3000").split(",")/g' "$f"; \
        # Keep allow_credentials=True (don't change it)
    done || echo "No server.py files found to patch"

# Also patch any other files that might have hardcoded localhost:3000
# But be careful not to break things - only patch CORS-related lines
RUN find /app -name "*.py" -type f -exec grep -l "allow_origins.*localhost:3000" {} \; | while read f; do \
        echo "Patching allow_origins in: $f"; \
        grep -q "^import os" "$f" || sed -i '1i import os' "$f"; \
        sed -i 's/allow_origins=\["http:\/\/localhost:3000"\]/allow_origins=os.environ.get("CORS_ALLOWED_ORIGINS", "http:\/\/localhost:3000").split(",")/g' "$f"; \
    done || echo "No additional files with allow_origins found"

# Copy our custom entrypoint with setup.py fallback (fixes GitHub Issue #2007)
COPY entrypoint.sh /app/custom-entrypoint.sh
RUN chmod +x /app/custom-entrypoint.sh

# Copy the .env file for pydantic_settings
COPY .env /app/.env

ENTRYPOINT ["/bin/bash", "/app/custom-entrypoint.sh"]
