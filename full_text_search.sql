create or replace procedure full_text_search(search_schema text, search_text text)
    language plpgsql
as
-- set my.table_name to :'table_name';
-- set my.schema_name to :'schema_name';
-- do
$$
    DECLARE
--         search_schema TEXT := current_setting('my.schema_name');
--         search_text   TEXT := upper(current_setting('my.table_name'));
        object_record RECORD;
        object_count  INT  := 0;
        schema_exists boolean;
        table_exists  boolean;
    BEGIN

        raise notice 'Проверка существования схемы: %', search_schema;
        select exists(select 1 from pg_namespace where nspname = search_schema) into schema_exists;
        if not schema_exists then
            raise notice 'Схемы не существует';
            return;
        end if;

        raise notice 'Проверка существования таблицы: %', search_text;
        select exists(select 1 from pg_tables where upper(tablename) = search_text) into table_exists;

        if not table_exists then
            raise notice 'Таблицы не существует';
            return;
        end if;

        RAISE NOTICE 'Текст запроса: %', search_text;
        RAISE NOTICE 'No.  Имя объекта           # строки  Текст';
        RAISE NOTICE '--- -------------------    ----------  --------------------------------------------';

        CREATE TEMP TABLE temp_lines AS
        WITH objects AS (SELECT p.proname            AS object_name,
                                p.prosrc             AS object_code,
                                'Function/Procedure' AS object_type
                         FROM pg_proc p
                                  JOIN pg_namespace n ON p.pronamespace = n.oid
                         WHERE n.nspname = search_schema
                           AND p.prosrc ILIKE '%' || search_text || '%'
                         UNION ALL
                         SELECT t.tgname                 AS object_name,
                                pg_get_triggerdef(t.oid) AS object_code,
                                'Trigger'                AS object_type
                         FROM pg_trigger t
                                  JOIN pg_class c ON t.tgrelid = c.oid
                                  JOIN pg_namespace n ON c.relnamespace = n.oid
                         WHERE n.nspname = search_schema
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
$$;
