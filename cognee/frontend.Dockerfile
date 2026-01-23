# Cognee Frontend Dockerfile with runtime environment variable support
# This Dockerfile creates a .env.local file at container startup
# to properly inject NEXT_PUBLIC_* variables into Next.js dev mode

FROM node:22-alpine

# Set the working directory to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package.json package-lock.json ./

# Install any needed packages specified in package.json
RUN npm ci
RUN npm rebuild lightningcss

# Copy the rest of the application code to the working directory
COPY src ./src
COPY public ./public
COPY next.config.mjs .
COPY postcss.config.mjs .
COPY tsconfig.json .

# Create entrypoint script that generates .env.local at runtime
# This is necessary because Next.js reads NEXT_PUBLIC_* from .env.local
# even in dev mode, but environment variables alone don't work
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Generate .env.local from environment variables' >> /entrypoint.sh && \
    echo 'echo "Generating .env.local with backend URL: $NEXT_PUBLIC_BACKEND_API_URL"' >> /entrypoint.sh && \
    echo 'cat > /app/.env.local << EOF' >> /entrypoint.sh && \
    echo 'NEXT_PUBLIC_BACKEND_API_URL=${NEXT_PUBLIC_BACKEND_API_URL:-http://localhost:8000}' >> /entrypoint.sh && \
    echo 'NEXT_PUBLIC_CLOUD_API_URL=${NEXT_PUBLIC_CLOUD_API_URL:-}' >> /entrypoint.sh && \
    echo 'NEXT_PUBLIC_MCP_API_URL=${NEXT_PUBLIC_MCP_API_URL:-}' >> /entrypoint.sh && \
    echo 'USE_AUTH0_AUTHORIZATION=${USE_AUTH0_AUTHORIZATION:-false}' >> /entrypoint.sh && \
    echo 'EOF' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'echo "Generated .env.local:"' >> /entrypoint.sh && \
    echo 'cat /app/.env.local' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Start the application' >> /entrypoint.sh && \
    echo 'exec npm run dev' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
