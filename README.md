# Automated Linux Backup System

This repository contains a small infrastructure automation project that demonstrates **Linux system administration, Bash scripting, database backup management, systemd scheduling, and configuration management with Ansible**.

The project implements a daily automated backup system that archives system configuration files, backs up MariaDB databases, performs disk health checks, and sends a summary report via email.

---

# Original Task

The following assignment requirements were implemented:

* Write a Bash script that:

  * Creates a backup of `/etc` into `/var/backups/etc-YYYYMMDD.tar.gz`.
  * Dumps all existing MariaDB databases and stores the dumps in `/var/backups/mariadb-YYYYMMDD.sql`.
  * Removes backup files older than 7 days.
  * Sends a summary email with backup status and disk usage using **msmtp**.
  * Adds a warning if there is a **SMART error**.

* Write a **systemd timer** that runs this script every day at **4:00 AM**.

* Write an **Ansible playbook** that:

  * Installs the bash script and all dependencies.
  * Configures **msmtp**.
  * Installs and enables the systemd timer unit.
  * Installs and secures **MariaDB**.

* Fill MariaDB with a simple dummy database containing one table with a primary key and a string that has a few entries.

* Provide the dump from the backup script.

---

# Project Structure

```
linux-backup-automation
│
├── README.md
│
├── scripts
│   └── system-backup.sh
│
├── systemd
│   ├── system-backup.service
│   └── system-backup.timer
│
├── ansible
│   ├── site.yml
│   └── inventory.ini
│
├── database
│   └── mariadb-dump.sql
│
└── docs
    └── architecture.md
```

---

# System Architecture

```
systemd timer (04:00 daily)
        │
        ▼
system-backup.service
        │
        ▼
system-backup.sh
        │
        ├── Backup /etc
        ├── Dump MariaDB databases
        ├── Delete old backups (>7 days)
        ├── Check SMART disk health
        ├── Check disk usage
        └── Send email summary via msmtp
```

---

# Bash Backup Script

Location:

```
/usr/local/bin/system-backup.sh
```

The script performs the following tasks:

### 1. Backup `/etc`

The `/etc` directory contains important system configuration files.

```
tar -czf /var/backups/etc-YYYYMMDD.tar.gz /etc
```

This creates a compressed archive with the current date.

---

### 2. Dump MariaDB Databases

All databases are exported using:

```
mysqldump --all-databases > /var/backups/mariadb-YYYYMMDD.sql
```

This allows full database recovery if the server fails.

---

### 3. Remove Old Backups

To prevent disk exhaustion, backups older than **7 days** are automatically deleted.

```
find /var/backups -mtime +7 -delete
```

This implements a simple **backup retention policy**.

---

### 4. SMART Disk Health Check

Disk health is checked using **smartmontools**.

```
smartctl -H /dev/sda
```

If a SMART failure is detected, the script includes a warning in the report.

---

### 5. Disk Usage Monitoring

Disk usage is checked using:

```
df -h
```

This information is included in the email summary.

---

### 6. Email Notification

The script sends a backup report using **msmtp**.

The report includes:

* Backup status
* Disk usage
* SMART disk health warnings

---

# systemd Service and Timer

The backup script is executed via a **systemd service**, which is triggered by a **systemd timer**.

### Service

```
system-backup.service
```

Example:

```
[Service]
Type=oneshot
ExecStart=/usr/local/bin/system-backup.sh
```

---

### Timer

```
system-backup.timer
```

The timer runs every day at **04:00 AM**.

```
OnCalendar=*-*-* 04:00:00
```

Enable the timer:

```
systemctl daemon-reload
systemctl enable --now system-backup.timer
```

Verify:

```
systemctl list-timers
```

---

# Ansible Deployment

The infrastructure is deployed automatically using **Ansible**.

The playbook performs the following:

* Installs required packages
* Installs and secures MariaDB
* Configures msmtp
* Deploys the backup script
* Installs systemd service and timer
* Enables the scheduled backup

Run the playbook:

```
ansible-playbook ansible/site.yml
```

---

# Dummy MariaDB Database

A simple test database is created to validate backups.

Example schema:

```
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255)
);
```

Example records:

```
Alice
Bob
Charlie
David
```

The database dump produced by the backup script is stored in:

```
database/mariadb-dump.sql
```

---

# Backup Output

Backup files are stored in:

```
/var/backups/
```

Example:

```
/var/backups/etc-20260308.tar.gz
/var/backups/mariadb-20260308.sql
```

---

# Restore Example

Restore MariaDB database:

```
mysql < mariadb-20260308.sql
```

Extract `/etc` backup:

```
tar -xzf etc-20260308.tar.gz
```

---

# Possible Improvements

For production environments, the system could be extended with:

* Encrypted backups using **GPG**
* Remote backup storage (S3 / MinIO)
* Incremental backups
* Prometheus monitoring
* Backup verification checks
* Centralized logging

---

# Skills Demonstrated

This project demonstrates practical experience in:

* Linux system administration
* Bash scripting
* MariaDB database management
* systemd service and timer configuration
* Configuration management with Ansible
* Disk health monitoring
* Infrastructure automation

---

# Summary

This project implements a **fully automated Linux backup solution** that performs daily configuration and database backups, monitors disk health, manages backup retention, and sends operational alerts via email.

The entire setup is reproducible using **Ansible**, making it suitable for both testing environments and production deployments.
