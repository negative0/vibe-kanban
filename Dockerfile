FROM node:18-alpine

# Install Rust, nginx and dependencies
RUN apk add --no-cache curl build-base perl tini nginx apache2-utils
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy package files first for dependency caching
COPY package*.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY frontend/package*.json ./frontend/
COPY npx-cli/package*.json ./npx-cli/

# Install pnpm, Claude Code, and dependencies (cached if package files unchanged)
RUN npm install -g pnpm @anthropic-ai/claude-code
RUN pnpm install

# Build frontend
COPY frontend/ ./frontend/
COPY shared/ ./shared/
WORKDIR /app/frontend
RUN npm run build

WORKDIR /app

# Copy Rust dependencies and build backend
COPY crates/ ./crates/
COPY assets/ ./assets/
COPY Cargo.toml ./
RUN cargo build --release

# Create nginx directories and copy built frontend
RUN mkdir -p /var/www/html
RUN cp -r /app/frontend/dist/* /var/www/html/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy basic auth file
COPY nginx/.htpasswd /etc/nginx/.htpasswd

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'nginx &' >> /start.sh && \
    echo 'cd /repos && /app/target/release/server' >> /start.sh && \
    chmod +x /start.sh

# Expose ports
EXPOSE 80 3001

# Set working directory for runtime
WORKDIR /repos

# Use tini and run startup script
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/start.sh"]
