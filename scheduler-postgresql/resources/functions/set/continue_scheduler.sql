create or replace function continue_scheduler ()
returns void
as $$
begin

  update scheduler_settings
     set setting_value   = 'N'
   where setting_name = 'Scheduler paused';

end;
$$
language 'plpgsql'
security definer;
