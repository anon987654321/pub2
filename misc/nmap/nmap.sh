#!/bin/bash

# Network scanning with nmap
# Security scanning and network discovery tool

set -e

if ! command -v nmap >/dev/null 2>&1; then
    echo "nmap not found. Install with: pkg_add nmap"
    exit 1
fi

show_usage() {
    echo "Usage: $0 [options] target"
    echo "Options:"
    echo "  -p PORT    Scan specific port"
    echo "  -r RANGE   Scan port range (e.g., 1-1000)"  
    echo "  -s         Service detection"
    echo "  -v         Verbose output"
    echo "  -h         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 192.168.1.1"
    echo "  $0 -p 80 example.com"
    echo "  $0 -r 1-1000 -s 192.168.1.0/24"
}

# Parse command line options
PORT=""
RANGE=""
SERVICE=""
VERBOSE=""
TARGET=""

while getopts "p:r:svh" opt; do
    case $opt in
        p) PORT="$OPTARG" ;;
        r) RANGE="$OPTARG" ;;
        s) SERVICE="-sV" ;;
        v) VERBOSE="-v" ;;
        h) show_usage; exit 0 ;;
        *) show_usage; exit 1 ;;
    esac
done

shift $((OPTIND-1))
TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "Error: Target is required"
    show_usage
    exit 1
fi

# Build nmap command
NMAP_CMD="nmap"

if [ -n "$PORT" ]; then
    NMAP_CMD="$NMAP_CMD -p $PORT"
elif [ -n "$RANGE" ]; then
    NMAP_CMD="$NMAP_CMD -p $RANGE"
fi

if [ -n "$SERVICE" ]; then
    NMAP_CMD="$NMAP_CMD $SERVICE"
fi

if [ -n "$VERBOSE" ]; then
    NMAP_CMD="$NMAP_CMD $VERBOSE"
fi

NMAP_CMD="$NMAP_CMD $TARGET"

echo "Running: $NMAP_CMD"
echo "=========================="
$NMAP_CMD