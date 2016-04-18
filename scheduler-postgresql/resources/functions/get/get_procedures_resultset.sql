drop type if exists get_procedures_resultset_row cascade;
create type get_procedures_resultset_row as (
  specific_name varchar,
  routine_resultset varchar
);

drop type if exists column_row cascade;
create type column_row as (
  column_name varchar,
  column_type varchar
); 

create or replace function get_procedures_resultset(
)
returns setof get_procedures_resultset_row
as
$$
  declare
    function_name varchar;
    rows_count bigint;
    routine_resultset_string varchar;
    query varchar(1000);
    attribute_row column_row%rowtype;
    row get_procedures_resultset_row%rowtype;
  begin

    for function_name in 
    select proname 
      from pg_catalog.pg_namespace n 
           join
                pg_catalog.pg_proc p 
             on pronamespace = n.oid 
     where nspname = 'public'
    loop
      query:='select count(*) from resultset_info where specific_name = '''||function_name||'''';
      execute query into rows_count;
      if(rows_count = 0) then
        routine_resultset_string := '';  

        query:= 'SELECT attname, a.typname  from pg_type t JOIN pg_class on (reltype = t.oid) JOIN pg_attribute on (attrelid = pg_class.oid) JOIN pg_type a on (atttypid = a.oid) WHERE t.typname = (SELECT t.typname FROM pg_catalog.pg_proc p LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace INNER JOIN pg_type t ON p.prorettype = t.oid WHERE n.nspname = ''public'' and proname = '''||function_name||''' ORDER BY proname)';
           
        for attribute_row in
        execute query
        loop
        if(routine_resultset_string != '') then
          routine_resultset_string:=routine_resultset_string||', ';
        end if;
        routine_resultset_string:=routine_resultset_string||attribute_row.column_name||' '||attribute_row.column_type;
        end loop; 
          
        if(routine_resultset_string != '') then
        --check for other types
          routine_resultset_string := REPLACE(routine_resultset_string, 'int8', 'bigint');        
          routine_resultset_string := REPLACE(routine_resultset_string, 'int4', 'integer');
          insert into resultset_info (specific_name, routine_resultset) values (function_name, routine_resultset_string);
        end if;  
      end if;
    end loop;   

    for row in
    select specific_name, routine_resultset
      from resultset_info
    loop
    return next row;
    end loop;
    return;
  end;
$$
language 'plpgsql'
security definer;
