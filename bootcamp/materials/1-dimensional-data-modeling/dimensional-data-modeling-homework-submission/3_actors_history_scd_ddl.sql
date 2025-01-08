CREATE TABLE actors_history_scd (
    actor_id TEXT NOT NULL,
    name TEXT NOT NULL,
    quality_class quality_class,
    current_year INTEGER,
    is_active BOOLEAN,
    start_date INTEGER,
    end_date INTEGER,
    PRIMARY KEY(actor_id, current_year)
);