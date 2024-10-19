SELECT app_store_apps AS Apple_Name, play_store_apps AS Play_Name, 
	CASE WHEN (app_store_apps.price > 1.00) THEN (app_store_apps.price*10,000) 
	END AS apple_purchase_price
FROM app_store_apps
LEFT JOIN play_store_apps USING(name)
ORDER BY name;





SELECT    DISTINCT ON (name) name
      ,     MAX(PRICE) as price
      ,     COUNT(name)*5000 AS profit_per_month
      ,     COUNT(DISTINCT name)*1000 AS cost_per_month
      ,     CAST((ROUND(AVG(rating)*2.0)/2.0)*2 +1 AS DECIMAL(5,2)) AS expected_life
      ,     CASE WHEN COUNT(name) > 1 THEN 'Y' ELSE 'N' END AS available_in_both_stores
      ,     MAX(genre) AS genre
FROM
(
SELECT      DISTINCT ON (name) name
      ,     MAX(CASE WHEN price = '0.00' THEN 10000 else CEILING(price)*10000 END) AS Price
      ,     AVG(rating) AS rating
      ,     MAX(primary_genre) AS genre
FROM app_store_apps
GROUP BY name
UNION ALL
SELECT      DISTINCT ON (name) name
      ,     MAX(CASE WHEN CAST(REPLACE(price, '$', '')AS NUMERIC) = 0 THEN 10000 
                  ELSE CEILING(CAST(REPLACE(price, '$','')AS NUMERIC))*10000 END) AS price
      ,     AVG(rating)
      ,     MAX(genres)
FROM play_store_apps
GROUP BY name)
GROUP BY name;


    SELECT app.name, 
    app.price as app_price,
    play.price as play_price, 
    app.rating as app_rating, 
    play.rating as play_rating
    FROM app_store_apps as app
    LEFT JOIN play_store_apps as play
    ON app.name = play.name;


    SELECT *
	FROM app_store_apps


	SELECT *
	FROM play_store_apps
	