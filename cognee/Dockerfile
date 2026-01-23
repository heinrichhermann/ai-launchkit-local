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
# The original code in run_sse_with_cors() and run_http_with_cors() has:
#   allow_origins=["http://localhost:3000"],
# We change it to:
#   allow_origins=os.environ.get("CORS_ALLOWED_ORIGINS", "http://localhost:3000").split(","),
#
# This allows the frontend to connect from any origin specified in CORS_ALLOWED_ORIGINS
RUN find /app -name "server.py" -type f | while read f; do \
        echo "Patching CORS in: $f"; \
        # Check if file contains the hardcoded localhost:3000
        if grep -q 'allow_origins=\["http://localhost:3000"\]' "$f"; then \
            echo "Found hardcoded CORS in: $f"; \
            # Replace hardcoded origins with env var reading
            # Use Python to do the replacement more reliably
            python3 -c " \
import re; \
content = open('$f').read(); \
# Pattern matches: allow_origins=[\"http://localhost:3000\"] \
pattern = r'allow_origins=\[\"http://localhost:3000\"\]'; \
replacement = 'allow_origins=os.environ.get(\"CORS_ALLOWED_ORIGINS\", \"http://localhost:3000\").split(\",\")'; \
new_content = re.sub(pattern, replacement, content); \
open('$f', 'w').write(new_content); \
print('Patched CORS in: $f'); \
"; \
        else \
            echo "No hardcoded CORS found in: $f"; \
        fi; \
    done || echo "No server.py files found to patch"

# Verify the patch was applied
RUN echo "=== Verifying CORS patch ===" && \
    find /app -name "server.py" -type f -exec grep -l "CORS_ALLOWED_ORIGINS" {} \; || \
    echo "WARNING: CORS patch may not have been applied!"

# Copy our custom entrypoint with setup.py fallback (fixes GitHub Issue #2007)
COPY entrypoint.sh /app/custom-entrypoint.sh
RUN chmod +x /app/custom-entrypoint.sh

# Copy the .env file for pydantic_settings
COPY .env /app/.env

ENTRYPOINT ["/bin/bash", "/app/custom-entrypoint.sh"]
