#!/bin/bash

for file in "$@"; do
    if [[ "$file" == *.exe ]]; then
        icon_name="${file%.*}.ico"
        wrestool -x -t 14 "$file" > "$icon_name" 2>/dev/null
    fi
done
