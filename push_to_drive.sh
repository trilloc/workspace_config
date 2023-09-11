#!/bin/bash

# Stop MongoDB
mongod --shutdown

# Dump MongoDB data
mongodump --out=/workspace/mongo_backup

# Define the path to the lockfile
LOCKFILE="/workspace/.version_lock"

# Check if .version_lock exists, if not, initialize it
if [ ! -f /workspace/.version_lock ]; then
    echo "0.0.0" > /workspace/.version_lock
fi

# Fetch the remote version
drive pull --no-prompt $LOCKFILE
REMOTE_VERSION=$(cat $LOCKFILE)

# Check the local version
LOCAL_VERSION=$(cat $LOCKFILE)

# If the local version is older or the same, proceed with the push
if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
    drive push --no-prompt /workspace/path_to_sync
else
    echo "Warning: Local version ($LOCAL_VERSION) is newer than remote version ($REMOTE_VERSION). Push halted."
fi

# Start MongoDB
mongod --fork --logpath /var/log/mongod.log

