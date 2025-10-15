# Vibe Server Mode Dockerfile
# Multi-stage build for Vibe transcription in server mode

# Stage 1: Build Rust binary
FROM rust:1.83-bookworm as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Clone Vibe repository
RUN git clone --depth 1 https://github.com/thewh1teagle/vibe.git .

# Build vibe-cli in release mode
RUN cargo build --release --bin vibe-cli

# Stage 2: Runtime
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -u 1000 -s /bin/bash vibeuser

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/target/release/vibe-cli /usr/local/bin/vibe-cli

# Create data directories
RUN mkdir -p /app/data /app/models /app/uploads && \
    chown -R vibeuser:vibeuser /app

# Switch to app user
USER vibeuser

# Expose port
EXPOSE 3022

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3022/health || exit 1

# Start Vibe in server mode
CMD ["vibe-cli", "--server", "--host", "0.0.0.0", "--port", "3022"]
