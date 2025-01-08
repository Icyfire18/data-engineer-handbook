WITH source_actors AS (
    SELECT
        actor_id,
		name,
        current_year,
        "quality_class",
        is_active,
        CASE
            WHEN is_active != LAG(is_active) OVER (PARTITION BY actor_id ORDER BY current_year) THEN 1
            WHEN LAG(is_active) OVER (PARTITION BY actor_id ORDER BY current_year) IS NULL THEN NULL
            WHEN "quality_class" != LAG("quality_class") OVER (PARTITION BY actor_id ORDER BY current_year) THEN 1
            WHEN LAG("quality_class") OVER (PARTITION BY actor_id ORDER BY current_year) IS NULL THEN NULL
            ELSE 0
        END as change_indicator
    FROM actors
    GROUP BY
        actor_id,
		name,
        current_year,
        "quality_class",
        is_active
),

changes AS (
    SELECT
        actor_id,
		name,
        current_year,
        "quality_class",
        is_active,
        change_indicator
    FROM source_actors
    WHERE 
        change_indicator = 1
        OR change_indicator IS NULL
),

combined AS (
    SELECT
        actor_id,
		name,
        current_year,
        quality_class,
        is_active,
        CASE
            WHEN 
                (LAG(change_indicator) OVER (PARTITION BY actor_id) = 1) THEN current_year
            WHEN 
                (LAG(change_indicator) OVER (PARTITION BY actor_id)) IS NULL THEN current_year
        END AS start_date,
        CASE
            WHEN 
                change_indicator = 1 AND current_year != MAX(current_year) OVER (PARTITION BY actor_id) THEN current_year
            WHEN 
                (LAG(change_indicator) OVER (PARTITION BY actor_id)) IS NULL THEN current_year
            WHEN current_year = MAX(current_year) OVER (PARTITION BY actor_id) THEN 9999
        END AS end_date
    FROM changes
    ORDER BY actor_id, current_year DESC
)

INSERT INTO actors_history_scd (
    actor_id,
	name,
    quality_class,
    is_active,
    start_date,
    end_date,
    current_year
)
SELECT
    actor_id,
	name,
    quality_class,
    is_active,
    start_date,
    end_date,
    current_year
FROM combined;
