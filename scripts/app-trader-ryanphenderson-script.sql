-- Purchase cost = 10,000 * max price
-- Each app earns 5000/month, or 60,000/year, per store
-- Each app costs 1000/month, or 12,000/year, in advertising. 
-- 0.5 rating = 1 year expected lifespan. Expected lifespan = rating * 2
-- ((-(60000* # of stores)12000)2*rating)-(10000*max price) = total expected revenue
-- Required: 
	-- Count of stores
	-- Average ratings rounded to nearest 0.5
	-- Max price over both stores
-- Output column layout
	-- name | count_of_stores | annual_revenue | lifetime | purchase_cost | total_revenue
	-- name: App name
	-- count_of_stores: 1 or 2
	-- annual_revenue: ((60000*count_of_stores)-12000)
	-- lifetime: 2 * average rating over both stores, rounded to nearest 0.5
	-- purchase_cost: 10000*max price, where max price => 1. If max price <1, purchase cost is 10000.
	-- total_revenue: (annual_revenue*lifetime)-purchase_cost
WITH play_store_corr AS (
	SELECT name, REPLACE(REPLACE(play_store_apps.price,'$',''),' ','')::money AS price_trimmed
	FROM play_store_apps
)
SELECT DISTINCT name
	,	(CASE
		WHEN app_store_apps.price IS NOT NULL AND play_store_apps.price IS NOT NULL THEN 120000-12000
		WHEN app_store_apps.price IS NULL OR play_store_apps.price IS NULL THEN 60000-12000
		END) as annual_revenue		-- Annual revenue
	,	(CASE
		WHEN app_store_apps.price::MONEY < 1::money AND play_store_corr.price_trimmed < 1::money THEN 10000::money
		ELSE (CASE
			WHEN app_store_apps.price::money > play_store_corr.price_trimmed THEN (app_store_apps.price * 10000)::money
			WHEN app_store_apps.price::money < play_store_corr.price_trimmed THEN (play_store_corr.price_trimmed*10000)
			END)
		END) AS purchase_cost		-- Max price * 10000
FROM app_store_apps
	FULL OUTER JOIN play_store_apps
		USING (name)
	INNER JOIN play_store_corr
		USING (name)
ORDER BY annual_revenue DESC

