create or replace function set_task_running (
  i_stsk_id  int
)
returns void
as $$
  declare
    v_task_definition    text;
    v_row_count          int;
begin

  update scheduled_tasks
     set exec_status   = 'R'
   where i_stsk_id = stsk_id and exec_status in ('S');

  get diagnostics v_row_count = row_count;
  if v_row_count <> 1 then
    raise exception 'lps:task.set.status.failed';
  end if;

    insert into scheduled_task_logs(stsk_stsk_id, exec_status)
         values (i_stsk_id, 'R');

--    commit;

  select task_definition
    into v_task_definition
    from scheduled_tasks
   where i_stsk_id = stsk_id and exec_status in ('R');

  if v_task_definition is null then
    raise exception 'lps:no.task.to.run';
  else
    execute v_task_definition;
    perform set_task_completed(i_stsk_id);
  end if;

end;
$$
language 'plpgsql'
security definer;
