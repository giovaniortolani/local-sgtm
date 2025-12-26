#!/bin/bash

# Run Performance Test with WRK
#
# This script executes a performance test using `wrk` with customizable parameters.
# It targets a local server and uses a Lua script (`benchmark.lua`) for request generation.
#
# Usage:
#   ./run-performance-test.sh [options] [profile] [x-gtm-server-preview]
#
# Arguments:
#   [profile]       Optional. The benchmark profile to use (defined in benchmark.lua).
#                   Possible options: "ga4_pageview", "ga4_purchase" and "datatag_pageview"
#                   Default: "ga4_pageview"
#   [x-gtm-server-preview] Optional. The X-GTM-Server-Preview header value.
#                          Default: ""
#
# Options:
#   -t <threads>    Number of threads to use. Default: 4
#   -c <conns>      Total number of HTTP connections to keep open. Default: 8
#   -d <duration>   Duration of the test (e.g., 20s, 2m). Default: 20s
#   --timeout <tm>  Record a timeout if a response is not received within this time. Default: 10s
#
# Environment Variables:
#   PORT_TAGGING_SERVER  The port of the tagging server. Default: 8888
#
# Examples:
#   ./run-performance-test.sh
#   ./run-performance-test.sh ga4_purchase
#   ./run-performance-test.sh ga4_pageview ZW52LTN8cTlhaXNfYWtOQ3x==
#   ./run-performance-test.sh -t 8 -c 20 -d 30s ga4_purchase


# Default values
THREADS=4
CONNECTIONS=8
DURATION="20s"
TIMEOUT="10s"
PROFILE="ga4_pageview"
PREVIEW_HEADER=""
PORT="${PORT_TAGGING_SERVER:-8888}"

# Track if profile was explicitly set to avoid overwriting it with preview header logic incorrectly if mixed with flags
# However, simple positional parsing assumes order: PROFILE then PREVIEW_HEADER
POSITIONAL_ARGS=()

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -t)
      THREADS="$2"
      shift 2
      ;;
    -c)
      CONNECTIONS="$2"
      shift 2
      ;;
    -d)
      DURATION="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Assign positional arguments
if [ ${#POSITIONAL_ARGS[@]} -ge 1 ]; then
  PROFILE="${POSITIONAL_ARGS[0]}"
fi
if [ ${#POSITIONAL_ARGS[@]} -ge 2 ]; then
  PREVIEW_HEADER="${POSITIONAL_ARGS[1]}"
fi

wrk -t"$THREADS" -c"$CONNECTIONS" -d"$DURATION" -s benchmark.lua --timeout "$TIMEOUT" "https://localhost:$PORT" "$PROFILE" "$PREVIEW_HEADER"