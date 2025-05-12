# PostgreSQL Docker Backup Script

A robust shell script for automating PostgreSQL database backups from Docker containers with comprehensive logging and error handling.

## 🚀 Features

- Automated PostgreSQL database backups from Docker containers
- Atomic backup operations using temporary directories
- Configurable backup retention policy
- Detailed logging system with timestamps and section markers
- Comprehensive error handling and validation
- Clean backup rotation with configurable retention
- Environment-based configuration
- Help system with detailed usage information

## 📋 Prerequisites

- Docker installed and running
- PostgreSQL container running
- Bash shell environment
- Required utilities:
  - `docker` for container management
  - `pg_dump` for PostgreSQL backups

## 🛠️ Installation

1. Navigate to the PostgreSQL Docker backup directory:

```bash
cd postgresql/docker
```

2. Make the script executable:

```bash
chmod +x postgresql_docker_backup.sh
```

3. Copy the example environment file and configure it:

```bash
cp .env.example .env
```

4. Edit the `.env` file with your settings:

```bash
nano .env
```

## ⚙️ Configuration

Configure your backup settings in the `.env` file:

```bash
# Container and Database Settings
BACKUPS_CONTAINER_NAME=postgres    # Name of your PostgreSQL container
BACKUPS_DATABASE_NAME=mydb         # Database to backup
BACKUPS_DATABASE_USER=postgres     # Database user with backup privileges

# Backup Settings
BACKUPS_BACKUP_PATH=./backup       # Directory to store backups
BACKUPS_LOG_FILE=./logs/log.log    # Path to log file
BACKUPS_MAX_FILES=4                # Number of backups to retain
BACKUPS_FILE_PREFIX=postgres_docker_backup  # Prefix for backup files
```

## 🚀 Usage

Run the backup script:

```bash
./postgresql_docker_backup.sh
```

For help and usage information:

```bash
./postgresql_docker_backup.sh --help
```

For scheduled backups, add to crontab:

```bash
# Daily backup at midnight
0 0 * * * /path/to/postgresql/docker/postgresql_docker_backup.sh
```

## 📁 Backup Structure

Backups are stored in the following format:

```
backup/
├── postgres_docker_backup_20240320_120000.sql
├── postgres_docker_backup_20240319_120000.sql
└── postgres_docker_backup_20240318_120000.sql
```

## 📝 Logging

The script implements a comprehensive logging system that includes:

- Timestamped log entries with millisecond precision
- Section markers for major operations
- Detailed configuration summaries
- Success/failure status for each operation
- Error messages and stack traces
- Backup rotation events
- Console output for important messages only

Log entries are formatted as:

```
[2024-03-20 12:00:00.123] Message content
```

## 🔒 Security Features

- Environment-based configuration (credentials not in script)
- Atomic backup operations prevent partial backups
- Temporary directory usage for safe backup creation
- Proper file permissions and ownership
- No sensitive data in logs
- Validation of all critical paths and permissions

## ⚠️ Error Handling

The script includes comprehensive error handling:

- Environment variable validation
- Container existence and status checks
- Backup path and log file permissions validation
- Failed backup cleanup
- Detailed error messages and logging
- Graceful exit on critical errors

## 📞 Support

If you encounter any issues or have questions, please:

- Open an issue in the GitHub repository
- Contact the maintainers at support@example.com

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
