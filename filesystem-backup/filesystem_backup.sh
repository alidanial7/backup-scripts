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
    echo "$formatted_message" >> "$FILESYSTEM_LOG_FILE"
}

# Function to log section start
log_section_start() {
    local section_name="$1"
    local timestamp=$(get_human_readable_datetime)
    local section_header="$section_name Started at $timestamp"
    
    # Add section header to log file only
    {
        print_separator "=" >> "$FILESYSTEM_LOG_FILE"
        print_centered "$section_header" >> "$FILESYSTEM_LOG_FILE"
        print_separator "=" >> "$FILESYSTEM_LOG_FILE"
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
    local temp_dir="${FILESYSTEM_BACKUP_PATH}_temp"
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

    if mv "$temp_dir"/* "$FILESYSTEM_BACKUP_PATH"/; then
        log_message "Successfully finalized backup in $FILESYSTEM_BACKUP_PATH"
        rm -rf "$temp_dir"
        return 0
    else
        log_message "ERROR: Failed to finalize backup"
        return 1
    fi
}

# Function to remove old backups
remove_old_backups() {
    log_message "Retention Policy: Keeping $FILESYSTEM_MAX_FILES most recent backups"

    # Get list of backup files sorted by modification time (newest first)
    local backup_files=($(ls -t "$FILESYSTEM_BACKUP_PATH"/*.tar.gz 2>/dev/null))
    local total_files=${#backup_files[@]}

    # If we have more files than FILESYSTEM_MAX_FILES, remove the oldest ones
    if [ $total_files -gt $FILESYSTEM_MAX_FILES ]; then
        log_message "Found $total_files backup files, removing oldest $(($total_files - $FILESYSTEM_MAX_FILES)) files"
        for ((i=FILESYSTEM_MAX_FILES; i<total_files; i++)); do
            local file_to_remove="${backup_files[$i]}"
            log_message "Removing old backup file: $(basename "$file_to_remove")"
            rm -f "$file_to_remove"
        done
    else
        log_message "Current backup count ($total_files) is within retention limit ($FILESYSTEM_MAX_FILES)"
    fi
}

# Function to backup filesystem
backup_filesystem() {
    # Set default prefix if not defined in .env
    local prefix=${FILESYSTEM_FILE_PREFIX:-filesystem_backup}
    local backup_file="$TIMESTAMPED_BACKUP_PATH/${prefix}_$DATETIME.tar.gz"
    
    log_message "Target Directory: $FILESYSTEM_SOURCE_PATH"
    log_message "Backup File: $(basename "$backup_file")"
    
    # Create tar archive with compression
    if tar -czf "$backup_file" -C "$(dirname "$FILESYSTEM_SOURCE_PATH")" "$(basename "$FILESYSTEM_SOURCE_PATH")"; then
        log_message "Successfully created backup archive for '$FILESYSTEM_SOURCE_PATH'"
        return 0
    else
        log_message "ERROR: Failed to create backup archive for '$FILESYSTEM_SOURCE_PATH'"
        return 1
    fi
}

# Function to validate environment variables
validate_env_vars() {
    # Check required environment variables
    if [ -z "$FILESYSTEM_SOURCE_PATH" ] || [ -z "$FILESYSTEM_BACKUP_PATH" ] || [ -z "$FILESYSTEM_LOG_FILE" ]; then
        echo "Error: Required environment variables are not set in .env file"
        echo "Please set the following variables in your .env file:"
        echo "  FILESYSTEM_SOURCE_PATH: Path to the directory to backup"
        echo "  FILESYSTEM_BACKUP_PATH: Directory to store backups"
        echo "  FILESYSTEM_LOG_FILE: Path to log file"
        exit 1
    fi
}

# Function to validate source path
validate_source_path() {
    if [ ! -r "$FILESYSTEM_SOURCE_PATH" ]; then
        echo "Error: Source path '$FILESYSTEM_SOURCE_PATH' is not readable or does not exist."
        exit 1
    fi
}

# Function to validate backup path
validate_backup_path() {
    if [ ! -w "$(dirname "$FILESYSTEM_BACKUP_PATH")" ]; then
        echo "Error: Backup path '$FILESYSTEM_BACKUP_PATH' is not writable or does not exist."
        exit 1
    fi
}

# Function to validate log file
validate_log_file() {
    local log_dir=$(dirname "$FILESYSTEM_LOG_FILE")

    mkdir -p "$log_dir"
    
    if [ ! -w "$log_dir" ]; then
        echo "Error: Log directory '$log_dir' is not writable."
        exit 1
    fi

    touch "$FILESYSTEM_LOG_FILE"
}

# Function to display help message
help() {
    echo "This script creates a backup of a filesystem directory."
    echo "Configuration:"
    echo "  - All settings must be configured in the .env file"
    echo "  - Required settings:"
    echo "    FILESYSTEM_SOURCE_PATH: Path to the directory to backup"
    echo "    FILESYSTEM_BACKUP_PATH: Directory to store backups"
    echo "    FILESYSTEM_LOG_FILE: Path to log file"
    echo "  - Optional settings:"
    echo "    FILESYSTEM_MAX_FILES: Number of backups to keep (default: 5)"
    echo "    FILESYSTEM_FILE_PREFIX: Prefix for backup file names"
}

# Display help if -h or --help is passed
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    help
    exit 0
fi

# Validate environment variables
validate_env_vars

# Validate paths
validate_source_path
validate_backup_path
validate_log_file

log_section_start "Backup Process"
log_message "Configuration Summary:"
log_message "  Source Path: $FILESYSTEM_SOURCE_PATH"
log_message "  Backup Path: $FILESYSTEM_BACKUP_PATH"
log_message "  Log File: $FILESYSTEM_LOG_FILE"
log_message "  Max Backups: $FILESYSTEM_MAX_FILES"

# Create timestamped backup directory
DATETIME=$(get_datetime)
TIMESTAMPED_BACKUP_PATH=$(create_backup_directory)
log_message "Backup directory created at $TIMESTAMPED_BACKUP_PATH"

# Perform filesystem backup
if ! backup_filesystem; then
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

log_section_end "Backup Process" 