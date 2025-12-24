# Local Server-Side Google Tag Manager

Simulates a Google Tag Manager Server-Side environment locally using Docker. Perfect for debugging/developing your server-side implementation and Data Client/Tag templates without needing cloud infrastructure (GCP/AWS).

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
CONTAINER_CONFIG=aWQ9AAANLVdSOUo0NTROJmVudj0xJmF1dGg9bnRMejlYRHhVU1RBd1VaOHdSb3N2dw==
CONTAINER_REFRESH_SECONDS=25
```

---

## Custom Domains

You can use a custom domain (e.g., `https://sgtm.example.com`) instead of `localhost`.

### 1. Configure the Domain

Edit your `.env` file and set the `CUSTOM_DOMAIN` variable:

```bash
CUSTOM_DOMAIN=sgtm.example.com
```

### 2. Update Hosts File

Map the domain to your local machine in `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add this line:
```
127.0.0.1 sgtm.example.com
```

### 3. Regenerate Certificates

If you already have containers running, you need to regenerate the SSL certificates:

```bash
# Remove old certificates
rm -rf ssl/

# Restart and rebuild to generate new ones
docker-compose down
docker-compose up -d
```

### 4. Access the Servers

- **Live Server**: `https://sgtm.example.com` (Port 443) OR `https://sgtm.example.com:8888`
- **Preview Server**: `https://sgtm.example.com:8889`

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
# Find what's using the default ports
lsof -i :8888
lsof -i :8889
lsof -i :443

# To change ports, you must edit docker-compose.yml directly:
# 1. Open docker-compose.yml
# 2. Locate the 'nginx' service
# 3. Modify the ports section (HostPort:ContainerPort):
#    ports:
#      - 'YOUR_NEW_PORT:8888'
#      - 'YOUR_PREVIEW_PORT:8889'
#      - 'YOUR_HTTPS_PORT:8888'  (Optional 443 mapping)

# After changing ports, restart the stack:
docker-compose down
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

---

Forked from [justushamalainen/datalayer-relay](https://github.com/justushamalainen/datalayer-relay).
