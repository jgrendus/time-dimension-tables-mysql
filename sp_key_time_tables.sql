-- sp_key_time_tables.sql

-- README

-- This SP is designed to handle DST

-- TIMEZONE DOCUMENTATION:
-- stackoverflow.com/questions/19023978/should-mysql-have-its-timezone-set-to-utc

DROP DATABASE IF EXISTS key_tables;

CREATE DATABASE IF NOT EXISTS key_tables;

USE key_tables;

DELIMITER |

DROP PROCEDURE IF EXISTS sp_key_time_tables|

CREATE PROCEDURE sp_key_time_tables
(IN table_v VARCHAR(255),
    beg_time_v DATETIME,
    end_time_v DATETIME,
    debug_v TINYINT UNSIGNED
 )
BEGIN

-- variables: generic
DECLARE beg_runtime_v DATETIME;

-- variables: key_hours
DECLARE hour_ts_v DATETIME;
DECLARE hour_uts_v BIGINT;
DECLARE py_date_v DATE;

-- variables: debug
DECLARE years_t_v TEXT;
DECLARE years_i_v TEXT;
DECLARE years_s_v TEXT;
DECLARE quarters_t_v TEXT;
DECLARE quarters_i_v TEXT;
DECLARE quarters_s_v TEXT;
DECLARE months_t_v TEXT;
DECLARE months_i_v TEXT;
DECLARE months_s_v TEXT;
DECLARE weeks_t_v TEXT;
DECLARE weeks_i_v TEXT;
DECLARE weeks_s_v TEXT;
DECLARE days_t_v TEXT;
DECLARE days_i_v TEXT;
DECLARE days_s_v TEXT;
DECLARE hours_t_v TEXT;
DECLARE hours_i_v TEXT;
DECLARE hours_s_v TEXT;

-- set variables
SET beg_runtime_v = NOW();

-- set session variables
SET SESSION auto_increment_increment = 1;
SET SESSION auto_increment_offset = 1;
SET SESSION max_sp_recursion_depth = 9;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY';
SET SESSION time_zone = '+00:00';

-- set defaults
SET table_v = IFNULL(table_v, 'key_hours');
SET end_time_v = DATE_FORMAT(LEAST('2037-12-31', COALESCE(end_time_v, beg_time_v, NOW())), '%Y-12-31 23:59:59');

-- set create table dynamic sql variables
SET years_t_v = '
 -- YEAR
 year_c CHAR(4) NOT NULL,
 year_d DATE NOT NULL,
 year_end_d DATE NOT NULL,
 year_end_ts DATETIME NOT NULL,
 year_i SMALLINT UNSIGNED NOT NULL,
 year_uts BIGINT NOT NULL,
 year_end_uts BIGINT NOT NULL';

SET quarters_t_v = '
 -- QUARTER
 quarter_c CHAR(1) NOT NULL,
 quarter_d DATE NOT NULL,
 quarter_end_d DATE NOT NULL,
 quarter_end_ts DATETIME NOT NULL,
 quarter_i TINYINT UNSIGNED NOT NULL,
 quarter_uts BIGINT NOT NULL,
 quarter_end_uts BIGINT NOT NULL';

SET months_t_v = '
 -- MONTH
 month_c CHAR(2) NOT NULL,
 month_d DATE NOT NULL,
 month_end_d DATE NOT NULL,
 month_end_ts DATETIME NOT NULL,
 month_i TINYINT UNSIGNED NOT NULL,
 month_name_c VARCHAR(9) NOT NULL,
 month_uts BIGINT NOT NULL,
 month_end_uts BIGINT NOT NULL';

SET weeks_t_v = '
 -- WEEK
 week_d DATE NOT NULL,
 week_end_d DATE NOT NULL,
 week_end_ts DATETIME NOT NULL,
 week_uts BIGINT NOT NULL,
 week_end_uts BIGINT NOT NULL';

SET days_t_v = '
 -- DAY
 date_c CHAR(14) NOT NULL,
 date_d DATE NOT NULL,
 date_end_d DATE NOT NULL,
 date_end_ts DATETIME NOT NULL,
 date_uts BIGINT NOT NULL,
 date_end_uts BIGINT NOT NULL,
 day_c CHAR(2) NOT NULL,
 day_i TINYINT UNSIGNED NOT NULL,
 day_of_week_c CHAR(3) NOT NULL,
 day_of_week_i TINYINT UNSIGNED NOT NULL,
 py_date_d DATE NOT NULL';

SET hours_t_v = '
 -- HOUR
 hour_c CHAR(2) NOT NULL,
 hour_i TINYINT UNSIGNED NOT NULL,
 hour_ts DATETIME UNIQUE KEY,
 hour_end_ts DATETIME NOT NULL,
 hour_uts BIGINT NOT NULL,
 hour_end_uts BIGINT NOT NULL';

-- set insert dynamic sql variables
SET years_i_v = '       (
        -- YEAR
        year_c,
        year_d,
        year_end_d,
        year_end_ts,
        year_i,
        year_uts,
        year_end_uts';

SET quarters_i_v = '
        -- QUARTER
        quarter_c,
        quarter_d,
        quarter_end_d,
        quarter_end_ts,
        quarter_i,
        quarter_uts,
        quarter_end_uts';

SET months_i_v = '
        -- MONTH
        month_c,
        month_d,
        month_end_d,
        month_end_ts,
        month_i,
        month_name_c,
        month_uts,
        month_end_uts';

SET weeks_i_v = '
        -- WEEK
        week_d,
        week_end_d,
        week_end_ts,
        week_uts,
        week_end_uts';

SET days_i_v = '
        -- DAY
        date_c,
        date_d,
        date_end_d,
        date_end_ts,
        date_uts,
        date_end_uts,
        day_c,
        day_i,
        day_of_week_c,
        day_of_week_i,
        py_date_d';

SET hours_i_v = '
        -- HOUR
        hour_c,
        hour_i,
        hour_ts,
        hour_end_ts,
        hour_uts,
        hour_end_uts';

-- set select dynamic sql variables
SET years_s_v = '
    -- YEAR
    year_c,
    year_d,
    year_end_d,
    year_end_ts,
    year_i,
    year_uts,
    year_end_uts';

SET quarters_s_v = '
    -- QUARTER
    quarter_c,
    quarter_d,
    quarter_end_d,
    quarter_end_ts,
    quarter_i,
    quarter_uts,
    quarter_end_uts';

SET months_s_v = '
    -- MONTH
    month_c,
    month_d,
    month_end_d,
    month_end_ts,
    month_i,
    month_name_c,
    month_uts,
    month_end_uts';

SET weeks_s_v = '
    -- WEEK
    week_d,
    week_end_d,
    week_end_ts,
    week_uts,
    week_end_uts';

SET days_s_v = '
    -- DAY
    date_c,
    date_d,
    date_end_d,
    date_end_ts,
    date_uts,
    date_end_uts,
    day_c,
    day_i,
    day_of_week_c,
    day_of_week_i,
    py_date_d';

CASE table_v
    WHEN 'all' THEN

CALL sp_key_time_tables('key_hours',    beg_time_v, end_time_v, debug_v);
CALL sp_key_time_tables('key_days',     NULL,       NULL,       debug_v);
CALL sp_key_time_tables('key_weeks',    NULL,       NULL,       debug_v);
CALL sp_key_time_tables('key_months',   NULL,       NULL,       debug_v);
CALL sp_key_time_tables('key_quarters', NULL,       NULL,       debug_v);
CALL sp_key_time_tables('key_years',    NULL,       NULL,       debug_v);

    WHEN 'key_hours' THEN

DROP TABLE IF EXISTS _key_hours_temp;

SET @statement:= CONCAT('CREATE TABLE _key_hours_temp
(id MEDIUMINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,',
                        years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, ', ',
                        weeks_t_v, ', ',
                        days_t_v, ', ',
                        hours_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

-- resolve to date and set default if need be
SET beg_time_v = DATE_FORMAT(LEAST(GREATEST(end_time_v, NOW()), IFNULL(beg_time_v, end_time_v)), '%Y-01-01');
SET hour_ts_v = DATE_SUB(beg_time_v, INTERVAL 1 HOUR);
SET hour_uts_v = IF(beg_time_v > DATE_SUB(FROM_UNIXTIME(0), INTERVAL 1 HOUR), UNIX_TIMESTAMP(beg_time_v) - 3600, 0);

REPEAT
    -- check to see if epoch time has been reached
    IF hour_uts_v > -3601 THEN
        SET hour_uts_v = hour_uts_v + 3600;
        SET hour_ts_v = FROM_UNIXTIME(hour_uts_v);
    ELSE
        SET hour_ts_v = DATE_ADD(hour_ts_v, INTERVAL 1 HOUR);
    END IF;

    SET py_date_v = (SELECT
                         D.date_d
                     FROM (      SELECT DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR) AS "date_d"
                           UNION SELECT DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR), INTERVAL 1 DAY)
                           UNION SELECT DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR), INTERVAL 2 DAY)
                           UNION SELECT DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR), INTERVAL 3 DAY)
                           UNION SELECT DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR), INTERVAL 4 DAY)
                           UNION SELECT DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR), INTERVAL 5 DAY)
                           UNION SELECT DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL 1 YEAR), INTERVAL 6 DAY)
                           ) D
                     WHERE DAYOFWEEK(D.date_d) = DAYOFWEEK(DATE(hour_ts_v))
                     );

    INSERT _key_hours_temp
           (
            -- YEAR
            year_c,
            year_d,
            year_end_d,
            year_end_ts,
            year_i,
            year_uts,
            year_end_uts,

            -- QUARTER
            quarter_c,
            quarter_d,
            quarter_end_d,
            quarter_end_ts,
            quarter_i,
            quarter_uts,
            quarter_end_uts,

            -- MONTH
            month_c,
            month_d,
            month_end_d,
            month_end_ts,
            month_i,
            month_name_c,
            month_uts,
            month_end_uts,

            -- WEEK
            week_d,
            week_end_d,
            week_end_ts,
            week_uts,
            week_end_uts,

            -- DAY
            date_c,
            date_d,
            date_end_d,
            date_end_ts,
            date_uts,
            date_end_uts,
            day_c,
            day_i,
            day_of_week_c,
            day_of_week_i,
            py_date_d,

            -- HOUR
            hour_c,
            hour_i,
            hour_ts,
            hour_end_ts,
            hour_uts,
            hour_end_uts
            )
    SELECT

        -- YEAR
        DATE_FORMAT(hour_ts_v, '%Y') AS 'year_c',
        DATE_FORMAT(hour_ts_v, '%Y-01-01') AS 'year_d',
        DATE_SUB(DATE_ADD(DATE_FORMAT(hour_ts_v, '%Y-01-01'), INTERVAL 1 YEAR), INTERVAL 1 SECOND) AS 'year_end_d',
        DATE_SUB(DATE_ADD(DATE_FORMAT(hour_ts_v, '%Y-01-01'), INTERVAL 1 YEAR), INTERVAL 1 SECOND) AS 'year_end_ts',
        DATE_FORMAT(hour_ts_v, '%Y') AS 'year_i',
        UNIX_TIMESTAMP(DATE_FORMAT(hour_ts_v, '%Y-01-01')) AS 'year_uts',
        UNIX_TIMESTAMP(DATE_SUB(DATE_ADD(DATE_FORMAT(hour_ts_v, '%Y-01-01'), INTERVAL 1 YEAR), INTERVAL 1 SECOND)) AS 'year_end_uts',

        -- QUARTER
        QUARTER(hour_ts_v) AS 'quarter_c',
        CONCAT(YEAR(hour_ts_v), '-', QUARTER(hour_ts_v) * 3 - 2, '-01') AS 'quarter_d',
        DATE_SUB(DATE_ADD(CONCAT(YEAR(hour_ts_v), '-', QUARTER(hour_ts_v) * 3, '-01'), INTERVAL 1 MONTH), INTERVAL 1 SECOND) AS 'quarter_end_d',
        DATE_SUB(DATE_ADD(CONCAT(YEAR(hour_ts_v), '-', QUARTER(hour_ts_v) * 3, '-01'), INTERVAL 1 MONTH), INTERVAL 1 SECOND) AS 'quarter_end_ts',
        QUARTER(hour_ts_v) AS 'quarter_i',
        UNIX_TIMESTAMP(CONCAT(YEAR(hour_ts_v), '-', QUARTER(hour_ts_v) * 3 - 2, '-01')) AS 'quarter_uts',
        UNIX_TIMESTAMP(DATE_SUB(DATE_ADD(CONCAT(YEAR(hour_ts_v), '-', QUARTER(hour_ts_v) * 3, '-01'), INTERVAL 1 MONTH), INTERVAL 1 SECOND)) AS 'quarter_end_uts',

        -- MONTH
        DATE_FORMAT(hour_ts_v, '%m') AS 'month_c',
        DATE_FORMAT(hour_ts_v, '%Y-%m-01') AS 'month_d',
        DATE_SUB(DATE_ADD(DATE_FORMAT(hour_ts_v, '%Y-%m-01'), INTERVAL 1 MONTH), INTERVAL 1 SECOND) AS 'month_end_d',
        DATE_SUB(DATE_ADD(DATE_FORMAT(hour_ts_v, '%Y-%m-01'), INTERVAL 1 MONTH), INTERVAL 1 SECOND) AS 'month_end_ts',
        DATE_FORMAT(hour_ts_v, '%c') AS 'month_i',
        DATE_FORMAT(hour_ts_v, '%M') AS 'month_name_c',
        UNIX_TIMESTAMP(DATE_FORMAT(hour_ts_v, '%Y-%m-01')) AS 'month_uts',
        UNIX_TIMESTAMP(DATE_SUB(DATE_ADD(DATE_FORMAT(hour_ts_v, '%Y-%m-01'), INTERVAL 1 MONTH), INTERVAL 1 SECOND)) AS 'month_end_uts',

        -- WEEK
        DATE_SUB(hour_ts_v, INTERVAL(DAYOFWEEK(hour_ts_v) - 1) DAY) AS "week_d",
        DATE_SUB(DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL(DAYOFWEEK(hour_ts_v) - 1) DAY), INTERVAL 7 DAY), INTERVAL 1 SECOND) AS "week_end_d",
        DATE_SUB(DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL(DAYOFWEEK(hour_ts_v) - 1) DAY), INTERVAL 7 DAY), INTERVAL 1 SECOND) AS "week_end_ts",
        UNIX_TIMESTAMP(DATE_SUB(DATE(hour_ts_v), INTERVAL(DAYOFWEEK(hour_ts_v) - 1) DAY)) AS "week_uts",
        UNIX_TIMESTAMP(DATE_SUB(DATE_ADD(DATE_SUB(DATE(hour_ts_v), INTERVAL(DAYOFWEEK(hour_ts_v) - 1) DAY), INTERVAL 7 DAY), INTERVAL 1 SECOND)) AS "week_end_uts",

        -- DAY
        DATE_FORMAT(hour_ts_v, '%Y-%m-%d %a') AS 'date_c',
        hour_ts_v AS 'date_d',
        DATE_SUB(DATE_ADD(DATE(hour_ts_v), INTERVAL 1 DAY), INTERVAL 1 SECOND) AS 'date_end_d',
        DATE_SUB(DATE_ADD(DATE(hour_ts_v), INTERVAL 1 DAY), INTERVAL 1 SECOND) AS 'date_end_ts',
        UNIX_TIMESTAMP(DATE(hour_ts_v)) AS 'date_uts',
        UNIX_TIMESTAMP(DATE_SUB(DATE_ADD(DATE(hour_ts_v), INTERVAL 1 DAY), INTERVAL 1 SECOND)) AS 'date_end_uts',
        DATE_FORMAT(hour_ts_v, '%d') AS 'day_c',
        DATE_FORMAT(hour_ts_v, '%e') AS 'day_i',
        DATE_FORMAT(hour_ts_v, '%a') AS 'day_of_week_c',
        DAYOFWEEK(hour_ts_v) AS "day_of_week_i",
        py_date_v AS 'py_date_d',

        -- HOUR
        DATE_FORMAT(hour_ts_v, '%H') AS 'hour_c',
        DATE_FORMAT(hour_ts_v, '%k') AS 'hour_i',
        hour_ts_v AS 'hour_ts',
        DATE_SUB(DATE_ADD(hour_ts_v, INTERVAL 1 HOUR), INTERVAL 1 SECOND) AS 'hour_end_ts',
        hour_uts_v AS 'hour_uts',
        UNIX_TIMESTAMP(DATE_SUB(DATE_ADD(hour_ts_v, INTERVAL 1 HOUR), INTERVAL 1 SECOND)) AS 'hour_end_uts';

    UNTIL DATE_ADD(hour_ts_v, INTERVAL 1 HOUR) > end_time_v
END REPEAT;

ALTER TABLE _key_hours_temp
ADD UNIQUE KEY (hour_ts),
ADD KEY (year_i);

DROP TABLE IF EXISTS key_hours;

RENAME TABLE _key_hours_temp TO key_hours;

    WHEN 'key_days' THEN

DROP TABLE IF EXISTS _key_days_temp;

SET @statement:= CONCAT('CREATE TABLE _key_days_temp
(id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,',
                        years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, ', ',
                        weeks_t_v, ', ',
                        days_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

SET @statement:= CONCAT('INSERT _key_days_temp
',
                        years_i_v, ', ',
                        quarters_i_v, ', ',
                        months_i_v, ', ',
                        weeks_i_v, ', ',
                        days_i_v, '
        )
SELECT DISTINCTROW',
                        years_s_v, ', ',
                        quarters_s_v, ', ',
                        months_s_v, ', ',
                        weeks_s_v, ', ',
                        days_s_v, '
FROM key_hours
ORDER BY date_d;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

ALTER TABLE _key_days_temp
ADD UNIQUE KEY (date_d),
ADD KEY (year_i, month_d, date_d),
ADD KEY (month_d, date_d);

DROP TABLE IF EXISTS key_days;

RENAME TABLE _key_days_temp TO key_days;

    WHEN 'key_weeks' THEN

DROP TABLE IF EXISTS _key_weeks_temp;

SET @statement:= CONCAT('CREATE TABLE _key_weeks_temp
(id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,', weeks_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

SET @statement:= CONCAT('INSERT _key_weeks_temp
       (', weeks_i_v, '
        )
SELECT DISTINCTROW', weeks_s_v, '
FROM key_hours
ORDER BY week_d;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

ALTER TABLE _key_weeks_temp
ADD UNIQUE KEY (week_d);

DROP TABLE IF EXISTS key_weeks;

RENAME TABLE _key_weeks_temp TO key_weeks;

    WHEN 'key_months' THEN

DROP TABLE IF EXISTS _key_months_temp;

SET @statement:= CONCAT('CREATE TABLE _key_months_temp
(id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,',
                        years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

DROP TABLE IF EXISTS _key_months_temp;

SET @statement:= CONCAT('CREATE TABLE _key_months_temp
(id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,',
                        years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

SET @statement:= CONCAT('INSERT _key_months_temp
',
                        years_i_v, ', ',
                        quarters_i_v, ', ',
                        months_i_v, '
        )
SELECT DISTINCTROW',
                        years_s_v, ', ',
                        quarters_s_v, ', ',
                        months_s_v, '
FROM key_hours
ORDER BY month_d;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

ALTER TABLE _key_months_temp
ADD UNIQUE KEY (month_d),
ADD KEY (year_i, month_d);

DROP TABLE IF EXISTS key_months;

RENAME TABLE _key_months_temp TO key_months;

    WHEN 'key_quarters' THEN

DROP TABLE IF EXISTS _key_quarters_temp;

SET @statement:= CONCAT('CREATE TABLE _key_quarters_temp
(id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,',
                        years_t_v, ', ',
                        quarters_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

SET @statement:= CONCAT('INSERT _key_quarters_temp
',
                        years_i_v, ', ',
                        quarters_i_v, '
        )
SELECT DISTINCTROW',
                        years_s_v, ', ',
                        quarters_s_v, '
FROM key_hours
ORDER BY quarter_d;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

ALTER TABLE _key_quarters_temp
ADD UNIQUE KEY (quarter_d),
ADD KEY (year_i, quarter_d);

DROP TABLE IF EXISTS key_quarters;

RENAME TABLE _key_quarters_temp TO key_quarters;

    WHEN 'key_years' THEN

DROP TABLE IF EXISTS _key_years_temp;

SET @statement:= CONCAT('CREATE TABLE _key_years_temp
(id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,',
                        years_t_v, '
 ) ENGINE = MYISAM;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

SET @statement:= CONCAT('INSERT _key_years_temp
',
                        years_i_v, '
        )
SELECT DISTINCTROW',
                        years_s_v, '
FROM key_hours
ORDER BY year_d;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

ALTER TABLE _key_years_temp
ADD UNIQUE KEY (year_d),
ADD UNIQUE KEY (year_i);

DROP TABLE IF EXISTS key_years;

RENAME TABLE _key_years_temp TO key_years;

END CASE;

-- runtime
IF table_v != 'all' THEN

    SET @statement:= CONCAT('SELECT FORMAT((SELECT id
               FROM ', table_v, '
               ORDER BY 1 DESC
               LIMIT 1
               ), 0) INTO @row_count_v;');

    PREPARE statement FROM @statement;
    EXECUTE statement;
    DROP PREPARE statement;

    SET @row_count_v:= CONCAT(' (', @row_count_v, ' rows)');
ELSE
    SET @row_count_v:= '';
END IF;

SET @statement:= CONCAT('      SELECT CONCAT(LPAD("BEGIN: ", 9, " "), "', beg_runtime_v, '") AS "', table_v, @row_count_v, '"
UNION SELECT CONCAT(LPAD("END: ", 9, " "), NOW())
UNION SELECT CONCAT(LPAD("RUNTIME: ", 9, " "), LPAD(TIMEDIFF(NOW(), "', beg_runtime_v, '"), 19, " "))
UNION SELECT "";');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

SET debug_v = IF(table_v IN ('key_hours', 'key_days', 'key_weeks', 'key_months', 'key_quarters', 'key_years'), IFNULL(debug_v, 0), 0);

IF debug_v > 0 THEN

SET years_t_v = 'SELECT
    -- YEAR
    year_c                                AS "Year (CHAR)",
    year_d                                AS "Year (DATE)",
    year_end_d                            AS "Year End (DATE)",
    year_end_ts                           AS "Year End (DATETIME)",
    year_i                                AS "Year (SMALLINT)",
    year_uts                              AS "Year (UNIX)",
    FROM_UNIXTIME(year_uts)               AS "Year (UNIX converted)",
    year_end_uts                          AS "Year End (UNIX)",
    FROM_UNIXTIME(year_end_uts)           AS "Year End (UNIX converted)"';

SET quarters_t_v = '
    -- QUARTER
    quarter_c                             AS "Quarter (CHAR)",
    quarter_d                             AS "Quarter (DATE)",
    quarter_end_d                         AS "Quarter End (DATE)",
    quarter_end_ts                        AS "Quarter End (DATETIME)",
    quarter_i                             AS "Quarter (TINYINT)",
    quarter_uts                           AS "Quarter (UNIX)",
    FROM_UNIXTIME(quarter_uts)            AS "Quarter (UNIX converted)",
    quarter_end_uts                       AS "Quarter End (UNIX)",
    FROM_UNIXTIME(quarter_end_uts)        AS "Quarter End (UNIX converted)"';

SET months_t_v = '
    -- MONTH
    month_c                               AS "Month (CHAR)",
    month_d                               AS "Month (DATE)",
    month_end_d                           AS "Month End (DATE)",
    month_end_ts                          AS "Month End (DATETIME)",
    month_i                               AS "Month (TINYINT)",
    month_name_c                          AS "Month Name (CHAR)",
    month_uts                             AS "Month (UNIX)",
    FROM_UNIXTIME(month_uts)              AS "Month (UNIX converted)",
    month_end_uts                         AS "Month End (UNIX)",
    FROM_UNIXTIME(month_end_uts)          AS "Month End (UNIX converted)"';

SET weeks_t_v = '
    -- WEEK
    week_d                                AS "Week (DATE)",
    week_end_d                            AS "Week End (DATE)",
    week_end_ts                           AS "Week End (DATETIME)",
    week_uts                              AS "Week (UNIX)",
    FROM_UNIXTIME(week_uts)               AS "Week (UNIX converted)",
    week_end_uts                          AS "Week End (UNIX)",
    FROM_UNIXTIME(week_end_uts)           AS "Week End (UNIX converted)"';

SET days_t_v = '
    -- DAY
    date_c,
    date_d                                AS "Date (DATE)",
    date_end_d                            AS "Date End (DATE)",
    date_end_ts                           AS "Date End (DATETIME)",
    date_uts                              AS "Date (UNIX)",
    FROM_UNIXTIME(date_uts)               AS "Date (UNIX converted)",
    date_end_uts                          AS "Date End (UNIX)",
    FROM_UNIXTIME(date_end_uts)           AS "Date End (UNIX converted)",
    day_c                                 AS "Day (CHAR)",
    day_i                                 AS "Day (INTEGER)",
    day_of_week_c                         AS "Day of Week (CHAR)",
    day_of_week_i                         AS "Day of Week (INTEGER)",
    py_date_d                             AS "PY Date (DATE)",
    DATE_FORMAT(py_date_d, ''%Y-%m-%d %a'') AS "PY Date (DATE - converted)"';

SET hours_t_v = '
';

    CASE table_v
        WHEN 'key_hours' THEN

SET @statement:= CONCAT(years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, ', ',
                        weeks_t_v, ', ',
                        days_t_v, '
FROM key_hours
ORDER BY hour_ts');

        WHEN 'key_days' THEN

SET @statement:= CONCAT(years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, ', ',
                        weeks_t_v, ', ',
                        days_t_v, '
FROM key_days
ORDER BY date_d');

        WHEN 'key_weeks' THEN

SET @statement:= CONCAT('SELECT ', weeks_t_v, '
FROM key_weeks
ORDER BY week_d');

        WHEN 'key_months' THEN

SET @statement:= CONCAT(years_t_v, ', ',
                        quarters_t_v, ', ',
                        months_t_v, '
FROM key_months
ORDER BY month_d');

        WHEN 'key_quarters' THEN

SET @statement:= CONCAT(years_t_v, ', ',
                        quarters_t_v, '
FROM key_quarters
ORDER BY quarter_d');

        WHEN 'key_years' THEN

SET @statement:= CONCAT(years_t_v, '
FROM key_years
ORDER BY year_d');

    END CASE;

SET @statement:= CONCAT(@statement, '
LIMIT 20;');

PREPARE statement FROM @statement;
EXECUTE statement;
DROP PREPARE statement;

END IF;

COMMIT;

END|

DELIMITER ;

BEGIN;
