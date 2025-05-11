#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Function to get formatted datetime for backup naming
get_datetime() {
    date +"%Y%m%d_%H%M%S"
}

# Function to get formatted datetime for logging
get_human_readable_datetime() {
    date +"%F %T.%3N"
}

# Function to log messages
log_message() {
    local message="$1"
    echo "$message"
    echo "$(get_human_readable_datetime) $message" >> "$LOG_FILE"
}

# Function to create backup directory
create_backup_directory() {
    local temp_dir="${BACKUP_PATH}_temp"
    mkdir -p "$temp_dir"
    echo "$temp_dir"
}

# Function to remove failed backup
remove_failed_backup() {
    local backup_dir=$1
    log_message "Removing failed backup directory: $backup_dir"

    if rm -rf "$backup_dir"; then
        log_message "Successfully removed failed backup directory"
        return 0
    else
        log_message "ERROR: Failed to remove backup directory"
        return 1
    fi
}

# Function to finalize backup
finalize_backup() {
    local temp_dir=$1

    if mv "$temp_dir"/* "$BACKUP_PATH"/; then
        log_message "Successfully finalized backup in $BACKUP_PATH"
        rm -rf "$temp_dir"
        return 0
    else
        log_message "ERROR: Failed to finalize backup"
        return 1
    fi
}

# Function to remove old backups
remove_old_backups() {
    log_message "Keeping only the $MAX_BACKUPS most recent backups"

    # Get list of backup files sorted by modification time (newest first)
    local backup_files=($(ls -t "$BACKUP_PATH"/*.sql 2>/dev/null))
    local total_files=${#backup_files[@]}

    # If we have more files than MAX_BACKUPS, remove the oldest ones
    if [ $total_files -gt $MAX_BACKUPS ]; then
        for ((i=MAX_BACKUPS; i<total_files; i++)); do
            local file_to_remove="${backup_files[$i]}"
            log_message "Removing old backup file: $(basename "$file_to_remove")"
            rm -f "$file_to_remove"
        done
    fi

    log_message "Successfully cleaned up old backups"
}

# Function to backup PostgreSQL database
backup_postgres_database() {
    local backup_file="$TIMESTAMPED_BACKUP_PATH/db_backup_$DATETIME.sql"
    
    log_message "Starting PostgreSQL backup for database '$DB_NAME'..."
    
    if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$backup_file"; then
        log_message "Successfully executed pg_dump for database '$DB_NAME'"
        return 0
    else
        log_message "ERROR: Failed to create database backup for '$DB_NAME'"
        return 1
    fi
}

# Function to validate environment variables
validate_env_vars() {
    # Check required environment variables
    if [ -z "$CONTAINER_NAME" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$BACKUP_PATH" ] || [ -z "$LOG_FILE" ]; then
        echo "Error: Required environment variables are not set in .env file"
        echo "Please set CONTAINER_NAME, DB_NAME, DB_USER, BACKUP_PATH, and LOG_FILE"
        exit 1
    fi
}

# Function to validate container
validate_container_name() {
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        echo "Error: Container '$CONTAINER_NAME' is not running or does not exist."
        exit 1
    fi
}

# Function to validate backup path
validate_backup_path() {
    if [ ! -w "$(dirname "$BACKUP_PATH")" ]; then
        echo "Error: Backup path '$BACKUP_PATH' is not writable or does not exist."
        exit 1
    fi
}

# Function to validate log file
validate_log_file() {
    local log_dir=$(dirname "$LOG_FILE")

    mkdir -p "$log_dir"
    
    if [ ! -w "$log_dir" ]; then
        echo "Error: Log directory '$log_dir' is not writable."
        exit 1
    fi

    touch "$LOG_FILE"
}

# Function to display help message
help() {
    echo "This script creates a backup of a PostgreSQL database running inside a Docker container."
    echo "Configuration:"
    echo "  - All settings must be configured in the .env file"
    echo "  - Required settings:"
    echo "    CONTAINER_NAME: Name of the PostgreSQL container"
    echo "    DB_NAME: Name of the database to backup"
    echo "    DB_USER: Database user with backup privileges"
    echo "    BACKUP_PATH: Directory to store backups"
    echo "    LOG_FILE: Path to log file"
    echo "  - Optional settings:"
    echo "    MAX_BACKUPS: Number of backups to keep (default: 4)"
}

# Display help if -h or --help is passed
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    help
    exit 0
fi

# Validate environment variables
validate_env_vars

# Validate container and paths
validate_container_name
validate_backup_path
validate_log_file

log_message "Backup started"

# Create timestamped backup directory
DATETIME=$(get_datetime)
TIMESTAMPED_BACKUP_PATH=$(create_backup_directory)
log_message "Backup directory created at $TIMESTAMPED_BACKUP_PATH"

# Perform PostgreSQL database backup
if ! backup_postgres_database; then
    log_message "Backup failed. Removing backup files..."
    remove_failed_backup "$TIMESTAMPED_BACKUP_PATH"
    exit 1
fi

# Finalize backup by moving from temporary to final location
if ! finalize_backup "$TIMESTAMPED_BACKUP_PATH"; then
    log_message "Failed to finalize backup"
    exit 1
fi

# Remove old backups after successful backup
remove_old_backups "$BACKUP_PATH"

log_message "Backup completed successfully"
exit 0
