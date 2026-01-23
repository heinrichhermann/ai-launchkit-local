# Cognee MCP Server with CORS Patch for AI LaunchKit
# This Dockerfile patches the CORS configuration to allow external origins
# instead of the hardcoded localhost:3000
#
# The patch modifies server.py to allow all origins for development use.
# This is necessary because:
# 1. cognee-mcp has CORS hardcoded to localhost:3000
# 2. The cognee backend (cognee/api/client.py) supports CORS_ALLOWED_ORIGINS env var
# 3. But the MCP server (server.py) does NOT read this env var
#
# Solution: Patch server.py at build time to allow all origins

FROM cognee/cognee-mcp:main

USER root

# Patch CORS in server.py to allow all origins
# The original code has:
#   allow_origins=["http://localhost:3000"]
#   allow_credentials=True
# We change it to:
#   allow_origins=["*"]
#   allow_credentials=False  (required when using wildcard)
RUN find /app -name "server.py" -type f | while read f; do \
        echo "Patching CORS in: $f"; \
        sed -i 's/allow_origins=\["http:\/\/localhost:3000"\]/allow_origins=["*"]/g' "$f"; \
        sed -i 's/allow_credentials=True/allow_credentials=False/g' "$f"; \
    done || echo "No server.py files found to patch"

# Also patch any FastAPI app CORS middleware that might be in other files
RUN find /app -name "*.py" -type f -exec grep -l "localhost:3000" {} \; | while read f; do \
        echo "Patching localhost:3000 in: $f"; \
        sed -i 's/"http:\/\/localhost:3000"/"*"/g' "$f"; \
    done || echo "No files with localhost:3000 found"

# Copy our custom entrypoint with setup.py fallback (fixes GitHub Issue #2007)
COPY entrypoint.sh /app/custom-entrypoint.sh
RUN chmod +x /app/custom-entrypoint.sh

# Copy the .env file for pydantic_settings
COPY .env /app/.env

ENTRYPOINT ["/bin/bash", "/app/custom-entrypoint.sh"]
