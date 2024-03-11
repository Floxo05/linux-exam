#!/bin/bash
if [[ $# != 1 ]]; then
    echo "Bitte geben Sie einen Ordnerpfad als Argument an."
    exit 1
fi

folder_path="$1"
duplicate_folder_path="$HOME/.originals"

mkdir -p "$duplicate_folder_path"
temp_hash_file=$(mktemp)
find "$folder_path" -type f -exec sha256sum {} + > "$temp_hash_file"

declare -A seen_hashes
while read -r line
do
    hash=$(echo "$line" | cut -d' ' -f1)
    path=$(echo "$line" | cut -d' ' -f3)
    extension="${path##*.}"

    if [[ $duplicate_folder_path == */ ]]; then
        destination_copy_path="$duplicate_folder_path$hash.$extension"
    else
        destination_copy_path="$duplicate_folder_path/$hash.$extension"
    fi

    if [[ -n "${seen_hashes[$hash]}" ]]; then 
        first_path="${seen_hashes[$hash]}"

        if [[ -L "$first_path" ]]; then
            echo '';
        else
            cp "$first_path" "$destination_copy_path"
            ln -sf "$destination_copy_path" "$first_path"
            echo "Ersetzt durch Symlink und kopiert: $first_path -> $destination_copy_path"
        fi

        ln -sf "$destination_copy_path" "$path" 
        echo "Ersetzt durch Symlink: $path -> $destination_copy_path"
    else
        seen_hashes[$hash]=$path
    fi
done < "$temp_hash_file"

rm "$temp_hash_file"
echo "Programm erfolgreich ausgeführt"
