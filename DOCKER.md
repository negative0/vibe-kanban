# Docker Deployment Guide

This guide explains how to deploy Vibe Kanban using Docker Compose with nginx reverse proxy and basic authentication.

## Quick Start

1. **Generate authentication credentials:**
   ```bash
   ./generate-auth.sh admin yourpassword123
   ```

2. **Start the application:**
   ```bash
   docker-compose up -d
   ```

3. **Access the application:**
   - Open http://localhost in your browser
   - Login with the credentials you created

## Architecture

The Docker Compose setup includes:
- **Backend**: Rust/Axum server running on port 3001
- **Frontend**: React/Vite application served by nginx
- **Nginx**: Reverse proxy with basic authentication on port 80

## Configuration

### Basic Authentication

The default credentials are:
- Username: `admin`
- Password: `admin123`

To create custom credentials:
```bash
# Method 1: Use the provided script
./generate-auth.sh myuser mypassword

# Method 2: Use htpasswd directly  
htpasswd -c nginx/.htpasswd myuser
```

### Environment Variables

You can customize the deployment by setting these environment variables:

```bash
# Backend configuration
export HOST=0.0.0.0
export BACKEND_PORT=3001

# Frontend configuration  
export VITE_API_BASE_URL=http://backend:3001
```

### Nginx Configuration

The nginx configuration (`nginx.conf`) includes:
- Basic authentication for all routes
- Reverse proxy to backend API (`/api/*`)
- Static asset caching
- Security headers
- Rate limiting
- Health check endpoint (no auth required)

## Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up --build -d

# Scale services (if needed)
docker-compose up -d --scale backend=2
```

## Development vs Production

This setup is configured for development/testing. For production:

1. **Use HTTPS**: Add SSL certificates and configure nginx for HTTPS
2. **Use stronger authentication**: Consider OAuth, LDAP, or other auth providers
3. **Set proper resource limits**: Add memory/CPU limits to services
4. **Use external database**: Configure persistent storage
5. **Add monitoring**: Include health checks and monitoring tools

## Troubleshooting

### Port conflicts
If port 80 is already in use:
```yaml
# In docker-compose.yml, change nginx ports:
ports:
  - "8080:80"  # Use port 8080 instead
```

### Permission issues
Make sure the scripts are executable:
```bash
chmod +x generate-auth.sh
```

### Backend connection issues
Check that the backend is accessible:
```bash
docker-compose exec nginx wget -q --spider http://backend:3001/api/health
```

### Authentication not working
Verify the .htpasswd file exists and has correct format:
```bash
cat nginx/.htpasswd
```

## Logs and Debugging

View service-specific logs:
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs nginx
docker-compose logs backend  
docker-compose logs frontend
```