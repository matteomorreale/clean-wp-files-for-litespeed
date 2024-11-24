#!/bin/bash

# Directory base dove cercare le installazioni WordPress
BASE_DIR="/usr/local/lsws"

# Proprietario temporaneo per le operazioni
TEMP_OWNER="matteo:nogroup"

# Proprietario originale da ripristinare
ORIGINAL_OWNER="nobody:nogroup"

# Permessi di sicurezza da applicare alla fine
DIR_PERMISSIONS=755
FILE_PERMISSIONS=644
CONFIG_PERMISSIONS=600

# Trova tutte le installazioni WordPress
for config in $(find "$BASE_DIR" -type f -path "*/public/wp-config.php" 2>/dev/null); do
    SITE_PATH=$(dirname "$config")
    echo "Gestione permessi e verifica dei checksums per $SITE_PATH..."

    # Cambia temporaneamente il proprietario
    echo "Cambio proprietario temporaneo a $TEMP_OWNER..."
    chown -R "$TEMP_OWNER" "$SITE_PATH"

    # Esegui wp-cli per verificare i file non autorizzati
    OUTPUT=$(wp core verify-checksums --allow-root --path="$SITE_PATH" 2>&1)
    echo "Output di wp core verify-checksums:"
    echo "$OUTPUT"

    # Filtra i file segnalati come "File should not exist"
    FILES=$(echo "$OUTPUT" | grep "File should not exist" | sed 's/^.*File should not exist: //')


    if [[ -z "$FILES" ]]; then
        echo "Nessun file sospetto trovato per $SITE_PATH."
    else
        echo "File sospetti trovati per $SITE_PATH:"
        echo "$FILES"

        # Rimuovi i file sospetti
        while read -r FILE; do
            FULL_PATH="$SITE_PATH/$FILE"
            if [[ -f "$FULL_PATH" ]]; then
                echo "Eliminazione di $FULL_PATH..."
                rm -f "$FULL_PATH"
            else
                echo "File $FULL_PATH non trovato, potrebbe essere già eliminato."
            fi
        done <<< "$FILES"
    fi

    # Ripristina il proprietario originale
    echo "Ripristino proprietario originale a $ORIGINAL_OWNER..."
    chown -R "$ORIGINAL_OWNER" "$SITE_PATH"

    # Applica i permessi corretti a file e directory
    echo "Ripristino permessi..."
    find "$SITE_PATH" -type d -exec chmod "$DIR_PERMISSIONS" {} \;
    find "$SITE_PATH" -type f -exec chmod "$FILE_PERMISSIONS" {} \;
    chmod "$CONFIG_PERMISSIONS" "$SITE_PATH/wp-config.php"

    echo "Pulizia completata per $SITE_PATH."
    echo "---------------------------"
done