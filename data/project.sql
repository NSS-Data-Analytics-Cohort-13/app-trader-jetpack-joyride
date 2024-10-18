SELECT *
FROM app_store_apps

SELECT * 
FROM play_store_apps 

SELECT 
  apple_store.name,
  CASE 
  WHEN  apple_store.price <=1.00 THEN 10000
  ELSE apple_store.price *10000
  END AS purchase_price 
  FROM app_store_apps AS apple_store
  UNION 
  SELECT 
  Play_store.name,
  CASE
  WHEN CAST(TRIM(REPLACE(play_store.price,'$','')) AS DECIMAL)<=1.00 THEN 10000
  ELSE CAST(TRIM(REPLACE(play_store.price,'$',''))AS DECIMAL)*10000
  END AS purchase_price 
  FROM play_store_apps AS play_store
  ORDER BY purchase_price DESC;


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
SELECT DISTINCT name, total.lifetime, app.content_rating, play.content_rating, app.primary_genre, play.genres, total.total_revenue
FROM total_revenue AS total
	FULL OUTER JOIN app_store_apps AS app
		USING (name)
	FULL OUTER JOIN play_store_apps AS play
		USING (name)
ORDER BY total.total_revenue DESC
LIMIT 10;