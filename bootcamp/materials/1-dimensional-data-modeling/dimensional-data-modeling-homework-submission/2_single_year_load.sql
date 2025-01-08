INSERT INTO
    actors WITH yesterday AS (
        SELECT
            *
        FROM
            actors
        WHERE
            current_year = 1969
    ),
    today AS (
        SELECT
            actor,
            actorid,
            year,
            ARRAY_AGG(ROW(year, film, votes, rating, filmid) :: films) AS films,
            CASE
                WHEN AVG(rating) > 8 THEN 'star'
                WHEN AVG(rating) > 7 THEN 'good'
                WHEN AVG(rating) > 6 THEN 'average'
                WHEN AVG(rating) <= 6 THEN 'bad'
                ELSE NULL
            END :: quality_class AS quality_class
        from
            actor_films
        WHERE
            year = 1970
        GROUP BY
            actor,
            actorid,
            year
    )
SELECT
    COALESCE(t.actorid, y.actor_id) AS actor_id,
    COALESCE(t.actor, y.name) AS name,
    CASE
        WHEN y.films IS NULL THEN t.films
        WHEN t.films IS NOT NULL THEN y.films || t.films
        ELSE y.films
    END as films,
    COALESCE(t.quality_class, y.quality_class) AS quality_class,
    COALESCE(t.year, y.current_year + 1) AS current_year,
    CASE
        WHEN t.films IS NOT NULL
        AND ARRAY_LENGTH(t.films, 1) > 0 THEN TRUE
        ELSE FALSE
    END AS is_active
FROM
    today t FULL
    OUTER JOIN yesterday y ON t.actorid = y.actor_id