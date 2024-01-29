use retail_events_db;

select * from dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;


ALTER TABLE fact_events
CHANGE COLUMN `quantity_sold(before_promo)` `quantity_sold_before_promo` varchar(50);

ALTER TABLE fact_events
CHANGE COLUMN `quantity_sold(after_promo)` `quantity_sold_after_promo` varchar(50);



SELECT
    dp.product_code,
    dp.product_name,
    dp.category,
    fe.base_price,
    fe.promo_type
FROM
    dim_products dp
JOIN
    fact_events fe ON dp.product_code = fe.product_code
WHERE
    fe.base_price > 500
    AND fe.promo_type = 'BOGOF';
    
-- Here retrieve information about products meeting the specified conditions, 
-- including their product code, name, category, base price, and promo type. 
-- The result set will contain rows where the base price is greater than 500 and the promo type is 'BOGOF'.    
    
    
==================================================================================

SELECT
    city,
    COUNT(DISTINCT store_id) AS store_count
FROM
    dim_stores
GROUP BY
    city
ORDER BY
    store_count DESC;
    
-- The query will provide a list of cities along with the count of distinct 
-- stores in each city, sorted by the store count in descending order.    
    
========================================================================

SELECT
    dc.campaign_name,
      ROUND(SUM(fe.base_price * fe.quantity_sold_before_promo) / 1000000, 2) AS total_revenue_before_promotion,
      ROUND(SUM(fe.base_price * fe.quantity_sold_after_promo) / 1000000, 2) AS total_revenue_after_promotion
FROM
    dim_campaigns dc
JOIN
    fact_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY
    dc.campaign_name;
    
    
-- The query will provide a report with campaign names, total revenue before promotion, 
-- and total revenue after promotion, displayed in millions and rounded to 2 decimal places.    
============================================================   


SELECT
    category,
    ISU_percentage,
    RANK() OVER (ORDER BY ISU_percentage DESC) AS rank_order
FROM (
    SELECT
        dp.category,
        ROUND(
            ((SUM(fe.quantity_sold_after_promo) - SUM(fe.quantity_sold_before_promo)) / SUM(fe.quantity_sold_before_promo)) * 100,
            2
        ) AS ISU_percentage
    FROM
        dim_products dp
    JOIN
        fact_events fe ON dp.product_code = fe.product_code
    JOIN
        dim_campaigns dc ON fe.campaign_id = dc.campaign_id
    WHERE
        dc.campaign_name = 'Diwali'
    GROUP BY
        dp.category
) AS subquery
ORDER BY
    ISU_percentage DESC;
    
-- In this query we extract the category, ISU_percentage, and rank order for each 
-- category during the Diwali campaign. The rank order is based on the ISU_percentage, allowing you 
-- to identify the categories with the most significant impact on incremental sales during the campaign.   
    
    
============================================================================================

SELECT
    dp.product_name,
    dp.category,
    ROUND(
        ((SUM(fe.base_price * fe.quantity_sold_after_promo) - SUM(fe.base_price * fe.quantity_sold_before_promo)) / SUM(fe.base_price * fe.quantity_sold_before_promo)) * 100,
        2
    ) AS IR_percentage
FROM
    dim_products dp
JOIN
    fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.product_name, dp.category
ORDER BY
    IR_percentage DESC
LIMIT 5;

-- The query will provide a report with the top 5 products, ranked by Incremental Revenue Percentage, across all campaigns.
    



