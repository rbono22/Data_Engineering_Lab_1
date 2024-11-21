

-- day 1 lab 

INSERT INTO players (
WITH yesterday AS (
    SELECT * FROM players
    WHERE current_season = 1996
), today AS (
    SELECT * FROM player_seasons ps
    WHERE season = 1997
)
SELECT 
    COALESCE(t.player_name, y.player_name) AS player_name,
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    CASE 
        WHEN y.season_stats IS NULL THEN ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        ELSE y.season_stats
    END AS season_stats,
    CASE 
        WHEN t.season IS NOT NULL THEN 
            CASE 
                WHEN t.pts > 20 THEN 'star'::scoring_class
                WHEN t.pts > 15 THEN 'good'::scoring_class
                WHEN t.pts > 10 THEN 'average'::scoring_class
                ELSE 'bad'::scoring_class
            END
        ELSE y.scoring_class
    END AS scoring_class,
    COALESCE(t.season, y.current_season + 1) AS current_season,
    CASE 
        WHEN t.season IS NOT NULL THEN 0
        ELSE COALESCE(y.years_since_last_season, 0) + 1
    END AS years_since_last_season
FROM today t
FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name
WHERE NOT EXISTS (
    SELECT 1
    FROM players p
    WHERE p.player_name = COALESCE(t.player_name, y.player_name)
    AND p.current_season = COALESCE(t.season, y.current_season + 1)
)