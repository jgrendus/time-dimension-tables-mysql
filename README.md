# sp_key_time_tables.sql

20 Jul 2016

## Description

A MySQL stored procedure that creates key time dimesion tables (star schema)


-- CALL sp_key_time_tables(table_v, beg_time_v, end_time_v, debug_v);


-- CALL sp_key_time_tables('all',         NULL, NULL, NULL);
-- CALL sp_key_time_tables('key_hours',   NULL, NULL, 1);
-- CALL sp_key_time_tables('key_days',    NULL, NULL, 1);
-- CALL sp_key_time_tables('key_weeks',   NULL, NULL, NULL);
-- CALL sp_key_time_tables('key_months',  NULL, NULL, NULL);
-- CALL sp_key_time_tables('key_quarter', NULL, NULL, NULL);
-- CALL sp_key_time_tables('key_years',   NULL, NULL, NULL);


CALL sp_key_time_tables('all',         '2015-01-01', '2018-12-31', NULL);


