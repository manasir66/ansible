#!/bin/bash


MYSQL_USER="your_mysql_user"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_DATABASE="your_database_name"
S3_BUCKET="your_s3_bucket_name"

# Backup the database
docker exec -i database-container bash -c "mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE}" > /backup/backup.sql

# Backup the server keys
docker cp passbolt-container:/etc/passbolt/gpg/serverkey_private.asc /backup/backup/serverkey_private.asc
docker cp passbolt-container:/etc/passbolt/gpg/serverkey.asc /backup/backup/serverkey.asc

# Backup the avatars
docker exec -i passbolt-container tar cvfzp - -C /usr/share/php/passbolt/webroot/img/avatar > /backup/passbolt-avatars.tar.gz

# Change directory to backup folder
cd /backup || exit

# Zip the backup files
zip -r backup.zip.

# Upload the backup to AWS S3
aws s3 cp backup.zip s3://${S3_BUCKET}/backup/backup.zip

# Clean up local backup files
rm backup.sql serverkey_private.asc serverkey.asc passbolt-avatars.tar.gz backup.zip
