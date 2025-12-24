# Local Server-Side Google Tag Manager

---

## Quick Start

### 1. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your actual values
nano .env
```

Set the following in `.env`:

```bash
# Get this from GTM Admin > Container Settings
CONTAINER_CONFIG=your_container_config_here
```

### 2. Start the Stack

SSL certificates are **automatically generated**. Just run:

```bash
docker-compose up -d
```

This starts:
- GTM Preview Server (for debugging)
- GTM Live Server (for production simulation)
- Nginx HTTPS Proxy (ports 8888, 8889)

### 3. Test It

```bash
# Check all containers are healthy
docker-compose ps

# Verify GTM containers
curl -k https://localhost:8888/healthy  # Live server
curl -k https://localhost:8889/healthy  # Preview server
```

### 4. Add localhost to your server side container

Add https://localhost:8888 to your server side container sites. Now you can preview and debug a server side container without server setup.

**That's it!** Click the test buttons and watch events flow through your server-side GTM container.

---

## Architecture

The system consists of 4 Docker services:

```
┌─────────────────────────────────────────────┐
│  Browser                                    │
│  ├─> https://localhost:8888 (GTM Live)      │
│  └─> https://localhost:8889 (GTM Preview)   │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│  ssl-init (one-time)                        │
│  └─> Generates SSL certificates             │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│  nginx (HTTPS Proxy)                        │
│  ├─> Port 8888 → gtm-live                   │
│  └─> Port 8889 → gtm-preview                │
└─────────────────────────────────────────────┘
              ↓
┌──────────────────┐    ┌─────────────────────┐
│  gtm-live        │───→│  gtm-preview        │
│  (Production)    │    │  (Debug Mode)       │
└──────────────────┘    └─────────────────────┘
```

### Service Details

| Service | Container | Ports | Purpose |
|---------|-----------|-------|---------|
| ssl-init | ssl-init | - | Generates SSL certificates (runs once) |
| gtm-preview | gtm-preview | Internal:8080 | GTM Preview Server |
| gtm-live | gtm-live | Internal:8080 | GTM Live Server |
| nginx | gtm-nginx | 8888, 8889 | HTTPS Proxy for GTM |

---

## Configuration

### Environment Variables

#### Required

- **`CONTAINER_CONFIG`** - Base64-encoded GTM container configuration
  - Get from: GTM Admin > Container Settings > Container Config
  - Format: Base64 string

#### Optional

- **`CONTAINER_REFRESH_SECONDS`** - Container refresh interval
  - Default: `25`

### Example .env File

```bash
# GTM Configuration
CONTAINER_CONFIG=aWQ9R1RNLVdSOUo0NTROJmVudj0xJmF1dGg9bnRMejlYRHhVU1RBd1VaOHdSb3N2dw==
CONTAINER_REFRESH_SECONDS=25
```

---

## Troubleshooting

### Containers Not Starting

```bash
# Check container status
docker-compose ps

# View logs for specific service
docker-compose logs gtm-live
docker-compose logs gtm-preview
docker-compose logs nginx
docker-compose logs ssl-init

# Check all logs
docker-compose logs -f
```

### SSL Certificate Issues

SSL certificates are automatically generated. If there are issues:

```bash
# Manually regenerate certificates
./generate-ssl.sh

# Check if certificates exist
ls -la ssl/

# Remove and regenerate
rm -rf ssl/
docker-compose up -d
```

### GTM Container Configuration Issues

```bash
# Verify CONTAINER_CONFIG is set
docker exec gtm-live env | grep CONTAINER_CONFIG
docker exec gtm-preview env | grep CONTAINER_CONFIG

# If empty, check your .env file
cat .env

# Restart containers after .env changes
docker-compose restart
```

### Port Already in Use

```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process (replace PID)
kill -9 <PID>

# Or change the port in .env
echo "PORT=3001" >> .env
docker-compose up -d
```

### HTTPS Browser Warnings

Self-signed certificates will show browser warnings. This is normal for local development.

**Chrome**: Click "Advanced" → "Proceed to localhost (unsafe)"
**Firefox**: Click "Advanced" → "Accept the Risk and Continue"
**Safari**: Click "Show Details" → "visit this website"

### Reset Everything

```bash
# Stop and remove all containers
docker-compose down

# Remove everything including images
docker-compose down --rmi all --volumes

# Remove SSL certificates
rm -rf ssl/

# Start fresh
docker-compose up -d --build
```

---

## License

MIT License - feel free to use this in your projects!
