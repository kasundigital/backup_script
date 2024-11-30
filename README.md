# Automated Backup Script with Telegram Notifications

This script automates the process of creating backups, managing old files, and sending status updates to a Telegram group. It is designed to streamline the backup process and notify you in real-time about the success or failure of each step.

## Features

- **Database Backup**: Creates a `.bak` backup of the specified SQL database.
- **Application Backup**: Compresses the application directory into a `.zip` file.
- **Document Backup**: Compresses the document repository into a `.zip` file.
- **Google Drive Sync**: Uses `rclone` to upload the backup files to Google Drive.
- **Old Backup Management**:
  - Deletes backups older than 6 days from Google Drive.
  - Moves local backups older than 6 days to an archive folder (`/LocalBackup`).
  - Deletes archived backups older than 25 days.
- **Telegram Notifications**:
  - Sends a start notification with a timestamp.
  - Notifies the success or failure of each backup step.
  - Sends a free disk space summary.
  - Indicates the completion of the backup process.
- **Google Drive Cleanup**: Removes orphaned or trashed files using `rclone cleanup`.

## Prerequisites

- **SQL Server Tools**: Ensure `sqlcmd` is installed for database backups.
- **Rclone**: Install and configure `rclone` with access to your Google Drive.
- **Curl**: Required for sending Telegram messages.
- **Telegram Bot**: Create a bot and obtain the `BOT_TOKEN`. Add the bot to your group and get the `CHAT_ID`.

## Configuration

Update the following variables in the script:

- `TELEGRAM_BOT_TOKEN`: Replace with your Telegram Bot API token.
- `TELEGRAM_CHAT_ID`: Replace with your Telegram group chat ID.
- `BACKUP_DIR`: Path to the local backup directory.
- `DB_BACKUP`, `APP_BACKUP`, `DOC_BACKUP`: Paths for the database, app, and document backups.
- `SQLCMD` credentials: Update the SQL username and password.

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/backup-script.git
   cd backup-script

