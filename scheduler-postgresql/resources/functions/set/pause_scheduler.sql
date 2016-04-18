create or replace function pause_scheduler (
  i_max_wait_sec  int
)
returns void
as $$
  declare
    v_running_tasks_count   int;
    v_end_wait              int;
begin

    v_end_wait   = clock_timestamp() + i_max_wait_sec  * interval '1 second';

    update scheduler_settings
       set setting_value   = 'Y'
     where setting_name = 'Scheduler paused';

    select count(1)
      into v_running_tasks_count
      from scheduled_tasks
     where exec_status = 'R';

    while v_running_tasks_count > 0 loop
      perform pg_sleep(10);

      select count(1)
        into v_running_tasks_count
        from scheduled_tasks
       where exec_status = 'R';

      if v_end_wait < clock_timestamp() then
        raise exception 'lps:time.exceeded';
      end if;
    end loop;

end;
$$
language 'plpgsql'
security definer;
