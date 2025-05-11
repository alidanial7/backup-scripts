# PostgreSQL Docker Backup Script

A robust shell script for automating PostgreSQL database backups from Docker containers.

## 🚀 Features

- Automated PostgreSQL database backups from Docker containers
- Configurable backup retention policy
- Detailed logging system
- Error handling and validation
- Temporary backup creation for atomic operations
- Clean backup rotation

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
cd postgresql-backup/docker
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
BACKUPS_CONTAINER_NAME=postgres
BACKUPS_DATABASE_NAME=mydb
BACKUPS_DATABASE_USER=postgres

# Backup Settings
BACKUPS_BACKUP_PATH=./backup
BACKUPS_LOG_FILE=./logs/log.log
BACKUPS_MAX_FILES=4
BACKUPS_FILE_PREFIX=postgres_docker_backup
```

## 🚀 Usage

Run the backup script:

```bash
./postgresql_docker_backup.sh
```

For scheduled backups, add to crontab:

```bash
# Daily backup at midnight
0 0 * * * /path/to/backup-scripts/postgresql-backup/docker/postgresql_docker_backup.sh
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

Logs are stored in the configured log file with detailed information about:

- Backup start and completion times
- Configuration summary
- Success/failure status
- Error messages
- Backup rotation events

## 🔒 Security

- Credentials are stored in `.env` file (not tracked in git)
- Backup files are stored with appropriate permissions
- Sensitive data is never logged
- Atomic backup operations prevent partial backups

## 📞 Support

If you encounter any issues or have questions, please:

- Open an issue in the GitHub repository
- Contact the maintainers at support@example.com

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
