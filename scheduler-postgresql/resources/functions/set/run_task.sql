create or replace function run_task (
  i_stsk_id  int
)
returns void
as $$
  declare
    v_task_definition    text;
    v_row_count          int;
begin

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
