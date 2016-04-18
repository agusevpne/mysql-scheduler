drop type if exists get_schedule_tasks_row cascade;
create type get_schedule_tasks_row as (
    task_id          int
  , task_name        varchar(64)
);

create or replace function get_schedule_tasks (
  i_max_tasks_count  int
)
returns setof get_schedule_tasks_row
as $$
  declare
    v_run_date    timestamp default now();
    v_is_paused   varchar(1);
    row get_schedule_tasks_row%rowtype;
begin

  select setting_value
    into v_is_paused
    from scheduler_settings
   where setting_name = 'Scheduler paused';
  
  for row in
  select stsk_id task_id, task_name
    from scheduled_tasks
   where exec_status in ('C', 'F') and exec_next_date <= v_run_date and v_is_paused = 'N'
   limit i_max_tasks_count
  loop
    return next row;
  end loop;

end;
$$
language 'plpgsql'
security definer;

delete from resultset_info where specific_name = 'get_schedule_tasks';
insert into resultset_info (specific_name, routine_resultset)
values ('get_schedule_tasks',
        concat_ws(','
                , 'task_id int'
                , 'task_name varchar'
                 )
        );
