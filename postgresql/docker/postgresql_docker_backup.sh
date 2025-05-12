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

# Function to print separator
print_separator() {
    local char=${1:-"-"}
    local length=${2:-80}
    printf "%${length}s\n" | tr " " "$char"
}

# Function to print centered text
print_centered() {
    local text="$1"
    local width=${2:-80}
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

# Function to log messages
log_message() {
    local message="$1"
    local timestamp=$(get_human_readable_datetime)
    local formatted_message="[${timestamp}] $message"
    
    # Only show important messages in console
    if [[ "$message" == *"ERROR"* ]] || [[ "$message" == *"Successfully"* ]]; then
        echo "$formatted_message"
    fi
    
    # Write everything to log file
    echo "$formatted_message" >> "$BACKUPS_LOG_FILE"
}

# Function to log section start
log_section_start() {
    local section_name="$1"
    local timestamp=$(get_human_readable_datetime)
    local section_header="$section_name Started at $timestamp"
    
    # Add section header to log file only
    {
        print_separator "=" >> "$BACKUPS_LOG_FILE"
        print_centered "$section_header" >> "$BACKUPS_LOG_FILE"
        print_separator "=" >> "$BACKUPS_LOG_FILE"
    }
    
    log_message "Starting $section_name..."
}

# Function to log section end
log_section_end() {
    local section_name="$1"
    log_message "Completed $section_name"
}

# Function to create backup directory
create_backup_directory() {
    local temp_dir="${BACKUPS_BACKUP_PATH}_temp"
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

    if mv "$temp_dir"/* "$BACKUPS_BACKUP_PATH"/; then
        log_message "Successfully finalized backup in $BACKUPS_BACKUP_PATH"
        rm -rf "$temp_dir"
        return 0
    else
        log_message "ERROR: Failed to finalize backup"
        return 1
    fi
}

# Function to remove old backups
remove_old_backups() {
    log_message "Retention Policy: Keeping $BACKUPS_MAX_FILES most recent backups"

    # Get list of backup files sorted by modification time (newest first)
    local backup_files=($(ls -t "$BACKUPS_BACKUP_PATH"/*.sql 2>/dev/null))
    local total_files=${#backup_files[@]}

    # If we have more files than BACKUPS_MAX_FILES, remove the oldest ones
    if [ $total_files -gt $BACKUPS_MAX_FILES ]; then
        log_message "Found $total_files backup files, removing oldest $(($total_files - $BACKUPS_MAX_FILES)) files"
        for ((i=BACKUPS_MAX_FILES; i<total_files; i++)); do
            local file_to_remove="${backup_files[$i]}"
            log_message "Removing old backup file: $(basename "$file_to_remove")"
            rm -f "$file_to_remove"
        done
    else
        log_message "Current backup count ($total_files) is within retention limit ($BACKUPS_MAX_FILES)"
    fi
}

# Function to backup PostgreSQL database
backup_postgres_database() {
    # Set default prefix if not defined in .env
    local prefix=${BACKUPS_FILE_PREFIX:-postgres_docker_backup}
    local backup_file="$TIMESTAMPED_BACKUP_PATH/${prefix}_$DATETIME.sql"
    
    log_message "Target Database: $BACKUPS_DATABASE_NAME"
    log_message "Container: $BACKUPS_CONTAINER_NAME"
    log_message "Backup File: $(basename "$backup_file")"
    
    if docker exec "$BACKUPS_CONTAINER_NAME" pg_dump -U "$BACKUPS_DATABASE_USER" "$BACKUPS_DATABASE_NAME" > "$backup_file"; then
        log_message "Successfully executed pg_dump for database '$BACKUPS_DATABASE_NAME'"
        return 0
    else
        log_message "ERROR: Failed to create database backup for '$BACKUPS_DATABASE_NAME'"
        return 1
    fi
}

# Function to validate environment variables
validate_env_vars() {
    # Check required environment variables
    if [ -z "$BACKUPS_CONTAINER_NAME" ] || [ -z "$BACKUPS_DATABASE_NAME" ] || [ -z "$BACKUPS_DATABASE_USER" ] || [ -z "$BACKUPS_BACKUP_PATH" ] || [ -z "$BACKUPS_LOG_FILE" ]; then
        echo "Error: Required environment variables are not set in .env file"
        echo "Please set the following variables in your .env file:"
        echo "  BACKUPS_CONTAINER_NAME: Name of the PostgreSQL container"
        echo "  BACKUPS_DATABASE_NAME: Name of the database to backup"
        echo "  BACKUPS_DATABASE_USER: Database user with backup privileges"
        echo "  BACKUPS_BACKUP_PATH: Directory to store backups"
        echo "  BACKUPS_LOG_FILE: Path to log file"
        exit 1
    fi
}

# Function to validate container
validate_container_name() {
    if ! docker ps | grep -q "$BACKUPS_CONTAINER_NAME"; then
        echo "Error: Container '$BACKUPS_CONTAINER_NAME' is not running or does not exist."
        exit 1
    fi
}

# Function to validate backup path
validate_backup_path() {
    if [ ! -w "$(dirname "$BACKUPS_BACKUP_PATH")" ]; then
        echo "Error: Backup path '$BACKUPS_BACKUP_PATH' is not writable or does not exist."
        exit 1
    fi
}

# Function to validate log file
validate_log_file() {
    local log_dir=$(dirname "$BACKUPS_LOG_FILE")

    mkdir -p "$log_dir"
    
    if [ ! -w "$log_dir" ]; then
        echo "Error: Log directory '$log_dir' is not writable."
        exit 1
    fi

    touch "$BACKUPS_LOG_FILE"
}

# Function to display help message
help() {
    echo "This script creates a backup of a PostgreSQL database running inside a Docker container."
    echo "Configuration:"
    echo "  - All settings must be configured in the .env file"
    echo "  - Required settings:"
    echo "    BACKUPS_CONTAINER_NAME: Name of the PostgreSQL container"
    echo "    BACKUPS_DATABASE_NAME: Name of the database to backup"
    echo "    BACKUPS_DATABASE_USER: Database user with backup privileges"
    echo "    BACKUPS_BACKUP_PATH: Directory to store backups"
    echo "    BACKUPS_LOG_FILE: Path to log file"
    echo "  - Optional settings:"
    echo "    BACKUPS_MAX_FILES: Number of backups to keep (default: 5)"
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

log_section_start "Backup Process"
log_message "Configuration Summary:"
log_message "  Container: $BACKUPS_CONTAINER_NAME"
log_message "  Database: $BACKUPS_DATABASE_NAME"
log_message "  User: $BACKUPS_DATABASE_USER"
log_message "  Backup Path: $BACKUPS_BACKUP_PATH"
log_message "  Log File: $BACKUPS_LOG_FILE"
log_message "  Max Backups: $BACKUPS_MAX_FILES"

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
remove_old_backups

log_message "Backup completed successfully"
exit 0 