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
# The server.py is in /app/src/server.py
# The original code in run_sse_with_cors() and run_http_with_cors() has:
#   allow_origins=["http://localhost:3000"],
# We change it to:
#   allow_origins=os.environ.get("CORS_ALLOWED_ORIGINS", "http://localhost:3000").split(","),
#
# This allows the frontend to connect from any origin specified in CORS_ALLOWED_ORIGINS
RUN echo "=== Patching CORS in server.py ===" && \
    SERVER_PY="/app/src/server.py" && \
    if [ -f "$SERVER_PY" ]; then \
        echo "Found server.py at: $SERVER_PY"; \
        echo "Before patch:"; \
        grep 'allow_origins' "$SERVER_PY"; \
        # Use sed to replace the hardcoded origins
        sed -i 's/allow_origins=\["http:\/\/localhost:3000"\]/allow_origins=os.environ.get("CORS_ALLOWED_ORIGINS", "http:\/\/localhost:3000").split(",")/g' "$SERVER_PY"; \
        echo "After patch:"; \
        grep 'allow_origins' "$SERVER_PY"; \
    else \
        echo "ERROR: server.py not found at $SERVER_PY"; \
        find /app -name "server.py" -type f 2>/dev/null; \
    fi

# Verify the patch was applied
RUN echo "=== Verifying CORS patch ===" && \
    grep -l "CORS_ALLOWED_ORIGINS" /app/src/server.py && \
    echo "CORS patch verified!" || \
    (echo "ERROR: CORS patch was NOT applied!" && exit 1)

# Copy our custom entrypoint with setup.py fallback (fixes GitHub Issue #2007)
COPY entrypoint.sh /app/custom-entrypoint.sh
RUN chmod +x /app/custom-entrypoint.sh

# Copy the .env file for pydantic_settings
COPY .env /app/.env

ENTRYPOINT ["/bin/bash", "/app/custom-entrypoint.sh"]
