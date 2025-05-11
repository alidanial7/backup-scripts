# PostgreSQL Backup Scripts

A collection of robust shell scripts for automating PostgreSQL database backups.

## 📁 Project Structure

```
postgresql-backup/
├── docker/
│   ├── postgresql_docker_backup.sh
│   ├── .env.example
│   ├── .env
│   ├── backup/
│   ├── logs/
│   └── README.md
└── README.md
```

## 🚀 Available Backup Methods

### Docker-based PostgreSQL Backup

Located in `docker/`, this script provides automated backups of PostgreSQL databases running in Docker containers.

[View Docker Backup Documentation](docker/README.md)

## 🛠️ Installation

1. Clone the repository and navigate to the PostgreSQL backup directory:

```bash
git clone https://github.com/yourusername/backup-scripts.git
cd backup-scripts/postgresql-backup
```

2. Choose the backup method you want to use and follow its specific installation instructions in its respective directory.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

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
