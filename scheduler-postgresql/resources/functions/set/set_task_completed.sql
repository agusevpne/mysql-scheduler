create or replace function set_task_completed (
  i_stsk_id  int
)
returns void
as $$
  declare
    v_exec_end_date    timestamp default now();
    v_row_count    int;
begin

    update scheduled_tasks
       set exec_status       = 'C',
           exec_start_date   = null,
           exec_end_date     = v_exec_end_date,
           exec_next_date      =
             case
               when schedule_strategy = 'E' then
                 case
                   when substring(retry_interval from '..$') = 'ME' then
                     date_trunc('month',
                                 v_exec_end_date + substring(retry_interval for length(retry_interval) - 1)::int * interval '1 month'
                                ) + interval '1 month - 1 hour'
                   when substring(retry_interval from '..$') = 'MI' then
                     v_exec_end_date + substring(retry_interval for length(retry_interval) - 2)::int * interval '1 minute'
                   when substring(retry_interval from '..$') = 'HH' then
                     v_exec_end_date + substring(retry_interval for length(retry_interval) - 2)::int * interval '1 hour'
                   when substring(retry_interval from '.$') = 'D' then
                     v_exec_end_date + substring(retry_interval for length(retry_interval) - 1)::int * interval '1 day'
                   when substring(retry_interval from '.$') = 'M' then
                     v_exec_end_date + substring(retry_interval for length(retry_interval) - 1)::int * interval '1 month'
                   when substring(retry_interval from '.$') = 'Y' then
                     v_exec_end_date + substring(retry_interval for length(retry_interval) - 1)::int * interval '1 year'
                 end
               when schedule_strategy = 'S' then
                 case
                   when substring(retry_interval from '..$') = 'ME' then
                     date_trunc('month',
                                 task_start_date +
                                   substring(retry_interval for length(retry_interval) - 1)::int
                                            * (  floor(
                                                     ((date_part('year', v_exec_end_date) - date_part('year', task_start_date)) * 12
                                                     + date_part('month', v_exec_end_date) - date_part('month', task_start_date))
                                                   / substring(retry_interval for length(retry_interval) - 1)::int
                                                 )
                                               + 1) * interval '1 month'
                                ) + interval '1 month - 1 hour'
                   when substring(retry_interval from '..$') = 'MI' then
                     task_start_date + 
                       substring(retry_interval for length(retry_interval) - 2)::int
                                * (  floor(
                                         date_part('epoch', v_exec_end_date - task_start_date)
                                       / 60
                                       / substring(retry_interval for length(retry_interval) - 2)::int
                                     )
                                   + 1) * interval '1 minute'
                   when substring(retry_interval from '..$') = 'HH' then
                     task_start_date + 
                       substring(retry_interval for length(retry_interval) - 2)::int
                                * (  floor(
                                         date_part('epoch', v_exec_end_date - task_start_date)
                                       / 60
                                       / 60
                                       / substring(retry_interval for length(retry_interval) - 2)::int
                                     )
                                   + 1) * interval '1 hour'
                   when substring(retry_interval from '.$') = 'D' then
                     task_start_date + 
                       substring(retry_interval for length(retry_interval) - 1)::int
                                * (  floor(
                                         date_part('day', v_exec_end_date - task_start_date)
                                       / substring(retry_interval for length(retry_interval) - 1)::int
                                     )
                                   + 1) * interval '1 day'
                   when substring(retry_interval from '.$') = 'M' then
                     task_start_date + 
                       substring(retry_interval for length(retry_interval) - 1)::int
                                * (  floor(
                                         ((date_part('year', v_exec_end_date) - date_part('year', task_start_date)) * 12
                                         + date_part('month', v_exec_end_date) - date_part('month', task_start_date))
                                       / substring(retry_interval for length(retry_interval) - 1)::int
                                     )
                                   + 1) * interval '1 month'
                   when substring(retry_interval from '.$') = 'Y' then
                     task_start_date + 
                       substring(retry_interval for length(retry_interval) - 1)::int
                                * (  floor(
                                         (date_part('year', v_exec_end_date) - date_part('year', task_start_date))
                                       / substring(retry_interval for length(retry_interval) - 1)::int
                                     )
                                   + 1) * interval '1 year'
                 end
             end,
           task_start_date      =
             case
               when schedule_strategy = 'E' then
                 task_start_date
               when schedule_strategy = 'S' then
                 case
                   when substring(retry_interval from '..$') = 'ME' then
                     date_trunc('month',
                                 exec_next_date - substring(retry_interval for length(retry_interval) - 1)::int * interval '1 month'
                                ) + interval '1 month - 1 hour'
                   when substring(retry_interval from '..$') = 'MI' then
                     exec_next_date - substring(retry_interval for length(retry_interval) - 2)::int * interval '1 minute'
                   when substring(retry_interval from '..$') = 'HH' then
                     exec_next_date - substring(retry_interval for length(retry_interval) - 2)::int * interval '1 hour'
                   when substring(retry_interval from '.$') = 'D' then
                     exec_next_date - substring(retry_interval for length(retry_interval) - 1)::int * interval '1 day'
                   when substring(retry_interval from '.$') = 'M' then
                     exec_next_date - substring(retry_interval for length(retry_interval) - 1)::int * interval '1 month'
                   when substring(retry_interval from '.$') = 'Y' then
                     exec_next_date - substring(retry_interval for length(retry_interval) - 1)::int * interval '1 year'
                 end
             end
     where i_stsk_id = stsk_id;

    get diagnostics v_row_count = row_count;
    if v_row_count <> 1 then
      raise exception 'lps:task.set.status.failed';
    end if;

    insert into scheduled_task_logs(stsk_stsk_id, exec_end_date, exec_status)
         values (i_stsk_id, now(), 'C');

end;
$$
language 'plpgsql'
security definer;
