#!/bin/bash

# Default log file path
DEFAULT_LOG_FILE="/var/log/backup_postgres.log"
DEFAULT_BACKUP_PERIOD="daily"

# Function to get formatted datetime for backup naming
get_datetime() {
    date +"%Y%m%d_%H%M%S"
}

# Function to get formatted datetime for logging
get_human_readable_datetime() {
    date +"%F %T.%3N"
}

# Function to get current period directory
get_period_directory() {
    local period=$1
    local current_date=$(date +"%Y-%m-%d")
    local current_hour=$(date +"%H")
    local current_week=$(date +"%V")
    local current_month=$(date +"%m")

    case "$period" in
        "hourly")
            echo "${current_date}_${current_hour}"
            ;;
        "daily")
            echo "$current_date"
            ;;
        "weekly")
            echo "week_${current_week}"
            ;;
        "monthly")
            echo "month_${current_month}"
            ;;
    esac
}

# Function to remove old backups from current period
remove_old_period_backups() {
    local backup_path=$1
    local period=$2
    local current_backup=$3
    local period_dir=$(get_period_directory "$period")
    local log_message=""

    # Find and remove old backups from current period, excluding current backup
    if [ -d "$backup_path" ]; then
        log_message="Removing old backups from current period: $period_dir"
        echo "$log_message"
        echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"

        find "$backup_path" -maxdepth 1 -type d -name "*${period_dir}*" ! -path "$current_backup" -exec rm -rf {} +
        
        log_message="Successfully removed old backups from current period"
        echo "$log_message"
        echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"
    fi
}

# Function to create backup directory
create_backup_directory() {
    local timestamped_path="$BACKUP_PATH/$DATETIME"
    local period_dir=$(get_period_directory "$BACKUP_PERIOD")
    local backup_dir="$BACKUP_PATH/${period_dir}_${DATETIME}"

    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
    fi

    echo "$backup_dir"
}

# Function to remove failed backup
remove_failed_backup() {
    local backup_dir=$1
    local log_message="Removing failed backup directory: $backup_dir"

    echo "$log_message"
    echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"

    if rm -rf "$backup_dir"; then
        log_message="Successfully removed failed backup directory"
        echo "$log_message"
        echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"
        return 0
    else
        log_message="ERROR: Failed to remove backup directory"
        echo "$log_message"
        echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"
        return 1
    fi
}

# Function to backup PostgreSQL database
backup_postgres_database() {
    local backup_file="$TIMESTAMPED_BACKUP_PATH/db_backup_$DATETIME.sql"
    local log_message=""

    echo "Starting PostgreSQL backup for database '$DB_NAME'..."
    
    if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$backup_file"; then
        log_message="Successfully executed pg_dump for database '$DB_NAME'"
        echo "$log_message"
        echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"
        return 0
    else
        log_message="ERROR: Failed to create database backup for '$DB_NAME'"
        echo "$log_message"
        echo "$(get_human_readable_datetime) $log_message" >> "$LOG_FILE"
        return 1
    fi
}

# Function to validate required arguments
validate_required_args() {
    # Check for excess arguments
    if [ $# -gt 6 ]; then
        echo "Error: Too many arguments provided."
        help
        exit 1
    fi

    local container_name=$1
    local db_name=$2
    local db_user=$3
    local backup_path=$4

    if [ -z "$container_name" ] || [ -z "$db_name" ] || [ -z "$db_user" ] || [ -z "$backup_path" ]; then
        echo "Error: All arguments are required."
        help
        exit 1
    fi
}

# Function to validate container
validate_container_name() {
    local container_name=$1
    if ! docker ps | grep -q "$container_name"; then
        echo "Error: Container '$container_name' is not running or does not exist."
        exit 1
    fi
}

# Function to validate backup path
validate_backup_path() {
    local backup_path=$1
    if [ ! -w "$(dirname "$backup_path")" ]; then
        echo "Error: Backup path '$backup_path' is not writable or does not exist."
        exit 1
    fi
}

# Function to validate log file
validate_log_file() {
    local log_file=$1
    local log_dir=$(dirname "$log_file")

    # Create log directory if it doesn't exist
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi

    # Check if log file is writable
    if [ ! -w "$log_dir" ]; then
        echo "Error: Log directory '$log_dir' is not writable."
        exit 1
    fi

    # Create log file if it doesn't exist
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi
}

# Function to validate backup period
validate_backup_period() {
    local period=$1
    case "$period" in
        "hourly"|"daily"|"weekly"|"monthly")
            return 0
            ;;
        *)
            echo "Error: Invalid backup period. Must be one of: hourly, daily, weekly, monthly"
            help
            exit 1
            ;;
    esac
}

# Function to get and validate arguments
get_and_validate_args() {
    # Get arguments
    local container_name=$1
    local db_name=$2
    local db_user=$3
    local backup_path=$4
    local log_file=${5:-$DEFAULT_LOG_FILE}
    local backup_period=${6:-$DEFAULT_BACKUP_PERIOD}

    # Validate all arguments
    validate_required_args "$@"
    validate_container_name "$container_name"
    validate_backup_path "$backup_path"
    validate_log_file "$log_file"
    validate_backup_period "$backup_period"

    # Export validated variables
    export CONTAINER_NAME="$container_name"
    export DB_NAME="$db_name"
    export DB_USER="$db_user"
    export BACKUP_PATH="$backup_path"
    export LOG_FILE="$log_file"
    export BACKUP_PERIOD="$backup_period"

    return 0
}

# Function to display help message
help() {
    echo "This script creates a backup of a PostgreSQL database running inside a Docker container."
    echo "Usage:"
    echo "  backup [CONTAINER_NAME] [DB_NAME] [DB_USER] [BACKUP_PATH] [LOG_FILE] [BACKUP_PERIOD]"
    echo "Note:"
    echo "  - Run this script with sudo permissions."
    echo "  - LOG_FILE is optional. Default: $DEFAULT_LOG_FILE"
    echo "  - BACKUP_PERIOD is optional. Must be one of: hourly, daily, weekly, monthly"
    echo "    Default: $DEFAULT_BACKUP_PERIOD"
}

# Display help if -h or --help is passed as an argument
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    help
    exit 0
fi

# Start backup
echo "Backup started at $(get_human_readable_datetime)"

# Get and validate arguments
get_and_validate_args "$@"

# Create timestamped backup directory
DATETIME=$(get_datetime)
TIMESTAMPED_BACKUP_PATH=$(create_backup_directory)
echo "Backup directory created at $TIMESTAMPED_BACKUP_PATH"

# Perform PostgreSQL database backup
if ! backup_postgres_database; then
    echo "Backup failed. Removing backup files..."
    remove_failed_backup "$TIMESTAMPED_BACKUP_PATH"
    echo "Backup failed. Check the log file for details."
    exit 0
fi

# Remove old backups from current period after successful backup
remove_old_period_backups "$BACKUP_PATH" "$BACKUP_PERIOD" "$TIMESTAMPED_BACKUP_PATH"

exit 0

# # Remove backups older than 5 days only if today's backup was successful
# if [ "$BACKUP_SUCCESS" = true ]; then
#     find "$BACKUP_PATH" -mindepth 1 -maxdepth 1 -type d -mtime +5 -exec rm -rf {} +
#     echo "$BACKUP_DATETIME Old backups older than 5 days have been deleted." >> /var/log/backup_postgres.log
# fi
