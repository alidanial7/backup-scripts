# Backup Scripts Collection

A collection of robust shell scripts for automating backups of various technologies and services.

## 📁 Project Structure

```
backup-scripts/
├── postgresql-backup/
│   ├── postgresql_docker_backup.sh
│   ├── .env.example
│   └── README.md
├── filesystem-backup/
│   ├── filesystem_backup.sh
│   ├── .env.example
│   └── README.md
├── backup/
│   └── (backup files)
├── logs/
│   └── (log files)
└── README.md
```

## 🚀 Available Backup Scripts

### PostgreSQL Docker Backup

Located in `postgresql-backup/`, this script provides automated backups of PostgreSQL databases running in Docker containers.

[View PostgreSQL Backup Documentation](postgresql-backup/README.md)

### Filesystem Backup

Located in `filesystem-backup/`, this script provides automated backups of files and directories with compression and rotation.

[View Filesystem Backup Documentation](filesystem-backup/README.md)

## 🛠️ Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/backup-scripts.git
cd backup-scripts
```

2. Choose the backup script you want to use and follow its specific installation instructions in its respective directory.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewBackupScript`)
3. Commit your changes (`git commit -m 'Add new backup script for X'`)
4. Push to the branch (`git push origin feature/NewBackupScript`)
5. Open a Pull Request

## 📞 Support

If you encounter any issues or have questions, please:

- Open an issue in the GitHub repository
- Contact the maintainers at support@example.com

## 🚀 Current Features

### PostgreSQL Docker Backup

- Automated PostgreSQL database backups from Docker containers
- Configurable backup retention policy
- Detailed logging system
- Error handling and validation
- Temporary backup creation for atomic operations
- Clean backup rotation

## 🚀 Supported Technologies

- PostgreSQL Databases
- MySQL/MariaDB Databases
- MongoDB Databases
- Redis
- Docker Containers
- File System Backups
- Configuration Files

## 📋 Prerequisites

- Docker installed and running
- PostgreSQL container running
- Bash shell environment
- Required utilities:
  - `docker` for container management
  - `pg_dump` for PostgreSQL backups

## 🛠️ Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/backup-scripts.git
cd backup-scripts
```

2. Make scripts executable:

```bash
chmod +x *.sh
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

### PostgreSQL Docker Backup

Run the backup script:

```bash
./postgresql_docker_backup.sh
```

For scheduled backups, add to crontab:

```bash
# Daily backup at midnight
0 0 * * * /path/to/backup-scripts/postgresql_docker_backup.sh
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

## 🗺️ Roadmap

### Phase 1: Database Backups

- [x] PostgreSQL Docker backup
- [ ] PostgreSQL standalone backup
- [ ] MySQL/MariaDB Docker backup
- [ ] MySQL/MariaDB standalone backup
- [ ] MongoDB Docker backup
- [ ] MongoDB standalone backup
- [ ] Redis backup

### Phase 2: Container Backups

- [ ] Docker volume backup
- [ ] Docker compose project backup
- [ ] Docker registry backup
- [ ] Container configuration backup

### Phase 3: File System Backups

- [ ] Directory backup with compression
- [ ] Incremental backup support
- [ ] File system snapshot backup
- [ ] Cloud storage integration (S3, GCS, Azure)

### Phase 4: Advanced Features

- [ ] Backup encryption
- [ ] Backup verification
- [ ] Automated restore testing
- [ ] Backup monitoring dashboard
- [ ] Email notifications
- [ ] Slack/Discord notifications
- [ ] Backup health checks

### Phase 5: Infrastructure Backups

- [ ] Kubernetes cluster backup
- [ ] Docker Swarm backup
- [ ] VM backup support
- [ ] Configuration management backup

## 🙏 Acknowledgments

- Thanks to all contributors who have helped shape this project
- Inspired by various open-source backup solutions
