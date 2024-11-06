#!/bin/bash

# read -p "Введите имя базы данных: " DATABASE_NAME
read -p "Введите имя схемы: " SCHEMA_NAME
read -p "Введите текст запроса: " SEARCH_TEXT

# SCHEMA_NAME=$(echo "$SEARCH_TEXT" | cut -d '.' -f 1)
# TABLE_NAME=$(echo "$SEARCH_TEXT" | cut -d '.' -f 2)

SEARCH_TABLE=$(echo "$SEARCH_TEXT" | tr '[:lower:]' '[:upper:]')

# CHECK_PERMISSIONS=$(psql -h pg -d studs -t -c "SELECT has_schema_privilege('$SCHEMA_NAME', 'CREATE');")

psql -h pg -d studs -c "CALL full_text_search('$SCHEMA_NAME', '$SEARCH_TABLE');" | sed 's|.*NOTICE:  ||g'
# psql -h pg -d "$DATABASE_NAME" -c "CALL full_text_search('$SCHEMA_NAME', '$SEARCH_TABLE');" | sed 's|.*NOTICE:  ||g'

