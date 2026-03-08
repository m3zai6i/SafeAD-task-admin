#!/usr/bin/env bash
set -euo pipefail


DATE=$(date +%Y%m%d)
BACKUP_DIR="/var/backups"
ETC_BACKUP="${BACKUP_DIR}/etc-${DATE}.tar.gz"
DB_BACKUP="${BACKUP_DIR}/mariadb-${DATE}.sql"
LOG_FILE="/var/log/system-backup.log"


EMAIL_TO="admin@example.com"
HOST=$(hostname)


STATUS="SUCCESS"
WARNINGS=""

mkdir -p "$BACKUP_DIR"
tar -czf "$ETC_BACKUP" /etc || STATUS="FAILED"
mysqldump --all-databases --single-transaction --quick --lock-tables=false > "$DB_BACKUP" || STATUS="FAILED"

find "$BACKUP_DIR" -type f -mtime +7 -delete


SMART_ERRORS=""

for disk in /dev/sd?; do
    if smartctl -H "$disk" | grep -q "FAILED"; then
        SMART_ERRORS+="SMART ERROR detected on $disk\n"
        STATUS="WARNING"

    fi
done

DISK_USAGE=$(df -h)

MAIL_BODY=$(cat <<EOF

Backup Status: $STATUS
Host: $HOST
Date: $(date)

SMART Status:
$SMART_ERRORS

Disk Usage:
$DISK_USAGE
EOF
)

echo -e "$MAIL_BODY" | msmtp "$EMAIL_TO"