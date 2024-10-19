SELECT *
FROM public.app_store_apps;

SELECT * 
FROM public.play_store_apps;



--App store calculated price sorted by rating
SELECT DISTINCT
    price,name,rating,review_count,
    CASE 
        WHEN price <= 1 THEN 10000
        WHEN price > 1 THEN 10000 * price
        ELSE NULL
    END AS calculated_price
FROM 
    public.app_store_apps
GROUP BY name, price, rating,review_count
ORDER BY rating DESC;

--Removing the dollar sign
SELECT 
    REPLACE(price, '$', '') AS Result
FROM 
    public.play_store_apps
ORDER BY price ASC;

--Original Formula
SELECT 
    price,name,rating
	REPLACE(price, '$', '') AS Result
    CASE WHEN price <= 1 THEN 10000
        WHEN price > 1 THEN 10000 * price
        ELSE NULL
    END AS calculated_price
FROM 
    public.play_store_apps
GROUP BY name, price, rating
ORDER BY rating DESC;

--Play store calculated price
SELECT 
    CAST(REPLACE(play_store_apps.price, '$', '') AS NUMERIC) AS price_numeric,
   app_store_apps.name,
	app_store_apps.review_count,
 app_store_apps. rating,
    CASE 
        WHEN CAST(REPLACE(play_store_apps.price, '$', '') AS NUMERIC) <= 1 THEN 10000
        WHEN CAST(REPLACE(play_store_apps.price, '$', '') AS NUMERIC) > 1 THEN 10000 * CAST(REPLACE(play_store_apps.price, '$', '') AS NUMERIC)
        ELSE NULL
    END AS calculated_price
FROM app_store_apps
INNER JOIN play_store_apps
ON app_store_apps.name=play_store_apps.name
--WHERE  CAST(REPLACE(play_store_apps.price, '$', '') AS NUMERIC) IS NOT NULL
--GROUP BY name, price,rating,review_count
ORDER BY rating DESC;




SELECT 
    CAST(REPLACE(price, '$', '') AS NUMERIC) AS price_numeric,
    name,
	review_count,
    rating,
    CASE 
        WHEN CAST(REPLACE(price, '$', '') AS NUMERIC) <= 1 THEN 10000
        WHEN CAST(REPLACE(price, '$', '') AS NUMERIC) > 1 THEN 10000 * CAST(REPLACE(price, '$', '') AS NUMERIC)
        ELSE NULL
    END AS calculated_price
FROM 
    public.play_store_apps
--GROUP BY name, price,rating,review_count
ORDER BY rating DESC;



SELECT 
    price,name,rating,review_count,
    CASE 
        WHEN price <= 1 THEN 10000
        WHEN price > 1 THEN 10000 * price
        ELSE NULL
    END AS calculated_price
FROM 
    public.app_store_apps
GROUP BY name, price, rating,review_count
ORDER BY rating DESC;



WITH play_store_corr AS (
	SELECT name, REPLACE(REPLACE(play_store_apps.price,'$',''),' ','')::numeric AS price_trimmed, rating
	FROM play_store_apps
),
prices_and_ratings AS (
	SELECT name, price, rating
	FROM app_store_apps
	UNION
	SELECT name, price_trimmed AS price, rating
	FROM play_store_corr
	ORDER BY name
 ),
cost_and_lifetime AS(
	SELECT name
		,	CASE WHEN MAX(price) < 1 THEN 10000
			ELSE MAX(price)*10000 END AS purchase_cost
		,	CASE WHEN ROUND(AVG(rating)*2)+1 IS NULL then 1
			ELSE ROUND(AVG(rating)*2)+1 END AS lifetime
	FROM prices_and_ratings
	GROUP BY name
	ORDER BY purchase_cost DESC
),
annual_revenue AS(
	SELECT name
		,	CASE WHEN app.price IS NOT NULL AND play.price_trimmed IS NOT NULL THEN 108000
				WHEN app.price IS NULL OR play.price_trimmed IS NULL THEN 48000
				END as annual_revenue
	FROM app_store_apps AS app
		FULL OUTER JOIN play_store_corr AS play
			USING (name)
	ORDER BY name
),
total_revenue AS(
SELECT DISTINCT name
	,	ann.annual_revenue
	,	cost.lifetime
	,	cost.purchase_cost
	,	(ann.annual_revenue*cost.lifetime)-cost.purchase_cost as total_revenue
FROM annual_revenue AS ann
	FULL OUTER JOIN cost_and_lifetime AS cost
		USING (name)
ORDER BY total_revenue DESC
)
SELECT DISTINCT name, app.price, play.price, total.lifetime, app.content_rating, play.content_rating, app.primary_genre, play.genres, play.size, play.rating, app.review_count,total.total_revenue
FROM total_revenue AS total
	FULL OUTER JOIN app_store_apps AS app
		USING (name)
	FULL OUTER JOIN play_store_apps AS play
		USING (name)
ORDER BY total.total_revenue DESC
LIMIT 10;




WITH play_store_corr AS (
	SELECT name, REPLACE(REPLACE(play_store_apps.price,'$',''),' ','')::numeric AS price_trimmed, rating
	FROM play_store_apps
),
prices_and_ratings AS (
	SELECT name, price, rating
	FROM app_store_apps
	UNION
	SELECT name, price_trimmed AS price, rating
	FROM play_store_corr
	ORDER BY name
 ),
cost_and_lifetime AS(
	SELECT name
		,	CASE WHEN MAX(price) < 1 THEN 10000
			ELSE MAX(price)*10000 END AS purchase_cost
		,	CASE WHEN ROUND(AVG(rating)*2)+1 IS NULL then 1
			ELSE ROUND(AVG(rating)*2)+1 END AS lifetime
	FROM prices_and_ratings
	GROUP BY name
	ORDER BY purchase_cost DESC
),
annual_revenue AS(
	SELECT name
		,	CASE WHEN app.price IS NOT NULL AND play.price_trimmed IS NOT NULL THEN 108000
				WHEN app.price IS NULL OR play.price_trimmed IS NULL THEN 48000
				END as annual_revenue
	FROM app_store_apps AS app
		FULL OUTER JOIN play_store_corr AS play
			USING (name)
	ORDER BY name
),
total_revenue AS(
SELECT DISTINCT name
	,	ann.annual_revenue
	,	cost.lifetime
	,	cost.purchase_cost
	,	(ann.annual_revenue*cost.lifetime)-cost.purchase_cost as total_revenue
FROM annual_revenue AS ann
	FULL OUTER JOIN cost_and_lifetime AS cost
		USING (name)
ORDER BY total_revenue DESC
)
SELECT DISTINCT name, app.price, play.price, total.lifetime, app.content_rating, play.content_rating, app.primary_genre, play.genres, play.size, play.rating, app.review_count,total.total_revenue
FROM total_revenue AS total
	FULL OUTER JOIN app_store_apps AS app
		USING (name)
	FULL OUTER JOIN play_store_apps AS play
		USING (name)
ORDER BY total.total_revenue DESC
LIMIT 50;




SELECT 
    CAST(REPLACE(play.price, '$', '') AS NUMERIC) AS price_numeric,
   app.name,
	app.review_count,
 app.rating,
 app.price,
    CASE 
        WHEN CAST(REPLACE(play.price, '$', '') AS NUMERIC) <= 1 THEN 10000
        WHEN CAST(REPLACE(play.price, '$', '') AS NUMERIC) > 1 THEN 10000 * CAST(REPLACE(play.price, '$', '') AS NUMERIC)
        ELSE NULL
    END AS calculated_price
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
ON app.name=play.name
--WHERE  CAST(REPLACE(play.price, '$', '') AS NUMERIC) IS NOT NULL
--GROUP BY name, price,rating,review_count
ORDER BY review_count DESC; fff





