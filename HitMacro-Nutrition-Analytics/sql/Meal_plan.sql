/*3.
if not acheived plan 21 days meal plan
food table,user table
*/
INSERT INTO Meal_Plan
(
    plan_id,
    user_id,
    plan_day,
    meal_type,
    food_id,
    quantity,
    reason
)

WITH RECURSIVE Days AS
(
    SELECT 1 AS plan_day

    UNION ALL

    SELECT plan_day + 1
    FROM Days
    WHERE plan_day < 21
),

Meal_Types AS
(
    SELECT 'Breakfast' AS meal_type
    UNION ALL
    SELECT 'Mid Snack'
    UNION ALL
    SELECT 'Lunch'
    UNION ALL
    SELECT 'Evening Snack'
    UNION ALL
    SELECT 'Dinner'
),

Failed_Days AS
(
    SELECT
        fl.User_ID,
        DATE(fl.Date_Time) AS failed_date,

        SUM(fl.Total_Calories_kcal) AS total_calories,
        SUM(fl.Total_Protein_g) AS total_protein,
        SUM(fl.Total_Fat_g) AS total_fat,
        SUM(fl.Total_Fibre_g) AS total_fibre,
        SUM(fl.Total_Carb_g) AS total_carb

    FROM Food_Log fl

    GROUP BY
        fl.User_ID,
        DATE(fl.Date_Time)
),

Latest_Failed_Day AS
(
    SELECT *
    FROM
    (
        SELECT
            fd.*,
            ROW_NUMBER() OVER
            (
                PARTITION BY fd.User_ID
                ORDER BY fd.failed_date DESC
            ) AS rn
        FROM Failed_Days fd

        JOIN Users u
            ON u.User_ID = fd.User_ID

        WHERE
               fd.total_calories > u.Daily_Calorie_Target
            OR fd.total_protein < u.Daily_Protein_Target_g
            OR fd.total_fat > u.Daily_Fat_Target_g
            OR fd.total_fibre < u.Daily_Fibre_Target_g
            OR fd.total_carb < u.Daily_Carb_Target_g
    ) x

    WHERE rn = 1
),

User_Deficiency AS
(
    SELECT
        u.User_ID,
        u.Name,
        lfd.failed_date,

        CASE
            WHEN lfd.total_calories > u.Daily_Calorie_Target
            THEN 1 ELSE 0
        END AS Calories_High,

        CASE
            WHEN lfd.total_protein < u.Daily_Protein_Target_g
            THEN 1 ELSE 0
        END AS Protein_Low,

        CASE
            WHEN lfd.total_fat > u.Daily_Fat_Target_g
            THEN 1 ELSE 0
        END AS Fat_High,

        CASE
            WHEN lfd.total_fibre < u.Daily_Fibre_Target_g
            THEN 1 ELSE 0
        END AS Fibre_Low,

        CASE
            WHEN lfd.total_carb < u.Daily_Carb_Target_g
            THEN 1 ELSE 0
        END AS Carb_Low

    FROM Users u

    JOIN Latest_Failed_Day lfd
        ON u.User_ID = lfd.User_ID
),

Food_Pool AS
(
    SELECT
        ud.User_ID,
        f.Food_ID,

        CASE
            WHEN ud.Protein_Low = 1
                 AND f.Protein_value_g_per_100g >= 10
            THEN 'Increase protein'

            WHEN ud.Fibre_Low = 1
                 AND f.Fibre_value_g_per_100g >= 5
            THEN 'Increase fibre'

            WHEN ud.Carb_Low = 1
                 AND f.Carb_value_g_per_100g >= 20
            THEN 'Increase carbohydrates'

            WHEN ud.Fat_High = 1
                 AND f.Fat_value_g_per_100g <= 10
            THEN 'Choose lower-fat food'

            WHEN ud.Calories_High = 1
                 AND f.Calories_kcal_per_100g <= 200
            THEN 'Choose lower-calorie food'

        END AS reason,

        ROW_NUMBER() OVER
        (
            PARTITION BY ud.User_ID
            ORDER BY f.Food_ID
        ) AS food_rank

    FROM User_Deficiency ud

    JOIN Foods f
        ON
           (
               ud.Protein_Low = 1
               AND f.Protein_value_g_per_100g >= 10
           )

        OR (
               ud.Fibre_Low = 1
               AND f.Fibre_value_g_per_100g >= 5
           )

        OR (
               ud.Carb_Low = 1
               AND f.Carb_value_g_per_100g >= 20
           )

        OR (
               ud.Fat_High = 1
               AND f.Fat_value_g_per_100g <= 10
           )

        OR (
               ud.Calories_High = 1
               AND f.Calories_kcal_per_100g <= 200
           )
),

Food_Count AS
(
    SELECT
        User_ID,
        COUNT(*) AS total_foods
    FROM Food_Pool
    GROUP BY User_ID
)

SELECT

    CONCAT(
        'P',
        ud.User_ID,
        '_D',
        d.plan_day,
        '_',
        REPLACE(m.meal_type, ' ', '')
    ) AS plan_id,

    ud.User_ID AS user_id,

    d.plan_day,

    m.meal_type,

    fp.Food_ID AS food_id,

    100 AS quantity,

    fp.reason

FROM User_Deficiency ud

CROSS JOIN Days d

CROSS JOIN Meal_Types m

JOIN Food_Count fc
    ON ud.User_ID = fc.User_ID

JOIN Food_Pool fp
    ON ud.User_ID = fp.User_ID

WHERE
    fp.food_rank =
    (
        MOD(
            (d.plan_day - 1) * 5
            +
            CASE m.meal_type
                WHEN 'Breakfast' THEN 1
                WHEN 'Mid Snack' THEN 2
                WHEN 'Lunch' THEN 3
                WHEN 'Evening Snack' THEN 4
                WHEN 'Dinner' THEN 5
            END
            - 1,
            fc.total_foods
        ) + 1
    );