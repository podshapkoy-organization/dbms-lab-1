#!/bin/bash

read -p "Текст запроса: " SEARCH_TEXT

SEARCH_TEXT=$(echo "$SEARCH_TEXT" | iconv -f $(locale charmap) -t UTF-8)

ACCESS_CHECK=$(psql -h pg -d studs -c "SELECT 1 FROM pg_namespace WHERE nspname = 'public';" 2>&1)

if [[ $ACCESS_CHECK == *"ERROR"* ]]; then
  echo "Ошибка доступа к базе данных."
  exit 1
fi

psql -h pg -d studs -c "CALL full_text_search('$SEARCH_TEXT');" | sed 's|.*NOTICE:  ||g'
