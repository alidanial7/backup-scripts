# Filesystem Backup Script

A robust shell script for automating filesystem backups with compression and rotation.

## 🚀 Features

- Automated filesystem backups with compression
- Configurable backup retention policy
- Detailed logging system
- Error handling and validation
- Clean backup rotation
- Support for any directory or file structure

## 📋 Prerequisites

- Bash shell environment
- Required utilities:
  - `tar` for file compression
  - `gzip` for compression
  - Basic Unix utilities (find, date, etc.)

## 🛠️ Installation

1. Clone the repository and navigate to the filesystem backup directory:

```bash
git clone https://github.com/yourusername/backup-scripts.git
cd backup-scripts/filesystem-backup
```

2. Make the script executable:

```bash
chmod +x filesystem_backup.sh
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
# Source and Destination Settings
FILESYSTEM_SOURCE_PATH=/path/to/source/directory
FILESYSTEM_BACKUP_PATH=./backup

# Logging and Retention Settings
FILESYSTEM_LOG_FILE=./logs/filesystem.log
FILESYSTEM_MAX_FILES=4
FILESYSTEM_FILE_PREFIX=filesystem_backup
```

## 🚀 Usage

Run the backup script:

```bash
./filesystem_backup.sh
```

For scheduled backups, add to crontab:

```bash
# Daily backup at midnight
0 0 * * * /path/to/backup-scripts/filesystem-backup/filesystem_backup.sh
```

## 📁 Backup Structure

Backups are stored in the following format:

```
backup/
├── filesystem_backup_20240320_120000.tar.gz
├── filesystem_backup_20240319_120000.tar.gz
└── filesystem_backup_20240318_120000.tar.gz
```

## 📝 Logging

Logs are stored in the configured log file with detailed information about:

- Backup start and completion times
- Configuration summary
- Success/failure status
- Error messages
- Backup rotation events

## 🔒 Security

- Backup files are stored with appropriate permissions
- Sensitive data is never logged
- Atomic backup operations prevent partial backups

## 📞 Support

If you encounter any issues or have questions, please:

- Open an issue in the GitHub repository
- Contact the maintainers at support@example.com

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
