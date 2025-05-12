# PostgreSQL Docker Backup Script

This script provides automated backup functionality for PostgreSQL databases running in Docker containers. It includes features for creating compressed backups, managing retention policies, and detailed logging.

## 🚀 Features

- Automated PostgreSQL database backups from Docker containers
- Automatic compression of backup files (ZIP format)
- Configurable backup retention policy
- Detailed logging with timestamps
- Automatic creation of backup directories
- Error handling and validation
- Cleanup of old backups

## 📋 Prerequisites

- Docker installed and running
- PostgreSQL container running
- `zip` command-line utility installed
- Bash shell environment

## ⚙️ Configuration

Create a `.env` file in the same directory as the script with the following variables:

```env
# Required Variables
BACKUPS_CONTAINER_NAME=your_postgres_container_name
BACKUPS_DATABASE_NAME=your_database_name
BACKUPS_DATABASE_USER=your_database_user
BACKUPS_BACKUP_PATH=/path/to/backup/directory
BACKUPS_LOG_FILE=/path/to/log/file.log

# Optional Variables
BACKUPS_MAX_FILES=5  # Number of backups to keep (default: 5)
BACKUPS_FILE_PREFIX=postgres_docker_backup  # Prefix for backup files
```

## 🚀 Usage

1. Make the script executable:

   ```bash
   chmod +x postgresql_docker_backup.sh
   ```

2. Run the script:

   ```bash
   ./postgresql_docker_backup.sh
   ```

3. For help:
   ```bash
   ./postgresql_docker_backup.sh --help
   ```

## 🔄 Backup Process

1. Validates environment variables and required paths
2. Creates backup directory if it doesn't exist
3. Creates a temporary directory for the backup
4. Executes `pg_dump` to create the database backup
5. Compresses the backup file into ZIP format
6. Removes the original SQL file after successful compression
7. Applies retention policy to remove old backups
8. Logs all operations with timestamps

## 📁 Backup File Format

Backup files are stored in the following format:

- `{prefix}_{YYYYMMDD_HHMMSS}.zip`

Example: `postgres_docker_backup_20240315_143022.zip`

## 📝 Logging

The script maintains detailed logs including:

- Start and end times of backup operations
- Success/failure status of each step
- Error messages when operations fail
- Configuration summary
- Retention policy actions

## ⚠️ Error Handling

The script includes comprehensive error handling for:

- Missing environment variables
- Container availability
- Directory permissions
- Backup creation
- Compression process
- File cleanup

## 🔄 Recent Changes

- Added automatic compression of backup files to ZIP format
- Added automatic creation of backup directory if it doesn't exist
- Updated retention policy to handle both SQL and ZIP files
- Improved error messages and logging

## 🔧 Maintenance

The script automatically manages backup retention by:

- Keeping the specified number of most recent backups
- Removing older backups when the limit is exceeded
- Cleaning up temporary files and failed backups

## 🔒 Security Notes

- Ensure proper permissions on the backup directory
- Store database credentials securely in the .env file
- Regularly rotate backup files
- Monitor log files for any issues
