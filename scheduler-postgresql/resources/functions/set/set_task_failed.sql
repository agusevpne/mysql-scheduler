create or replace function set_task_failed (
    i_stsk_id  int
  , i_error_message text
)
returns void
as $$
  declare
    v_row_count    int;
begin

  update scheduled_tasks
     set exec_status = 'F', exec_start_date = null, exec_end_date = now()
   where i_stsk_id = stsk_id;

  get diagnostics v_row_count = row_count;
  if v_row_count <> 1 then
    raise exception 'lps:task.set.status.failed';
  end if;

  insert into scheduled_task_logs(stsk_stsk_id,
                                  exec_start_date,
                                  exec_end_date,
                                  exec_status,
                                  error_message
                                 )
       values (i_stsk_id,
               null,
               current_timestamp,
               'F',
               i_error_message
              );

end;
$$
language 'plpgsql'
security definer;
