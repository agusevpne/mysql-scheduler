create sequence scheduled_tasks_seq;
create table scheduled_tasks (
   stsk_id                    int not null default nextval('scheduled_tasks_seq'),
   task_name                  varchar(64),
   task_description           varchar(256),
   task_definition            text,
   task_start_date            timestamp,
   retry_interval             varchar(128),
   schedule_strategy          varchar(1) not null default 'S',
   exec_next_date             timestamp,
   exec_start_date            timestamp,
   exec_end_date              timestamp,
   exec_status                varchar(1) not null default 'C',
   exce_max_run_time          int not null default 15,
   constraint pk_scheduled_tasks primary key (stsk_id),
   constraint unq_scheduled_tasks_task_name unique (task_name)
);
create index idx_scheduled_tasks_runnable on scheduled_tasks (exec_status, exec_start_date);

create sequence scheduled_task_logs_seq;
create table scheduled_task_logs(
  slog_id           int not null default nextval('scheduled_task_logs_seq'),
  stsk_stsk_id      int,
  exec_next_date    timestamp,
  exec_start_date   timestamp,
  exec_end_date     timestamp,
  exec_status       varchar(1),
  error_message     text,
  constraint pk_scheduled_task_logs primary key (slog_id),
  constraint fk_scheduled_task_logs_scheduled_tasks foreign key (stsk_stsk_id) references scheduled_tasks(stsk_id)
);

create sequence scheduler_settings_seq;
create table scheduler_settings (
  sett_id          int not null default nextval('scheduler_settings_seq'),
  setting_name     varchar(32) not null,
  setting_value    varchar(512),
  number_history   int not null,
  start_date       timestamp,
  end_date         timestamp,
  update_date      timestamp,
  username         varchar(64),
  constraint pk_scheduler_settings primary key (sett_id, number_history)
);
create index idx_scheduler_settings_start_end_dates on scheduler_settings (sett_id, start_date, end_date);
create index idx_scheduler_settings_setting_name on scheduler_settings (setting_name);

create sequence resultset_seq;
create table resultset_info (
     rs_id              bigint not null default nextval('resultset_seq')
   , specific_name      varchar(128)
   , routine_resultset  text
   , constraint pk_rs primary key (rs_id)
);
