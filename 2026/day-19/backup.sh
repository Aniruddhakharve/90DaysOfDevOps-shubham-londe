#!/bin/bash

# This script creates a compressed backup archive of a source directory.
# It also deletes backups older than 14 days.

# First argument → source directory to backup
SOURCE_DIR=$1

# Second argument → destination directory where backups will be stored
BACKUP_DIR=$2

# Check if both arguments are provided
if [ -z "$SOURCE_DIR" ] || [ -z "$BACKUP_DIR" ]; then
    echo "Usage: ./backup.sh <source_directory> <backup_directory>"
    exit 1
fi

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Generate a timestamp for unique backup filenames
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)

# Define the archive file name
ARCHIVE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

# Create a compressed tar archive of the source directory
tar -czf "$ARCHIVE" "$SOURCE_DIR"

# Check if the backup command was successful
if [ $? -eq 0 ]; then
    echo "Backup created successfully: $ARCHIVE"

    # Display the size of the backup file
    du -h "$ARCHIVE"
else
    echo "Backup failed"
    exit 1
fi

# Delete backup archives older than 14 days
# -mtime +14 → files older than 14 days
find "$BACKUP_DIR" -name "backup-*.tar.gz" -mtime +14 -delete
