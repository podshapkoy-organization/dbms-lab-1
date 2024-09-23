create or replace procedure full_text_search(search_text text)
    language plpgsql
as
$$
DECLARE
--     search_text TEXT := 'Н_ЛЮДИ';
    object_record RECORD;
    object_count  INT := 0;
BEGIN
    RAISE NOTICE 'Текст запроса: %', search_text;
    RAISE NOTICE 'No.  Имя объекта           # строки  Текст';
    RAISE NOTICE '--- -------------------    ----------  --------------------------------------------';

    CREATE TEMP TABLE temp_lines AS
    WITH objects AS (SELECT p.proname            AS object_name,
                            p.prosrc             AS object_code,
                            'Function/Procedure' AS object_type
                     FROM pg_proc p
                              JOIN pg_namespace n ON p.pronamespace = n.oid
                     WHERE n.nspname = 'public'
                       AND p.prosrc ILIKE '%' || search_text || '%'

                     UNION ALL

                     SELECT t.tgname                 AS object_name,
                            pg_get_triggerdef(t.oid) AS object_code,
                            'Trigger'                AS object_type
                     FROM pg_trigger t
                              JOIN pg_class c ON t.tgrelid = c.oid
                              JOIN pg_namespace n ON c.relnamespace = n.oid
                     WHERE n.nspname = 'public'
                       AND pg_get_triggerdef(t.oid) ILIKE '%' || search_text || '%')
    SELECT object_name,
           object_code,
           object_type,
           line,
           ROW_NUMBER() OVER (PARTITION BY object_name ORDER BY line_number) AS line_number
    FROM objects
             CROSS JOIN LATERAL unnest(string_to_array(object_code, E'\n')) WITH ORDINALITY AS t(line, line_number)
    WHERE line ILIKE '%' || search_text || '%';

    FOR object_record IN
        SELECT ROW_NUMBER() OVER ()   AS No,
               object_name            AS "Имя объекта",
               line_number            AS "# строки",
               substring(line, 1, 50) AS "Текст"
        FROM temp_lines
        ORDER BY No
        LOOP
            object_count := object_count + 1;
            RAISE NOTICE '%    %-20s    %          %', object_count, object_record."Имя объекта", object_record."# строки", object_record."Текст";
        END LOOP;

    DROP TABLE temp_lines;
END
$$
