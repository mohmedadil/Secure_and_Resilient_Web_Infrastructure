#!/bin/bash

# ===== Configuration =====
BACKUP_DIR="/backups"
TIMESTAMP=$(date '+%Y-%m-%d_%H%M%S')
WORK_DIR="$BACKUP_DIR/backup_$TIMESTAMP"
ARCHIVE_NAME="backup_$TIMESTAMP.tar.gz"
LOG_FILE="$BACKUP_DIR/backup.log"

DB_NAME="shopdb"
DB_USER="root"
DB_PASS="Yourpassword"

# ===== Start =====
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting backup" >> "$LOG_FILE"

mkdir -p "$WORK_DIR"

# 1. Backup Nginx configs
cp -r /etc/nginx "$WORK_DIR/nginx_conf"
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Nginx configs backed up" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILED to back up Nginx configs" >> "$LOG_FILE"
fi

# 2. Backup website files
cp -r /usr/share/nginx/html "$WORK_DIR/website_files"
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Website files backed up" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILED to back up website files" >> "$LOG_FILE"
fi

# 3. Backup database
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$WORK_DIR/database.sql"
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Database backed up" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILED to back up database" >> "$LOG_FILE"
fi

# 4. Compress everything into one archive
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$BACKUP_DIR" "backup_$TIMESTAMP"

if [ $? -eq 0 ]; then
    ARCHIVE_SIZE=$(du -h "$BACKUP_DIR/$ARCHIVE_NAME" | cut -f1)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Archive created: $ARCHIVE_NAME ($ARCHIVE_SIZE)" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILED to create archive" >> "$LOG_FILE"
fi

# 5. Clean up the uncompressed working folder
rm -rf "$WORK_DIR"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup complete" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
# 6. Rotation: delete backups older than 7 days
DELETED=$(find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -print -delete)

if [ -n "$DELETED" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Rotation: deleted old backups:" >> "$LOG_FILE"
    echo "$DELETED" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Rotation: no old backups to delete" >> "$LOG_FILE"
fi
