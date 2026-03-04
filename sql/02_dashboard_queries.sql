--- KPI карточки ---


-- всего клиентов

SELECT COUNT(*) as "Всего клиентов" 
FROM {{#12909-rfm-analiz}} rfm -- на основе модели данных rfm-анализа
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
;



-- общая выручка

SELECT SUM(monetary) as "Общая выручка, руб" 
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
;

-- средний чек

SELECT 
    ROUND(SUM(monetary) / NULLIF(SUM(frequency), 0)) as "Средний чек, руб"
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
;

-- средняя частота покупок на одного человека за анализируемый период

SELECT ROUND(AVG(frequency), 1) as "Средняя частота покупок" 
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]

;

--- Визуализации ---

-- барчарт: распределение по выручке

SELECT 
    segment,
    SUM(monetary) as revenue
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
GROUP BY segment
ORDER BY revenue DESC
;

-- линейный график: динамика новых клиентов по месяцам

SELECT 
    DATE_TRUNC('month', last_purchase_date) as month,
    COUNT(*) as new_clients
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
GROUP BY month
ORDER BY month
;

-- горизонтальный барчарт: кол-во клиентов по сегменту

SELECT 
    segment,
    COUNT(*) as "Клиентов"
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
GROUP BY segment
ORDER BY "Клиентов" DESC
;

-- таблица: детализация по сегментам

SELECT 
    segment AS "Сегмент",
    COUNT(*) as "Клиенты",
    SUM(monetary) as "Выручка",
    ROUND(AVG(monetary)) as "Средний чек",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) / 100 as "% клиентов", 
    ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER(), 1) / 100 as "% выручки"  
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
GROUP BY 1
ORDER BY "Выручка" DESC

;

--- Вторая страница дашборда ---

-- ТОП100 клиентов по выручке

SELECT 
    client_id as "Клиент",
    last_purchase_date as "Дата последней покупки",
    recency_days as "Дней с последней покупки",
    frequency as "Всего покупок",
    monetary as "Сумма, руб",
    rfm_code as "RFM-код"
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND segment = {{segment}}]]
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
ORDER BY monetary DESC
LIMIT 100
;

-- матрица rfm: клиенты

SELECT 
    r_score AS "R",
    f_score AS "F",
    COUNT(*) as "Кол-во клиентов"
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND segment = {{segment}}]]
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
GROUP BY r_score, f_score
ORDER BY r_score DESC, f_score DESC
;

-- матрица rfm: средний чек

SELECT 
    r_score AS "R",
    f_score AS "F",
    ROUND(AVG(monetary)) as "Средний чек, руб"
FROM {{#12909-rfm-analiz}} rfm
WHERE True
  [[AND segment = {{segment}}]]
  [[AND last_purchase_date >= {{date_from}}]]
  [[AND last_purchase_date <= {{date_to}}]]
GROUP BY r_score, f_score
ORDER BY r_score DESC, f_score DESC
