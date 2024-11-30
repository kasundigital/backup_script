#!/bin/bash

# Replace these placeholders with your own values
TELEGRAM_BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN" # Replace with your Telegram bot token
TELEGRAM_CHAT_ID="YOUR_TELEGRAM_CHAT_ID"     # Replace with your Telegram chat ID
SQL_PASSWORD="YOUR_SQL_PASSWORD"            # Replace with your SQL password
RCLONE_REMOTE_NAME="gdrive"                 # Replace with your rclone remote name

# Directory paths
BACKUP_DIR="/backup"                        # Local backup directory
LOCAL_BACKUP_DIR="/LocalBackup"             # Local backup for aged files
NOW=$(date '+%F_%H-%M-%S')

# Backup file paths
DB_BACKUP="${BACKUP_DIR}/SQL${NOW}.bak"
APP_BACKUP="${BACKUP_DIR}/App${NOW}.zip"
DOC_BACKUP="${BACKUP_DIR}/Doc${NOW}.zip"
LOG_FILE="${BACKUP_DIR}/backup_log_${NOW}.txt"

# Notification subject
SUBJECT="Backup Result for ${NOW}"

# Function to send Telegram messages
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="${message}" >/dev/null
}

# Send start notification
send_telegram_message "----------------------------------"
send_telegram_message "🚀 Backup Process Started at ${NOW}"

# Function to get free space percentage
get_free_space() {
    df -h / | awk 'NR==2 {print $5}'
}

# SQL backup
sqlcmd -U sa -P "${SQL_PASSWORD}" -Q "BACKUP DATABASE ImmigrationCons TO DISK = '${DB_BACKUP}'" >> ${LOG_FILE} 2>&1
if [ $? -ne 0 ]; then
    send_telegram_message "🚨 Backup FAILURE: SQL database backup failed at ${NOW}."
else
    send_telegram_message "✅ Backup SUCCESS: SQL database backup completed at ${NOW}."
fi

# App backup
zip -r ${APP_BACKUP} /var/www/blazorapp/ >> ${LOG_FILE} 2>&1
if [ $? -ne 0 ]; then
    send_telegram_message "🚨 Backup FAILURE: App backup failed at ${NOW}."
else
    send_telegram_message "✅ Backup SUCCESS: App backup completed at ${NOW}."
fi

# Documents backup
zip -r ${DOC_BACKUP} /var/www/ImmiConsDocRepo/ >> ${LOG_FILE} 2>&1
if [ $? -ne 0 ]; then
    send_telegram_message "🚨 Backup FAILURE: Document backup failed at ${NOW}."
else
    send_telegram_message "✅ Backup SUCCESS: Document backup completed at ${NOW}."
fi

# Copy to Google Drive
rclone copy ${BACKUP_DIR}/ "${RCLONE_REMOTE_NAME}:" >> ${LOG_FILE} 2>&1
if [ $? -ne 0 ]; then
    send_telegram_message "🚨 Backup FAILURE: Google Drive upload failed at ${NOW}."
else
    send_telegram_message "✅ Backup SUCCESS: Google Drive upload completed at ${NOW}."
fi

# Free space check
FREE_SPACE=$(get_free_space)
send_telegram_message "📊 Free space on /: ${FREE_SPACE}"

# Google Drive cleanup
rclone cleanup "${RCLONE_REMOTE_NAME}:"
send_telegram_message "🔄 Cleanup: Google Drive cleanup completed at ${NOW}."

# Send completion notification
send_telegram_message "🎉 Backup Process Completed at ${NOW}"

# Maintenance: Delete old backups
find "${BACKUP_DIR}" -type f -mtime +6 -exec mv {} "${LOCAL_BACKUP_DIR}/" \;
find "${LOCAL_BACKUP_DIR}" -type f -mtime +25 -exec rm -f {} \;
