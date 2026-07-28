#!/bin/bash

# Log Archive Tool
# roadmap.sh DevOps Project


if [ -z "$1" ]; then
    echo "Usage: $0 <log-directory>"
    exit 1
fi


LOG_DIR=$1


if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory does not exist"
    exit 1
fi


ARCHIVE_DIR="./archives"

mkdir -p "$ARCHIVE_DIR"


DATE=$(date +"%Y%m%d_%H%M%S")

ARCHIVE_NAME="logs_archive_${DATE}.tar.gz"


tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" "$LOG_DIR"


if [ $? -eq 0 ]; then
    echo "Log archive created successfully:"
    echo "$ARCHIVE_DIR/$ARCHIVE_NAME"
else
    echo "Failed to create archive"
    exit 1
fi


echo "Archive created at: $(date)" >> "$ARCHIVE_DIR/archive.log"