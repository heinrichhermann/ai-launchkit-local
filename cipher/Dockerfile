################################################################################
# Cipher Dockerfile for AI LaunchKit
# Based on official Cipher Dockerfile with Ollama integration
# 
# CORS PATCH: Modified to allow all origins for local network access
# This is necessary because Cipher's built-in CORS only allows localhost
################################################################################

# Build stage - includes dev dependencies
FROM node:20.18.1-alpine AS builder

# Build arguments
ARG BUILD_UI=true
ARG NODE_VERSION=20.18.1

# Install build dependencies for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Clone the Cipher repository
RUN git clone --depth 1 https://github.com/campfirein/cipher.git .

# Install pnpm
RUN npm install -g pnpm@9.14.0

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build with UI
RUN if [ "$BUILD_UI" = "true" ]; then pnpm run build; else pnpm run build:no-ui; fi

# ============================================================================
# CORS PATCH: Allow all origins for local network access
# This patches the compiled JavaScript to accept any origin
# ============================================================================
RUN echo "Applying CORS patch for local network access..." && \
    # Patch the API server to allow all origins
    # Find and replace the CORS origin callback to always return true
    sed -i 's/callback(new Error("Not allowed by CORS"))/callback(null, true)/g' dist/src/app/api/server.cjs && \
    # Also patch the index.cjs in case CORS is configured there
    sed -i 's/callback(new Error("Not allowed by CORS"))/callback(null, true)/g' dist/src/app/index.cjs 2>/dev/null || true && \
    echo "CORS patch applied successfully"

# Clean up and prepare production node_modules
RUN pnpm prune --prod && \
    pnpm store prune && \
    rm -rf /root/.npm /tmp/* /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts

################################################################################
# Production stage - minimal Alpine
FROM node:20.18.1-alpine AS production

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S cipher && adduser -S cipher -u 1001

# Create directories with proper permissions for database and backup files
# Cipher needs write access to /app for cipher-backup.db and other temp files
RUN mkdir -p /app/.cipher/database && \
    chown -R cipher:cipher /app

# Copy only essential production files
COPY --from=builder --chown=cipher:cipher /app/dist ./dist
COPY --from=builder --chown=cipher:cipher /app/node_modules ./node_modules
COPY --from=builder --chown=cipher:cipher /app/package.json ./

# Copy custom memAgent configuration for Ollama
COPY --chown=cipher:cipher memAgent ./memAgent

# Create a minimal .env file for Docker (environment variables will be passed via docker)
RUN echo "# Docker environment - variables passed via docker run" > .env

# Environment variables
ENV NODE_ENV=development \
    PORT=3000 \
    CONFIG_FILE=/app/memAgent/cipher.yml

# Switch to non-root user
USER cipher

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); const req = http.request({host:'localhost',port:process.env.PORT||3000,path:'/health'}, (res) => process.exit(res.statusCode === 200 ? 0 : 1)); req.on('error', () => process.exit(1)); req.end();"

# Expose ports for UI mode
EXPOSE 3000 3001

# Default command - can be overridden in docker-compose
CMD ["sh", "-c", "node dist/src/app/index.cjs --mode ui --host 0.0.0.0 --agent $CONFIG_FILE --mcp-transport-type sse"]
