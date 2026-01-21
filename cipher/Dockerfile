################################################################################
# Cipher Dockerfile for AI LaunchKit
# Based on official Cipher Dockerfile with Ollama integration
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

# Create .cipher directory with proper permissions for database
RUN mkdir -p /app/.cipher/database && \
    chown -R cipher:cipher /app/.cipher

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
