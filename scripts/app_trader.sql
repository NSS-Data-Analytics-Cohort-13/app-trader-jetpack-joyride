SELECT app_store_apps AS Apple_Name, play_store_apps AS Play_Name, 
	CASE WHEN (app_store_apps.price > 1.00) THEN (app_store_apps.price*10,000) 
	END AS apple_purchase_price
FROM app_store_apps
LEFT JOIN play_store_apps USING(name)
ORDER BY name;






    SELECT *
	FROM app_store_apps


	SELECT *
	FROM play_store_apps



   SELECT DISTINCT(name),
   MAX(price) as price,
   COUNT(name)*5000 as profitPerMonth,
   COUNT(DISTINCT name)*1000 as costPerMonth,
   CAST((ROUND(AVG(rating)*2.0)/2.0)*2 +1 as decimal(5,2)) as avg_rating
   ,CASE WHEN COUNT(name) > 1 THEN 'y' ELSE 'n' END AS availableInBothStores
   
   FROM
   (
   SELECT DISTINCT(name),
   CASE WHEN price = '0.00' THEN 10000 ELSE CEILING(price)*10000 END AS price,rating
  
   FROM app_store_apps
   UNION
  SELECT DISTINCT(name),
  CASE WHEN CAST(REPLACE(price,'$','') as numeric) = 0 THEN 10000 ELSE
  CEILING(CAST(REPLACE(price,'$','') as numeric))*10000 END AS price, rating
  
  FROM play_store_apps)
  GROUP BY name;








	WITH play_store_corr AS (
	SELECT name, REPLACE(REPLACE(play_store_apps.price,'$',''),' ','')::numeric AS price_trimmed, rating, review_count
	FROM play_store_apps
),
prices_and_ratings AS (
	SELECT name, price, rating, review_count::integer
	FROM app_store_apps
	UNION
	SELECT name, price_trimmed AS price, rating, review_count
	FROM play_store_corr
	ORDER BY name
 ),
cost_and_lifetime AS(
	SELECT name
		,	CASE WHEN MAX(price) < 1 THEN 10000
			ELSE MAX(price)*10000 END AS purchase_cost
		,	CASE WHEN ROUND(AVG(rating)*2)+1 IS NULL then 1
			ELSE ROUND(AVG(rating)*2)+1 END AS lifetime
		,	SUM(review_count) as total_reviews
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
	,	cost.total_reviews
	,	(ann.annual_revenue*cost.lifetime)-cost.purchase_cost as total_revenue
FROM annual_revenue AS ann
	FULL OUTER JOIN cost_and_lifetime AS cost
		USING (name)
ORDER BY total_revenue DESC
)
SELECT DISTINCT name, total.total_reviews, play.install_count as play_store_installs, total.lifetime, app.content_rating, play.content_rating, app.primary_genre, play.genres, total.total_revenue
FROM total_revenue AS total
	FULL OUTER JOIN app_store_apps AS app
		USING (name)
	FULL OUTER JOIN play_store_apps AS play
		USING (name)
ORDER BY total.total_revenue DESC
LIMIT 10;