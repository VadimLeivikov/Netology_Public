
CREATE DATABASE DWH_FLIGHTS

CREATE SCHEMA solution



DROP TABLE IF EXISTS dim_calendar ;

CREATE TABLE dim_calendar (
	dt DATE NULL
);

INSERT INTO dim_calendar
SELECT gs::DATE
FROM GENERATE_SERIES('2023-01-01', '2023-12-31', INTERVAL '1 day') AS gs;

SELECT * FROM dim_calendar;


DROP TABLE IF EXISTS dim_passengers; 

CREATE TABLE dim_passengers (
	pass_id SERIAL ,  -- технический ключ
	document_id  VARCHAR(30)  NULL CHECK (document_id LIKE '____ ______'),    -- натуральный ключ
	passenger_name TEXT NULL,  -
	date_start DATE DEFAULT '2000-01-01'  NULL CHECK (DATE_PART('year',date_start)>=2000),
	date_end DATE DEFAULT '2199-12-31' NULL CHECK (DATE_PART('year',date_end)<=2199),
	num_version INT   DEFAULT 1,  
	CONSTRAINT dim_passengers_pkey PRIMARY KEY (pass_id, num_version)
);

/* Вспомогательные скрипты, удобны при проверке
SELECT * FROM dim_passengers; 
SELECT COUNT(*) FROM dim_passengers;
TRUNCATE TABLE dim_passengers;

DELETE FROM dim_passengers
WHERE document_id = '4363 948638';
*/



DROP TABLE IF EXISTS  dim_aircrafts ;

CREATE TABLE dim_aircrafts (
	aircraft_id INT2 NULL,	-- технический ключ
	aircraft_code CHAR(3) NULL CHECK (aircraft_code  SIMILAR TO '[A-Z0-9][A-Z0-9][A-Z0-9]'),  -- натуральный ключ
	model VARCHAR(30) NULL,  
	"range" INT NULL CHECK ("range" BETWEEN 0 AND 30000) , 
	date_start DATE DEFAULT '2000-01-01'  NULL CHECK (DATE_PART('year',date_start)>=2000),
	date_end DATE DEFAULT '2199-12-31' NULL CHECK (DATE_PART('year',date_end)<=2199),
	num_version INT   DEFAULT 1, 
	CONSTRAINT dim_aircrafts_pkey PRIMARY KEY (aircraft_id, num_version)
);

/*
SELECT * FROM dim_aircrafts; 
SELECT COUNT(*) FROM dim_aircrafts;
TRUNCATE TABLE dim_aircrafts;
*/


DROP TABLE IF EXISTS  dim_airports; 

CREATE TABLE dim_airports (
	airport_id INT2 NULL,   -- технический ключ
	airport_code CHAR(3) NULL  CHECK (airport_code  SIMILAR TO '[A-Z0-9][A-Z0-9][A-Z0-9]'),  -- натуральный ключ
	airport_name VARCHAR(30) NULL,
	city VARCHAR(30) NULL,
	timezone VARCHAR(30) NULL,
	date_start DATE DEFAULT '2000-01-01'  NULL CHECK (DATE_PART('year',date_start)>=2000),
	date_end DATE DEFAULT '2199-12-31' NULL CHECK (DATE_PART('year',date_end)<=2199),
	num_version INT   DEFAULT 1, 
	CONSTRAINT dim_airports_pkey PRIMARY KEY (airport_id, num_version)
);

/*
SELECT * FROM dim_airports; 
SELECT COUNT(*) FROM dim_airports;
TRUNCATE TABLE dim_airports;
*/


DROP TABLE IF EXISTS  dim_tariff; 

CREATE TABLE dim_tariff (
	tariff_id SERIAL,     -- технический ключ
	fare_conditions VARCHAR(10) NULL CHECK (fare_conditions IN ('Business','Comfort','Economy')),   -- натуральный ключ
	date_start DATE DEFAULT '2000-01-01'  NULL CHECK (DATE_PART('year',date_start)>=2000),
	date_end DATE DEFAULT '2199-12-31' NULL CHECK (DATE_PART('year',date_end)<=2199),
	num_version INT   DEFAULT 1, 
	CONSTRAINT dim_tariff_pkey PRIMARY KEY (tariff_id, num_version)
)

/*
SELECT * FROM dim_tariff; 
SELECT COUNT(*) FROM dim_tariff;
TRUNCATE TABLE dim_tariff;
*/


DROP TABLE IF EXISTS fact_flights ;

CREATE TABLE fact_flights (
    id serial4  NOT NULL,
	passenger_id INT4 NOT NULL,
    act_departure TIMESTAMP NULL CHECK (DATE_PART('year',act_departure)>=2000),
    act_arrival TIMESTAMP NULL CHECK (act_arrival<=now()),
    dep_delay VARCHAR(20) NULL CHECK (dep_delay::INT4>=0),
    arr_delay VARCHAR(20) NULL CHECK (arr_delay::INT4>=0),
	departure_airport_id INT2 NOT NULL, --REFERENCES dim_airports(airport_id),  
	arrival_airport_id INT2 NOT NULL, --REFERENCES dim_airports(airport_id),
	aircraft_id INT2 NOT NULL, --REFERENCES dim_aircrafts(aircraft_id),
    tariff_id  INT4 NULL,  ----REFERENCES dim_tariff(tariff_id),
	amount numeric(10, 2) NULL CHECK (amount>=0),
    CONSTRAINT fact_flights_pkey PRIMARY KEY (id)
    );
   
/*
SELECT * FROM fact_flights;
SELECT COUNT(*) FROM fact_flights;
TRUNCATE TABLE fact_flights;
*/



-- REJECTED TABLES
DROP TABLE IF EXISTS rejected_dim_passengers; 

CREATE TABLE rejected_dim_passengers (
	document_id  VARCHAR(30)  NULL,  
	passenger_name TEXT NULL  
	);

/*
SELECT * FROM rejected_dim_passengers;
SELECT COUNT(*) FROM rejected_dim_passengers;
TRUNCATE TABLE rejected_dim_passengers;
*/

DROP TABLE IF EXISTS  rejected_dim_aircrafts ;

CREATE TABLE rejected_dim_aircrafts (
	aircraft_code VARCHAR(50) NULL ,  
	model VARCHAR(30) NULL,  
	"range" INT NULL 
);

/*
SELECT * FROM rejected_dim_aircrafts;
SELECT COUNT(*) FROM rejected_dim_aircrafts;
TRUNCATE TABLE rejected_dim_aircrafts;
*/
   

DROP TABLE IF EXISTS  rejected_dim_airports ;

CREATE TABLE rejected_dim_airports (
	airport_code VARCHAR(3) NULL ,
	airport_name VARCHAR(30) NULL,
	city VARCHAR(30) NULL,
	timezone VARCHAR(30) NULL  
);

/*
SELECT * FROM rejected_dim_airports; 
SELECT COUNT(*) FROM rejected_dim_airports;
TRUNCATE TABLE rejected_dim_airports;
*/

DROP TABLE IF EXISTS rejected_fact_flights ;

CREATE TABLE rejected_fact_flights (
    id int4  NULL,
	passenger_id INT4  NULL,
    act_departure TIMESTAMP NULL,
    act_arrival TIMESTAMP NULL,
    dep_delay VARCHAR(20) NULL,
    arr_delay VARCHAR(20) NULL,
	departure_airport_id INT2 NULL, 
	arrival_airport_id INT2 NULL, 
	aircraft_id INT2 NULL, 
    tariff_id  INT4 NULL,
	amount numeric(10, 2) NULL ,
	dt TIMESTAMP NULL
    );
 
/*
SELECT * FROM rejected_fact_flights;
SELECT COUNT(*) FROM rejected_fact_flights;
TRUNCATE TABLE rejected_fact_flights;
*/
   
