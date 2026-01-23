# Cognee MCP with CORS Patch
# Extends the official cognee-mcp image to allow CORS from any origin
# This fixes the "No 'Access-Control-Allow-Origin' header" error when
# the frontend (port 8122) tries to access the MCP server (port 8121)

FROM cognee/cognee-mcp:main

# Patch the server.py to allow CORS from any origin
# The original code has: allow_origins=["http://localhost:3000"]
# We change it to: allow_origins=["*"]
RUN sed -i 's/allow_origins=\["http:\/\/localhost:3000"\]/allow_origins=["*"]/g' /app/src/server.py

# Also patch the health endpoint to add CORS headers
# We need to modify the health_check function to return proper CORS headers
RUN sed -i 's/return JSONResponse({"status": "ok"})/return JSONResponse({"status": "ok"}, headers={"Access-Control-Allow-Origin": "*", "Access-Control-Allow-Credentials": "true"})/g' /app/src/server.py
