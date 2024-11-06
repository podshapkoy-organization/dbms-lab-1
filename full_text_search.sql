create or replace procedure full_text_search(search_schema text, search_text text)
    language plpgsql
as
$$
declare
    obj_record  RECORD;
    line_number int;
    line_text   text;
    counter     int := 0;
begin
    raise notice 'Текст запроса: %', search_text;
    raise notice 'No. | Имя объекта   | # строки | Текст';
    raise notice '----|---------------|----------|--------------------------------------------';

    for obj_record in
        select p.proname                 as object_name,
               pg_get_functiondef(p.oid) as object_definition
        from pg_proc p
                 join
             pg_namespace n on p.pronamespace = n.oid
        where n.nspname = search_schema
          and (p.prokind = 'p' or p.prokind = 'f')
        union all
        select t.tgname                 as object_name,
               pg_get_triggerdef(t.oid) as object_definition
        from pg_trigger t
                 join
             pg_class c ON t.tgrelid = c.oid
                 join
             pg_namespace n ON c.relnamespace = n.oid
        where n.nspname = search_schema
        loop
            line_number := 1;
            for line_text in select unnest(string_to_array(obj_record.object_definition, E'\n'))
                loop
                    if position(search_text in line_text) > 0 then
                        counter := counter + 1;
                        raise notice '% | % | % |%',
                            rpad(counter::text, 3),
                            rpad(obj_record.object_name, 13),
                            rpad(line_number::text, 8),
                            left(line_text, 20);
                    end if;
                    line_number := line_number + 1;
                end loop;
        end loop;
end;
$$

