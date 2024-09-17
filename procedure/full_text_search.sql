WITH objects AS (
    SELECT
        p.proname AS object_name,
        p.prosrc AS object_code,
        'Function/Procedure' AS object_type
    FROM
        pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE
        n.nspname = 'public'
        AND p.prosrc ILIKE '%Н_ЛЮДИ%'

    UNION ALL

    SELECT
        t.tgname AS object_name,
        pg_get_triggerdef(t.oid) AS object_code,
        'Trigger' AS object_type
    FROM
        pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE
        n.nspname = 'public'
        AND pg_get_triggerdef(t.oid) ILIKE '%Н_ЛЮДИ%'
),
lines AS (
    SELECT
        object_name,
        object_code,
        object_type,
        line,
        ROW_NUMBER() OVER (PARTITION BY object_name ORDER BY line_number) AS line_number
    FROM
        objects
        CROSS JOIN LATERAL unnest(string_to_array(object_code, E'\n')) WITH ORDINALITY AS t(line, line_number)
    WHERE
        line ILIKE '%Н_ЛЮДИ%'
)
SELECT
    ROW_NUMBER() OVER () AS No,
    object_name AS "Имя объекта",
    line_number AS "# строки",
    substring(line, 1, 50) AS "Текст"
FROM
    lines
ORDER BY No;
