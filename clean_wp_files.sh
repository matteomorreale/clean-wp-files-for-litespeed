#!/bin/bash

# Base directory to search for WordPress installations
BASE_DIR="/usr/local/lsws"

# Temporary owner for operations
TEMP_OWNER="yourname:nogroup"

# Original owner to restore
ORIGINAL_OWNER="nobody:nogroup"

# Security permissions to apply at the end
DIR_PERMISSIONS=755
FILE_PERMISSIONS=644
CONFIG_PERMISSIONS=600

# Find all WordPress installations
for config in $(find "$BASE_DIR" -type f -path "*/public/wp-config.php" 2>/dev/null); do
    SITE_PATH=$(dirname "$config")
    echo "Managing permissions and verifying checksums for $SITE_PATH..."

    # Temporarily change the owner
    echo "Temporarily changing owner to $TEMP_OWNER..."
    chown -R "$TEMP_OWNER" "$SITE_PATH"

    # Run wp-cli to verify unauthorized files
    OUTPUT=$(wp core verify-checksums --allow-root --path="$SITE_PATH" 2>&1)
    echo "Output of wp core verify-checksums:"
    echo "$OUTPUT"

    # Filter files flagged as "File should not exist"
    FILES=$(echo "$OUTPUT" | grep "File should not exist" | sed 's/^.*File should not exist: //')

    if [[ -z "$FILES" ]]; then
        echo "No suspicious files found for $SITE_PATH."
    else
        echo "Suspicious files found for $SITE_PATH:"
        echo "$FILES"

        # Remove suspicious files
        while read -r FILE; do
            FULL_PATH="$SITE_PATH/$FILE"
            if [[ -f "$FULL_PATH" ]]; then
                echo "Deleting $FULL_PATH..."
                rm -f "$FULL_PATH"
            else
                echo "File $FULL_PATH not found, it might have already been deleted."
            fi
        done <<< "$FILES"
    fi

    # Restore the original owner
    echo "Restoring original owner to $ORIGINAL_OWNER..."
    chown -R "$ORIGINAL_OWNER" "$SITE_PATH"

    # Apply correct permissions to files and directories
    echo "Restoring permissions..."
    find "$SITE_PATH" -type d -exec chmod "$DIR_PERMISSIONS" {} \;
    find "$SITE_PATH" -type f -exec chmod "$FILE_PERMISSIONS" {} \;
    chmod "$CONFIG_PERMISSIONS" "$SITE_PATH/wp-config.php"

    echo "Cleanup completed for $SITE_PATH."
    echo "---------------------------"
done