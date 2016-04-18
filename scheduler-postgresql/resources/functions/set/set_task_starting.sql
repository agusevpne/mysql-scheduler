create or replace function set_task_starting (
  i_stsk_id  int
)
returns void
as $$
  declare
    v_task_definition    text;
    v_row_count          int;
begin

  update scheduled_tasks
     set exec_status = 'S', exec_start_date = now()
   where i_stsk_id = stsk_id and exec_status in ('F', 'C');

  get diagnostics v_row_count = row_count;
  if v_row_count <> 1 then
    raise exception 'lps:task.set.status.failed';
  end if;

  insert into scheduled_task_logs(stsk_stsk_id, exec_start_date, exec_status)
       values (i_stsk_id, now(), 'S');

end;
$$
language 'plpgsql'
security definer;
