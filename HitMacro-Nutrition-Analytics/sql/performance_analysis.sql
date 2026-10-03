WITH Daily_Nutrition AS
(
    SELECT
        fl.User_ID,
        DATE(fl.Date_Time) AS nutrition_date,

        SUM(fl.Total_Calories_kcal) AS calories,
        SUM(fl.Total_Protein_g) AS protein,
        SUM(fl.Total_Carb_g) AS carbs,
        SUM(fl.Total_Fat_g) AS fat,
        SUM(fl.Total_Fibre_g) AS fibre

    FROM Food_Log fl

    GROUP BY
        fl.User_ID,
        DATE(fl.Date_Time)
),

Daily_Performance AS
(
    SELECT
        dn.User_ID,
        u.Name,
        dn.nutrition_date,

        ROUND(
            (
                CASE
                    WHEN dn.calories <= u.Daily_Calorie_Target
                    THEN 1 ELSE 0
                END

                +

                CASE
                    WHEN dn.protein >= u.Daily_Protein_Target_g
                    THEN 1 ELSE 0
                END

                +

                CASE
                    WHEN dn.carbs >= u.Daily_Carb_Target_g
                    THEN 1 ELSE 0
                END

                +

                CASE
                    WHEN dn.fat <= u.Daily_Fat_Target_g
                    THEN 1 ELSE 0
                END

                +

                CASE
                    WHEN dn.fibre >= u.Daily_Fibre_Target_g
                    THEN 1 ELSE 0
                END
            ) * 20,
            0
        ) AS performance_percentage

    FROM Daily_Nutrition dn

    JOIN Users u
        ON dn.User_ID = u.User_ID
),

Ranked_Days AS
(
    SELECT
        User_ID,
        Name,
        nutrition_date,
        performance_percentage,

        RANK() OVER
        (
            PARTITION BY User_ID
            ORDER BY performance_percentage DESC
        ) AS best_rank,

        RANK() OVER
        (
            PARTITION BY User_ID
            ORDER BY performance_percentage ASC
        ) AS worst_rank

    FROM Daily_Performance
)

SELECT
    User_ID,
    Name,
    nutrition_date,
    performance_percentage,

    CASE
        WHEN best_rank = 1
             AND worst_rank = 1
            THEN 'Best & Worst'

        WHEN best_rank = 1
            THEN 'Best Performing Day'

        WHEN worst_rank = 1
            THEN 'Worst Performing Day'

    END AS day_performance

FROM Ranked_Days

WHERE
    best_rank = 1
    OR worst_rank = 1

ORDER BY
    User_ID,
    nutrition_date;