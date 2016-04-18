insert into scheduler_settings(setting_name,
                               setting_value,
                               number_history,
                               start_date,
                               end_date,
                               username
                              )
     values ('Scheduler paused',
             'N',
             1,
             '1000-01-01'::timestamp,
             '2999-12-31'::timestamp,
             'mcshadow'
            );

commit;
