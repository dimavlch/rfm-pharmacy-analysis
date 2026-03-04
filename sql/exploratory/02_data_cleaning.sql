-- сколько валидных карт и сколько "мусорных"

SELECT 
    CASE 
        WHEN card ~ '^[0-9]{13}$' THEN 'normal'
        ELSE 'uuid_garbage'
    END as card_type,
    COUNT(DISTINCT card) as unique_cards,
    COUNT(*) as transactions,
    SUM(summ) as total_revenue
FROM bonuscheques
GROUP BY 1;

-- как выглядят "мусорные"

SELECT card, COUNT(*) as cnt
FROM bonuscheques 
WHERE card !~ '^[0-9]{13}$'
   OR card IS NULL
GROUP BY card
ORDER BY cnt DESC
LIMIT 20;

-- Итоговая статистика 

SELECT 
    MIN(datetime) as first_date,
    MAX(datetime) as last_date,
    COUNT(*) as total_rows,
    COUNT(DISTINCT card) as unique_cards
FROM bonuscheques;