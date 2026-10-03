/*SET SQL_SAFE_UPDATES = 0;*/

/*1.
Display user acheived or not acheived target
Tables can be used user,daily summary
*/
/*2.if not acheived what could have improved on day wise*/
SELECT 
    u.user_id,
    u.name,
    t.target_date,

    CASE 
        WHEN d.Total_Calories_kcal_perday <= u.Daily_Calorie_Target
         AND d.Total_Protein_g_perday >= u.Daily_Protein_Target_g
         AND d.Total_Carb_g_perday >= u.Daily_Carb_Target_g
         AND d.Total_Fat_g_perday <= u.Daily_Fat_Target_g
        THEN 'Achieved'
        ELSE 'Not Achieved'
    END AS achievement_status,

    CASE
        WHEN d.Total_Calories_kcal_perday <= u.Daily_Calorie_Target
         AND d.Total_Protein_g_perday >= u.Daily_Protein_Target_g
         AND d.Total_Carb_g_perday >= u.Daily_Carb_Target_g
         AND d.Total_Fat_g_perday <= u.Daily_Fat_Target_g
        THEN 'Target achieved'
        
        ELSE CONCAT_WS(' + ',

            CASE 
                WHEN d.Total_Calories_kcal_perday > u.Daily_Calorie_Target
                THEN CONCAT(
                    'Calories high (',
                    ROUND(
                        d.Total_Calories_kcal_perday - u.Daily_Calorie_Target,
                        2
                    ),
                    ' kcal above target)'
                )
            END,

            CASE 
                WHEN d.Total_Protein_g_perday < u.Daily_Protein_Target_g
                THEN CONCAT(
                    'Protein low (',
                    ROUND(
                        u.Daily_Protein_Target_g - d.Total_Protein_g_perday,
                        2
                    ),
                    'g below target)'
                )
            END,

            CASE 
                WHEN d.Total_Carb_g_perday < u.Daily_Carb_Target_g
                THEN CONCAT(
                    'Carbs low (',
                    ROUND(
                        u.Daily_Carb_Target_g - d.Total_Carb_g_perday,
                        2
                    ),
                    'g below target)'
                )
            END,

            CASE 
                WHEN d.Total_Fat_g_perday > u.Daily_Fat_Target_g
                THEN CONCAT(
                    'Fat high (',
                    ROUND(
                        d.Total_Fat_g_perday - u.Daily_Fat_Target_g,
                        2
                    ),
                    'g above target)'
                )
            END

        )
    END AS reason,

    CASE
        WHEN d.Total_Calories_kcal_perday <= u.Daily_Calorie_Target
         AND d.Total_Protein_g_perday >= u.Daily_Protein_Target_g
         AND d.Total_Carb_g_perday >= u.Daily_Carb_Target_g
         AND d.Total_Fat_g_perday <= u.Daily_Fat_Target_g
        THEN 'No improvement required'

        ELSE CONCAT_WS(' + ',

            CASE 
                WHEN d.Total_Calories_kcal_perday > u.Daily_Calorie_Target
                THEN 'Reduce high-calorie foods'
            END,

            CASE 
                WHEN d.Total_Protein_g_perday < u.Daily_Protein_Target_g
                THEN 'Increase protein-rich foods'
            END,

            CASE 
                WHEN d.Total_Carb_g_perday < u.Daily_Carb_Target_g
                THEN 'Include more healthy carbohydrate sources'
            END,

            CASE 
                WHEN d.Total_Fat_g_perday > u.Daily_Fat_Target_g
                THEN 'Reduce high-fat foods'
            END

        )
    END AS improvement

FROM Users u

JOIN Daily_Summary d 
    ON u.user_id = d.user_id

JOIN Target_analysis t 
    ON u.user_id = t.user_id

WHERE d.date = t.target_date;

