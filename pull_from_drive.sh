#!/bin/bash

# Define the path to the lockfile
LOCKFILE="/workspace/.version_lock"

# Fetch the remote version
drive pull --no-prompt --exclude="*" $LOCKFILE
REMOTE_VERSION=$(cat $LOCKFILE)

# Check the local version
if [ -f "$LOCKFILE" ]; then
    LOCAL_VERSION=$(cat $LOCKFILE)
else
    LOCAL_VERSION="0.0.0"
fi

# If the remote version is the same or newer, proceed with the pull
if [ "$REMOTE_VERSION" \> "$LOCAL_VERSION" ] || [ "$REMOTE_VERSION" = "$LOCAL_VERSION" ]; then
    drive pull --no-prompt /workspace/path_to_sync
else
    echo "Warning: Local version ($LOCAL_VERSION) is newer than remote version ($REMOTE_VERSION). Pull halted."
fi

# Stop MongoDB
service mongod stop

# Restore MongoDB data
mongorestore /workspace/mongo_backup

# Start MongoDB
service mongod start

