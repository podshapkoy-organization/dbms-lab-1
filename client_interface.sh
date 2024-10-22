#!/bin/bash

read -p "Введите имя таблицы: " SEARCH_TEXT

SCHEMA_NAME=$(echo "$SEARCH_TEXT" | cut -d '.' -f 1)
TABLE_NAME=$(echo "$SEARCH_TEXT" | cut -d '.' -f 2)

SEARCH_TABLE=$(echo "$TABLE_NAME" | tr '[:lower:]' '[:upper:]')

psql -h pg -d studs -c "CALL full_text_search('$SCHEMA_NAME', '$SEARCH_TABLE');" | sed 's|.*NOTICE:  ||g'
