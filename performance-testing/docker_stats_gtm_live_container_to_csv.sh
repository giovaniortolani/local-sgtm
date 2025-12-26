#!/bin/bash

# Docker Stats to CSV Recorder
#
# This script monitors the `gtm-live` container's resource usage and records
# the stats (CPU, Memory, Net I/O, Block I/O, PIDs) to a CSV file in real-time.
#
# Usage:
#   ./docker_stats_gtm_live_container_to_csv.sh [output_file]
#
# Arguments:
#   [output_file]   Optional. The name of the CSV file to write to.
#                   Default: "container_stats.csv"
#
# Examples:
#   ./docker_stats_gtm_live_container_to_csv.sh
#   ./docker_stats_gtm_live_container_to_csv.sh my_test_stats.csv

# Output file name
OUTPUT_FILE="${1:-container_stats.csv}"


# Check if file exists, if not, write the header row
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Timestamp,Container Name,CPU %,Mem Usage,Net I/O,Block I/O,PIDs" > "$OUTPUT_FILE"
fi

echo "Recording stats to $OUTPUT_FILE..."
echo "Press [CTRL+C] to stop."

# We use 'docker stats' with a custom format string to generate comma-separated values.
# We pipe the output into a while loop to prepend the current timestamp to every line.
# Note: We do NOT use --no-stream because CPU% requires a previous sample to calculate correctly.
docker stats gtm-live --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}" | \
sed -u "s/\x1b\[[0-9;]*[a-zA-Z]//g" | \
while read line; do
    # Skip empty lines caused by sed stripping or stream refresh signals
    if [ -z "$line" ]; then
        continue
    fi

    # Get current timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # Append to file
    echo "$TIMESTAMP,$line" >> "$OUTPUT_FILE"

    # Optional: Print to console so you know it's working
    echo "$TIMESTAMP,$line"

    sleep 1
done