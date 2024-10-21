#!/bin/bash

read -p "Введите схему поиска: " SEARCH_SCHEMA
read -p "Текст запроса: " SEARCH_TEXT

ACCESS_CHECK=$(psql -h pg -d studs -c "SELECT 1 FROM pg_namespace WHERE nspname = '$SEARCH_SCHEMA';" 2>&1)

if [[ $ACCESS_CHECK == *"ERROR"* ]]; then
  echo "Ошибка доступа к базе данных."
  exit 1
fi

# shellcheck disable=SC2046
SEARCH_TEXT=$(echo "$SEARCH_TEXT" | tr "[:lower:]" "[:upper:]" | iconv -f $(locale charmap) -t UTF-8)



psql -h pg -d studs -c "CALL full_text_search('$SEARCH_SCHEMA', '$SEARCH_TEXT');" | sed 's|.*NOTICE:  ||g'
