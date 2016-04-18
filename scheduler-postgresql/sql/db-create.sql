set lc_messages to 'en_US.UTF-8';

create role sched login nosuperuser noinherit nocreatedb nocreaterole password '123sched123';
create database sched with owner=sched encoding='UTF-8' tablespace=pg_default;

\connect sched;

set lc_messages to 'en_US.UTF-8';

drop schema public;

create schema schedschema authorization sched;
alter database sched set search_path to schedschema;
alter role     sched set search_path to schedschema;

-- -- REVOKE
-- revoke all privileges on database sched from sched_ui;
-- revoke all privileges on all tables    in schema schedschema from sched_ui;
-- revoke all privileges on all functions in schema schedschema from sched_ui;
-- revoke all privileges on all sequences in schema schedschema from sched_ui;
-- 
-- grant execute on all functions in schema schedschema to sched_ui;
