FROM node:18-alpine

# Install Rust and dependencies
RUN apk add --no-cache curl build-base perl tini
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

COPY frontend/ ./frontend/
COPY shared/ ./shared/
RUN cd frontend && npm run build

# Copy Rust dependencies for cargo cache
COPY crates/ ./crates/
COPY assets/ ./assets/
COPY Cargo.toml ./
RUN cargo build --release

# Expose port
ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000

# Run the application
WORKDIR /repos
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/target/release/server"]
