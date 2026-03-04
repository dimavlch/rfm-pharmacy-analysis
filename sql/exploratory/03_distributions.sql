-- Распределение Recency 

WITH last_purchase AS (
    SELECT 
        card,
        EXTRACT(DAY FROM '2022-06-09'::timestamp - MAX(datetime)::timestamp) as recency_days
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
)
SELECT 
    CASE 
        WHEN recency_days <= 30 THEN '0-30 дней'
        WHEN recency_days <= 60 THEN '31-60 дней'
        WHEN recency_days <= 90 THEN '61-90 дней'
        WHEN recency_days <= 180 THEN '91-180 дней'
        ELSE 'более 180 дней'
    END as recency_group,
    COUNT(*) as client_count
FROM last_purchase
GROUP BY recency_group
ORDER BY MIN(recency_days);

-- Распределение Frequency

SELECT 
    frequency,
    COUNT(*) as client_count
FROM (
    SELECT card, COUNT(*) as frequency
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
) t
GROUP BY frequency
ORDER BY frequency;

-- Распределение Monetary 

WITH monetary AS (
    SELECT card, SUM(summ) as total_sum
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
)
SELECT 
    CASE 
        WHEN total_sum <= 500 THEN '0-500'
        WHEN total_sum <= 1000 THEN '501-1000'
        WHEN total_sum <= 3000 THEN '1001-3000'
        WHEN total_sum <= 5000 THEN '3001-5000'
        WHEN total_sum <= 10000 THEN '5001-10000'
        ELSE 'более 10000'
    END as monetary_group,
    COUNT(*) as client_count
FROM monetary
GROUP BY monetary_group
ORDER BY MIN(total_sum);