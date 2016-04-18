create or replace function last_day (
  i_date  timestamp
)
returns timestamp
as $$
  declare
    v_date  timestamp;
begin

  select (date_trunc('month', i_date) + interval '1 month - 1 day')::timestamp into v_date;
  
  return v_date;

end;
$$
language 'plpgsql'
immutable strict security definer;
