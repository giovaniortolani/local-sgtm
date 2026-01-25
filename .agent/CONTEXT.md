# Project Context: Local sGTM & Performance Suite

**Project Name:** `local-sgtm`
**Purpose:** Simulates a Google Tag Manager (sGTM) Server-Side environment locally using Docker, with built-in performance benchmarking and debugging capabilities.

## 1. High-Level Architecture

The project uses `docker-compose` to spin up a complete sGTM stack.

*   **`nginx` (Proxy)**: Entry point. Listens on ports:
    *   `8888` (Live Server)
    *   `8889` (Preview Server)
    *   `443` (HTTPS for Custom Domain)
    *   Routes traffic to internal containers `gtm-live` and `gtm-preview`.
*   **`gtm-live`**: The production sGTM Node.js server.
    *   Internal Port: `8080`
    *   Debug Port: `9229` (Node.js Inspector)
*   **`gtm-preview`**: The sGTM server running in debug/preview mode.
    *   Internal Port: `8080`
    *   Debug Port: `9228` (Node.js Inspector)
*   **`ssl-init`**: One-off helper container to generate self-signed SSL certificates for `localhost` and custom domains.

## 2. Directory Structure & Key Files

```text
/
├── docker-compose.yml       # Main stack definition. Defines 4 services.
├── .env                     # Configuration (GTM container config, ports, limits).
├── nginx.conf               # Nginx routing logic for Live vs Preview.
├── README.md                # General user documentation.
├── generate-ssl.sh          # Helper script used by ssl-init container.
│
├── performance-testing/     # Suite for benchmarking sGTM.
│   ├── README.md            # Docs for performance tools.
│   ├── run-performance-test.sh # Main entry point. Wraps 'wrk'.
│   ├── benchmark.lua        # 'wrk' Lua script defining request profiles (GA4, Data Tag).
│   └── *.sh                 # Specific helper scripts (flood, stats recording).
│
└── nodejs-server-files-debugging/ # Research & Tools for modifying sGTM internals.
    ├── README.md            # Documentation for debugging suite.
    ├── setup_debug.sh       # Main script to patch and restart containers.
    ├── scripts/             # Helper scripts (e.g., patcher).
    └── server-files/        # Directory where extracted/patched files reside locally.
```

## 3. Operational Guide

### Starting the Environment
```bash
# 1. Ensure .env is configured (requires CONTAINER_CONFIG base64 string)
# 2. Start stack
docker-compose up -d

# 3. Verify health
docker-compose ps
curl -k https://localhost:8888/healthy
```

### Running Performance Tests
Tools are located in `performance-testing/`. This relies on `wrk`.
```bash
cd performance-testing

# Run default load test (GA4 Pageview profile)
./run-performance-test.sh

# Run specific profile (defined in benchmark.lua)
./run-performance-test.sh ga4_purchase
```

### Debugging & Inspection
The `nodejs-server-files-debugging` directory contains tools to "jailbreak" the sGTM container.

*   **Setup**: `./nodejs-server-files-debugging/setup_debug.sh`
    1.  Extracts `server_bin.js` from `gtm-live`.
    2.  Downloads `server.js` and `server_bootstrap.js` from Google.
    3.  Monkey-patches `server_bin.js` to log traffic and serve local files.
    4.  Injects files back and restarts containers.
*   **Logs**:
    *   ➡️🤖 `[INCOMING HTTP REQUEST]`
    *   ➡️🤖📦 `[INCOMING HTTP REQUEST BODY]`
    *   ⬅️🤖 `[INCOMING HTTP RESPONSE]`
    *   ➡️🛜 `[OUTGOING HTTP REQUEST]`
    *   ➡️🛜📦 `[OUTGOING HTTP REQUEST BODY]`
    *   ⬅️🛜📦 `[OUTGOING HTTP RESPONSE]`
*   **Inspector**: Attach Chrome DevTools to `localhost:9229` (Live) or `localhost:9228` (Preview).

## 4. Configuration Reference (`.env`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CONTAINER_CONFIG` | **REQUIRED**. Base64 encoded string from GTM Admin. | - |
| `CUSTOM_DOMAIN` | Hostname for local mapping (requires `/etc/hosts` edit). | `localhost` |
| `PORT_TAGGING_SERVER` | Port for Live Server traffic. | `8888` |
| `PORT_PREVIEW_SERVER` | Port for Preview Server traffic. | `8889` |
| `DEBUGGING_ENABLED` | Set to `true` to enable Node.js inspector ports. | - |
| `GTM_MEMORY_LIMIT` / `GTM_CPU_LIMIT` | Resource constraints for Docker. | Unlimited |

## 5. Agent Tips
*   **SSL**: The project uses self-signed certs. **ALWAYS** use `curl -k` or ignore SSL errors in tools.
*   **Health Checks**: The containers have built-in healthchecks tailored for sGTM (`/healthy` endpoint).
*   **Performance**: The `benchmark.lua` file is the source of truth for *what* data is being sent during tests. detailed payload analysis happens there.
*   **Debugging Status**: If the user asks about "patching" or "intercepting" requests, refer to `nodejs-server-files-debugging`. If `DEBUGGING_ENABLED` is not set in `.env`, these features won't work.
