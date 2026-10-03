SELECT
    fl.User_ID,
    u.Name,
    DATE(fl.Date_Time) AS summary_date,

    ROUND(SUM(fl.Total_Calories_kcal), 2) AS total_calories,
    u.Daily_Calorie_Target,

    ROUND(SUM(fl.Total_Protein_g), 2) AS total_protein,
    u.Daily_Protein_Target_g,

    ROUND(SUM(fl.Total_Carb_g), 2) AS total_carbs,
    u.Daily_Carb_Target_g,

    ROUND(SUM(fl.Total_Fat_g), 2) AS total_fat,
    u.Daily_Fat_Target_g,

    ROUND(SUM(fl.Total_Fibre_g), 2) AS total_fibre,
    u.Daily_Fibre_Target_g

FROM Food_Log fl

JOIN Users u
    ON fl.User_ID = u.User_ID

GROUP BY
    fl.User_ID,
    u.Name,
    u.Daily_Calorie_Target,
    u.Daily_Protein_Target_g,
    u.Daily_Carb_Target_g,
    u.Daily_Fat_Target_g,
    u.Daily_Fibre_Target_g,
    DATE(fl.Date_Time)

ORDER BY
    fl.User_ID,
    summary_date;