-- Recency 

WITH last_purchase AS (
    SELECT 
        card,
        EXTRACT(DAY FROM '2022-06-09'::timestamp - MAX(datetime)::timestamp) as recency_days
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
)
SELECT 
    MIN(recency_days) as min_rec,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY recency_days) as p25_rec,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY recency_days) as median_rec,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY recency_days) as p75_rec,
    MAX(recency_days) as max_rec,
    AVG(recency_days) as avg_rec
FROM last_purchase;

-- Frequency

WITH freq AS (
    SELECT card, COUNT(*) as frequency
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
)
SELECT 
    MIN(frequency) as min_freq,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY frequency) as p25_freq,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY frequency) as median_freq,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY frequency) as p75_freq,
    MAX(frequency) as max_freq,
    AVG(frequency) as avg_freq,
    COUNT(*) as total_customers
FROM freq;

-- Monetary 

WITH monetary AS (
    SELECT card, SUM(summ) as total_sum
    FROM bonuscheques 
    WHERE card ~ '^[0-9]{13}$'
    GROUP BY card
)
SELECT 
    MIN(total_sum) as min_mon,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_sum) as p25_mon,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_sum) as median_mon,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_sum) as p75_mon,
    MAX(total_sum) as max_mon,
    AVG(total_sum) as avg_mon,
    COUNT(*) as total_customers
FROM monetary