# Performance Testing Tools

This directory contains scripts and tools for benchmarking and stress-testing the local sGTM (Server-Side Google Tag Manager) environment. These tools help in evaluating the performance and stability of the sGTM container under load.

> ⚠️ Avoid using the Preview Version when testing, because it can have overhead when comparing to the Live Version.
>
> Try to always publish the version you want to test (e.g. set as the Live version) an run the tests against it.


## Tools Overview

### 1. [`run-performance-test.sh`](./run-performance-test.sh)

**Prerequisites**

- **Homebrew**: [Install Homebrew](https://brew.sh/#install) if you haven't already.
- **Install `wrk`**: You need to install `wrk` benchmarking tool.
  ```bash
  brew install wrk
  ```

This is the main script for running performance tests using `wrk`. It wraps the `wrk` command and provides a user-friendly interface for configuring test parameters and selecting benchmark profiles.

**Usage:**
```bash
./run-performance-test.sh [options] [profile] [x-gtm-server-preview header value]
```

**Arguments:**
- `[profile]`: The benchmark profile to use (defined in `benchmark.lua`).
    - Defaults to `"ga4_pageview"`.
    - Other common options (check `benchmark.lua` for full list): `"ga4_purchase"`, `"datatag_pageview"`.
- `[x-gtm-server-preview header value]`: Optional `X-GTM-Server-Preview` header value for debugging sessions.

**Options:**
- `-t <threads>`: Number of threads to use (Default: 4).
- `-c <conns>`: Total number of HTTP connections to keep open (Default: 8).
- `-d <duration>`: Duration of the test, e.g., `20s`, `2m` (Default: `20s`).
- `--timeout <tm>`: Socket/request timeout (Default: `10s`).

**Environment Variables:**
- `PORT_TAGGING_SERVER`: Sets the target port (Default: `8888`).

**Examples:**
```bash
# Run with default settings (ga4_pageview, 4 threads, 8 conns, 20s)
./run-performance-test.sh

# Run with a specific profile
./run-performance-test.sh ga4_purchase

# Run with custom load settings
./run-performance-test.sh -t 8 -c 20 -d 30s ga4_pageview

# Run with a debug header
./run-performance-test.sh ga4_pageview ZW52LTN8cTlhaXNfYWtOQ3x==
```

#### [`benchmark.lua`](./benchmark.lua)

This Lua script is the configuration file for `wrk`. It defines the HTTP requests structure (method, path, headers, body) for different testing scenarios (profiles).

- **Role:** It is loaded by `run-performance-test.sh` via the `-s` flag.
- **Customization:** Edit this file to add new test profiles or modify existing request payloads (e.g., changing GA4 Measurement IDs or event data).

---

### 2. [`flood-container-with-curl.sh`](./flood-container-with-curl.sh)

A simple shell script to "flood" the container with a sequence of `curl` requests. Unlike `wrk` which is designed for high-concurrency benchmarking, this script is useful for generating a controlled, countable number of requests, often for functional verification under light load.

**Usage:**
```bash
./flood-container-with-curl.sh [num_requests]
```

**Arguments:**
- `[num_requests]`: The number of `curl` requests to fire (Default: `50`).

**Example:**
```bash
# Fire 100 requests
./flood-container-with-curl.sh 100
```

---

### 3. [`docker_stats_gtm_live_container_to_csv.sh`](./docker_stats_gtm_live_container_to_csv.sh)

A monitoring utility that captures real-time resource usage statistics of the `gtm-live` Docker container and saves them to a CSV file.

**Usage:**
```bash
./docker_stats_gtm_live_container_to_csv.sh [output_file]
```

**Arguments:**
- `[output_file]`: The filename for the CSV output (Default: `container_stats.csv`).

**Output Format:**
The CSV file will contain columns for: `Timestamp`, `Container Name`, `CPU %`, `Mem Usage`, `Net I/O`, `Block I/O`, `PIDs`.

**Example:**
```bash
# Start recording stats to 'test_run_1.csv'
./docker_stats_gtm_live_container_to_csv.sh test_run_1.csv
```
Press `CTRL+C` to stop recording.
