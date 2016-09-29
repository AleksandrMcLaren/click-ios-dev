PRAGMA foreign_keys = ON;
CREATE TABLE continents (id INTEGER PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE countries (id INTEGER PRIMARY KEY, name TEXT NOT NULL,iso INTEGER NOT NULL, phonecode INTEGER NOT NULL, continent REFERENCES continents(id));
CREATE TABLE regions (id INTEGER PRIMARY KEY, name TEXT NOT NULL, countryid REFERENCES countries(id));
CREATE TABLE cities (id INTEGER PRIMARY KEY, name TEXT NOT NULL, regionid REFERENCES regions, latitude DOUBLE, longitude DOUBLE);

CREATE UNIQUE INDEX cities_regionid on cities (regionid);
CREATE UNIQUE INDEX regions_countryid on regions (countryid);
