#!/bin/bash

ACCESS_CHECK=$(psql -h pg -d ucheb -c "SELECT 1 FROM pg_namespace WHERE nspname = 'public';" 2>&1)

if echo "$ACCESS_CHECK" | grep -q "permission denied"; then
    echo "Ошибка: У вас нет доступа к схеме public"
    exit 1
fi

psql -h pg -d ucheb -f ~/full_text_search.sql 2>&1 | sed 's|.*NOTICE:  ||g'
