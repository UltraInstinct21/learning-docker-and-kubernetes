#!/bin/sh

# ==============================================================================
# SCRIPT: TRAFFIC GENERATOR SCRIPT
# ==============================================================================
# Usage:
#   ./traffic-gen.sh <target_url> <interval_in_seconds>
#
# Examples:
#   ./traffic-gen.sh http://localhost:8080/api 1
#   ./traffic-gen.sh http://color-api-clusterip/api 0.5
# ==============================================================================

if [ $# -lt 2 ]
then
    echo "Usage: $0 <target> <interval in seconds>"
    exit 1
fi

TARGET=$1
INTERVAL=$2

echo "Starting traffic generator targeting $TARGET every ${INTERVAL}s..."

while true;
do
    REQUEST_TIME=$(date +%Y-%m-%d"T"%H:%M:%S)
    RESPONSE=$(curl -s "$TARGET")
    echo " [$REQUEST_TIME] - $RESPONSE"
    sleep $INTERVAL
done