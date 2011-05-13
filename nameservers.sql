CREATE SCHEMA FRzone;

DROP TABLE FRzone.nameservers;

CREATE TABLE FRzone.nameservers (
    id SERIAL UNIQUE NOT NULL,
    added TIMESTAMP NOT NULL DEFAULT now(),
    name TEXT UNIQUE NOT NULL);
