#!/bin/bash

# Überprüfen, ob ein Argument übergeben wurde. Wenn nicht, geben Sie eine Fehlermeldung aus und beenden Sie das Skript.
if [[ $# != 2 ]]; then
    echo "Bitte geben Sie genau zwei Ordnerpfade als Argumente an."
    exit 1
fi

# Speichern des ersten Arguments (Ordnerpfad) in der Variable folder_path.
folder_path="$1"

# Speichern des zweiten Arguments (Ordnerpfad für Dublette-Kopien) in der Variable duplicate_folder_path.
duplicate_folder_path="$2"

# Überprüfen, ob der angegebene Ordner existiert, und erstellen, falls nicht.
mkdir -p "$duplicate_folder_path"

# Erstellen einer temporären Datei für die Hash-Liste.
temp_hash_file=$(mktemp) # Erstellt Datei unter /tmp/ in der Form tmp.????????

# Durch den Ordner iterieren, Hashes berechnen und in die temporäre Datei schreiben.
# - find "$folder_path" -type f: Sucht rekursiv im angegebenen Ordner nach allen Dateien.
# - -exec sha256sum {} +: Führt für jede gefundene Datei den Befehl sha256sum aus, um den Hash zu berechnen.
# - | sort -k 2: Leitet die Ausgabe an sort weiter, um die Liste nach dem zweiten Feld (dem Hash) zu sortieren.
# - > "$temp_hash_file": Speichert die sortierte Ausgabe in der temporären Datei.find "$folder_path" -type f -exec sha256sum {} + | sort -k 2 > "$temp_hash_file"
find "$folder_path" -type f -exec sha256sum {} + > "$temp_hash_file"


# Deklarieren eines assoziativen Arrays zum Speichern der bereits gesehenen Hashes.
declare -A seen_hashes

# Lesen der temporären Datei Zeile für Zeile.
while read -r line
do
    # Extrahieren des Hash-Werts aus der Zeile.
    hash=$(echo "$line" | cut -d' ' -f1)
    # Extrahieren des Pfads aus der Zeile.
    path=$(echo "$line" | cut -d' ' -f3) # 3, Weil sha256sum zwei Leerzeichen zwischen hash und Pfad setzt
    # Extrahieren der Dateiendung aus dem Pfad.
    extension="${path##*.}"
    # Erstellen eines neuen Pfads für die Kopie, der die ursprüngliche Dateiendung beibehält.
    destination_copy_path="$duplicate_folder_path/$hash.$extension"
    
    # Überprüfen, ob der Hash bereits im Array gesehen wurde.
    if [[ -n "${seen_hashes[$hash]}" ]]; then # -n, ob ein String mit einer Länge < 0 vorhanden ist

        # Extragieren des Pfades der ersten gefundenen Datei mit dem Hash
        first_path="${seen_hashes[$hash]}"

        # Überprüfen, ob der ursprüngliche Pfad ein symbolischer Link ist.
        if [[ -L "$first_path" ]]; then
            # Wenn ja, nichts tun
            echo '';
        else
            # Wenn nein, den Pfad aus seen_hashes[$hash] verwenden und diesen linken.
            cp "$first_path" "$destination_copy_path"

            ln -sf "$destination_copy_path" "$first_path"

            echo "Ersetzt durch Symlink und kopiert: $first_path -> $destination_copy_path"
        fi

        # Ersetzen der Datei durch einen Symlink auf die bereits gesehene Datei.
        # -s für symbolischen Link
        # -f um bereits vorhandene Datei zu ersetzen
        ln -sf "$destination_copy_path" "$path" 
        # Ausgabe einer Nachricht, die den Ersatz durch einen Symlink anzeigt.
        echo "Ersetzt durch Symlink: $path -> $destination_copy_path"
    else
        # Speichern des Hash-Werts und des Pfads im Array, falls der Hash noch nicht gesehen wurde.
        seen_hashes[$hash]=$path
    fi
done < "$temp_hash_file"

# Löschen der temporären Datei
rm "$temp_hash_file"

# Ausgabe einer Nachricht, die anzeigt, dass Dubletten durch Symlinks ersetzt wurden.
echo "Dubletten wurden durch Symlinks ersetzt."
