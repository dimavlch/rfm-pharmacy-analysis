WITH rfm_raw AS (
    SELECT 
        card,
        MAX(datetime) as last_purchase_date,
        COUNT(*) as frequency,
        SUM(summ) as monetary,
        EXTRACT(DAY FROM '2022-06-09'::timestamp - MAX(datetime)::timestamp) as recency_days
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
),
rfm_scores AS (
    SELECT 
        card as client_id,
        recency_days,
        frequency,
        monetary,
        last_purchase_date,
        CASE 
            WHEN recency_days <= 29 THEN 3
            WHEN recency_days <= 86 THEN 2
            ELSE 1
        END as r_score,
        CASE 
            WHEN frequency >= 4 THEN 3
            WHEN frequency >= 2 THEN 2
            ELSE 1
        END as f_score,
        CASE 
            WHEN monetary >= 3316 THEN 3
            WHEN monetary >= 730 THEN 2
            ELSE 1
        END as m_score
    FROM rfm_raw
)
SELECT 
    client_id,
    recency_days,
    frequency,
    monetary,
    last_purchase_date,
    r_score,
    f_score,
    m_score,
    (r_score::text || f_score::text || m_score::text) as rfm_code,
    
    CASE 
        WHEN r_score = 3 AND f_score = 3 AND m_score >= 2 THEN 'VIP'
        
        WHEN r_score >= 2 AND f_score = 3 AND m_score >= 2 THEN 'Лояльные'
        
        WHEN r_score = 3 AND f_score <= 2 AND m_score <= 2 THEN 'Новички'
        
        WHEN r_score = 1 AND f_score = 3 AND m_score >= 2 THEN 'Уходящие'
        
        WHEN r_score = 1 AND f_score <= 2 AND m_score = 1 THEN 'Спящие'
        
        ELSE 'Массовые'
    END as segment
    
FROM rfm_scores
ORDER BY monetary DESC