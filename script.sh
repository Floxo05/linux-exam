#!/bin/bash

# Überprüfen, ob ein Argument übergeben wurde
if [ $# -eq 0 ]; then
    echo "Bitte geben Sie einen Ordnerpfad als Argument an."
    exit 1
fi

# Ordnerpfad aus dem Argument extrahieren
folder_path="$1"

# Temporäre Datei für die Hash-Liste erstellen
temp_hash_file=$(mktemp)

# Durch den Ordner iterieren und Hashes berechnen
find "$folder_path" -type f -exec sha256sum {} + | sort -k 2 > "$temp_hash_file"

# Dubletten finden und durch Symlinks ersetzen
awk 'seen[$2]++ {print $2}' "$temp_hash_file" | while read -r hash; do
    # Dateien mit dem gleichen Hash finden
    files=$(grep "$hash" "$temp_hash_file" | awk '{print $1}')
    # Erste Datei als Referenz behalten und die restlichen durch Symlinks ersetzen
    first_file=$(echo "$files" | head -n 1)
    for file in $files; do
        if [ "$file" != "$first_file" ]; then
            ln -sf "$first_file" "$file"
            echo "Ersetze $file durch Symlink zu $first_file"
        fi
    done
done

# Temporäre Hash-Liste löschen
# rm "$temp_hash_file"

echo "Dubletten wurden durch Symlinks ersetzt."
