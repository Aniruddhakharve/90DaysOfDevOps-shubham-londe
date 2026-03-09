#!/bin/bash

# This script performs scheduled maintenance tasks.
# It runs log rotation and backup scripts
# and writes all output into a maintenance log file.

# Define log file path where script activity will be recorded
LOGFILE="/var/log/maintenance.log"

# Define paths used by backup and log rotation scripts
LOG_DIR="./testlogs"
SOURCE_DIR="./data"
BACKUP_DIR="./backups"

# Write start timestamp into maintenance log
echo "$(date): Maintenance process started" >> "$LOGFILE"

# Run log rotation script
# stdout and stderr are appended to maintenance log
./log_rotate.sh "$LOG_DIR" >> "$LOGFILE" 2>&1

# Run backup script
./backup.sh "$SOURCE_DIR" "$BACKUP_DIR" >> "$LOGFILE" 2>&1

# Write completion timestamp into maintenance log
echo "$(date): Maintenance process completed" >> "$LOGFILE"
