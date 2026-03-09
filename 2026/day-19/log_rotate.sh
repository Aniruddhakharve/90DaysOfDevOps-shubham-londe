#!/bin/bash

# This script performs log rotation on a given directory.
# It compresses .log files older than 7 days
# and deletes compressed .gz files older than 30 days.

# First argument passed to the script will be treated as the log directory
LOG_DIR=$1

# Check if the user provided a directory argument
if [ -z "$LOG_DIR" ]; then
    echo "Usage: ./log_rotate.sh <log_directory>"
    exit 1
fi

# Check if the provided directory actually exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory does not exist"
    exit 1
fi

# Print message indicating log rotation has started
echo "Starting log rotation in directory: $LOG_DIR"

# Counters to keep track of number of files processed
compressed=0
deleted=0

# Find .log files older than 7 days and compress them using gzip
# -name "*.log" → select log files
# -mtime +7 → files modified more than 7 days ago
for file in $(find "$LOG_DIR" -name "*.log" -mtime +7); do
    gzip "$file"
    ((compressed++))
done

# Find compressed .gz files older than 30 days and delete them
# -name "*.gz" → compressed log files
# -mtime +30 → older than 30 days
for file in $(find "$LOG_DIR" -name "*.gz" -mtime +30); do
    rm -f "$file"
    ((deleted++))
done

# Print summary of operations
echo "Total log files compressed: $compressed"
echo "Total old compressed logs deleted: $deleted"
