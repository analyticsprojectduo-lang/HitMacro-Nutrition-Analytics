SELECT
    fl.User_ID,
    u.Name,

    YEAR(fl.Date_Time) AS year_no,
    MONTH(fl.Date_Time) AS month_no,

    DATE_FORMAT(fl.Date_Time, '%Y-%m') AS month,

    ROUND(SUM(fl.Total_Calories_kcal), 2) AS actual_calories,
    ROUND(
        u.Daily_Calorie_Target
        * COUNT(DISTINCT DATE(fl.Date_Time)),
        2
    ) AS calorie_target,

    ROUND(SUM(fl.Total_Protein_g), 2) AS actual_protein,
    ROUND(
        u.Daily_Protein_Target_g
        * COUNT(DISTINCT DATE(fl.Date_Time)),
        2
    ) AS protein_target,

    ROUND(SUM(fl.Total_Carb_g), 2) AS actual_carbs,
    ROUND(
        u.Daily_Carb_Target_g
        * COUNT(DISTINCT DATE(fl.Date_Time)),
        2
    ) AS carb_target,

    ROUND(SUM(fl.Total_Fat_g), 2) AS actual_fat,
    ROUND(
        u.Daily_Fat_Target_g
        * COUNT(DISTINCT DATE(fl.Date_Time)),
        2
    ) AS fat_target,

    ROUND(SUM(fl.Total_Fibre_g), 2) AS actual_fibre,
    ROUND(
        u.Daily_Fibre_Target_g
        * COUNT(DISTINCT DATE(fl.Date_Time)),
        2
    ) AS fibre_target,

    CASE
        WHEN SUM(fl.Total_Calories_kcal)
                <= u.Daily_Calorie_Target
                   * COUNT(DISTINCT DATE(fl.Date_Time))
         AND SUM(fl.Total_Protein_g)
                >= u.Daily_Protein_Target_g
                   * COUNT(DISTINCT DATE(fl.Date_Time))
         AND SUM(fl.Total_Carb_g)
                >= u.Daily_Carb_Target_g
                   * COUNT(DISTINCT DATE(fl.Date_Time))
         AND SUM(fl.Total_Fat_g)
                <= u.Daily_Fat_Target_g
                   * COUNT(DISTINCT DATE(fl.Date_Time))
         AND SUM(fl.Total_Fibre_g)
                >= u.Daily_Fibre_Target_g
                   * COUNT(DISTINCT DATE(fl.Date_Time))
        THEN 'Achieved'

        ELSE 'Not Achieved'
    END AS monthly_target_status

FROM Food_Log fl

JOIN Users u
    ON fl.User_ID = u.User_ID

GROUP BY
    fl.User_ID,
    u.Name,
    YEAR(fl.Date_Time),
    MONTH(fl.Date_Time),
    DATE_FORMAT(fl.Date_Time, '%Y-%m'),
    u.Daily_Calorie_Target,
    u.Daily_Protein_Target_g,
    u.Daily_Carb_Target_g,
    u.Daily_Fat_Target_g,
    u.Daily_Fibre_Target_g

ORDER BY
    fl.User_ID,
    year_no,
    month_no;