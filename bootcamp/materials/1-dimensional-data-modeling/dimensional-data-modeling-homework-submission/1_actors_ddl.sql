CREATE TYPE films AS (
    year INTEGER,
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);

CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE actors (
    actor_id TEXT,
    name TEXT NOT NULL,
    films films [],
    quality_class quality_class,
    current_year INTEGER,
    is_active BOOLEAN,
    PRIMARY KEY(actor_id, current_year)
);