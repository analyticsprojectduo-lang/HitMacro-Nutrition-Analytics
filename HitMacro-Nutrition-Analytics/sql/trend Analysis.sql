/*10.
Trend Analysis

Problem:

Determine whether a user's nutritional performance is improving over time.*/

WITH Daily_Nutrition AS
(
    SELECT
        fl.User_ID,
        DATE(fl.Date_Time) AS nutrition_date,

        SUM(fl.Total_Calories_kcal) AS calories,
        SUM(fl.Total_Protein_g) AS protein,
        SUM(fl.Total_Fat_g) AS fat,
        SUM(fl.Total_Fibre_g) AS fibre,
        SUM(fl.Total_Carb_g) AS carbs

    FROM Food_Log fl

    GROUP BY
        fl.User_ID,
        DATE(fl.Date_Time)
),

Daily_Performance AS
(
    SELECT
        dn.User_ID,
        dn.nutrition_date,

        (
            CASE WHEN dn.calories <= u.Daily_Calorie_Target THEN 1 ELSE 0 END
            +
            CASE WHEN dn.protein >= u.Daily_Protein_Target_g THEN 1 ELSE 0 END
            +
            CASE WHEN dn.fat <= u.Daily_Fat_Target_g THEN 1 ELSE 0 END
            +
            CASE WHEN dn.fibre >= u.Daily_Fibre_Target_g THEN 1 ELSE 0 END
            +
            CASE WHEN dn.carbs >= u.Daily_Carb_Target_g THEN 1 ELSE 0 END
        ) * 20 AS performance_percentage

    FROM Daily_Nutrition dn

    JOIN Users u
        ON dn.User_ID = u.User_ID
),

Ranked_Performance AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY User_ID
            ORDER BY nutrition_date
        ) AS first_day,

        ROW_NUMBER() OVER
        (
            PARTITION BY User_ID
            ORDER BY nutrition_date DESC
        ) AS latest_day

    FROM Daily_Performance
),

First_Performance AS
(
    SELECT
        User_ID,
        performance_percentage AS first_performance
    FROM Ranked_Performance
    WHERE first_day = 1
),

Latest_Performance AS
(
    SELECT
        User_ID,
        performance_percentage AS latest_performance
    FROM Ranked_Performance
    WHERE latest_day = 1
)

SELECT
    u.User_ID,
    u.Name,

    fp.first_performance,
    lp.latest_performance,

    lp.latest_performance - fp.first_performance
        AS performance_change,

    CASE
        WHEN lp.latest_performance > fp.first_performance
            THEN 'Improving'

        WHEN lp.latest_performance < fp.first_performance
            THEN 'Declining'

        ELSE 'Stable'
    END AS nutritional_trend

FROM Users u

JOIN First_Performance fp
    ON u.User_ID = fp.User_ID

JOIN Latest_Performance lp
    ON u.User_ID = lp.User_ID;