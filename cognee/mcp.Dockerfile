# Cognee MCP with CORS Patch
# Extends the official cognee-mcp image to allow CORS from any origin
# This fixes the "No 'Access-Control-Allow-Origin' header" error when
# the frontend (port 8122) tries to access the MCP server (port 8121)

FROM cognee/cognee-mcp:main

# Patch the server.py to allow CORS from any origin
# The original code has: allow_origins=["http://localhost:3000"]
# We change it to: allow_origins=["*"]
# Using Python to do the replacement since sed escaping is tricky
RUN python3 -c "import re; f=open('/app/src/server.py','r'); c=f.read(); f.close(); c=c.replace('allow_origins=[\"http://localhost:3000\"]','allow_origins=[\"*\"]'); c=c.replace('return JSONResponse({\"status\": \"ok\"})','return JSONResponse({\"status\": \"ok\"}, headers={\"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"})'); f=open('/app/src/server.py','w'); f.write(c); f.close(); print('CORS patch applied')"

# Verify the patch was applied
RUN grep -n "allow_origins" /app/src/server.py || echo "Warning: allow_origins not found"
