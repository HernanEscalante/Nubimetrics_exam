-- Ejercicio 6
SELECT 
	c.country
	, AVG(s.TaxRate) AS tax_rate_avg
FROM sales.SalesTaxRate AS s
INNER JOIN  
(
	SELECT 
		sp.StateProvinceID
		, cr.name AS country
	FROM person.StateProvince AS sp
	INNER JOIN person.CountryRegion AS cr
	ON sp.CountryRegionCode = cr.CountryRegionCode
) AS c
ON s.StateProvinceID = c.StateProvinceID
GROUP BY c.country

-- Ejercicio 7

WITH cte AS 
(
	SELECT
		ToCurrencyCode AS country_code
		, ROUND(EndOfDayRate, 2) AS rate
		, ROW_NUMBER() OVER(PARTITION BY FromCurrencyCode, ToCurrencyCode ORDER BY EndOfDayRate DESC) AS rn
	FROM sales.CurrencyRate
)
SELECT country, currency, rate, ROUND(AVG(TaxRate), 2) AS average_tax_rate 
FROM 
(
	SELECT 
		country
		, currency
		, rate
		, TaxRate 
	FROM cte
	JOIN
	(
		SELECT 
			 CurrencyCode
			, p.country
			, str.TaxRate
			, p.currency
		FROM sales.SalesTaxRate AS str
		JOIN
		(
			SELECT
				cr.*
				, crc.CurrencyCode 
				, crc.currency
			FROM 
			(
				SELECT
					sp.StateProvinceID
					, cr.CountryRegionCode
					, cr.Name AS country
				FROM Person.CountryRegion AS cr
				JOIN Person.StateProvince AS sp
				ON cr.CountryRegionCode = sp.CountryRegionCode
			) AS cr
			JOIN 
			(
				SELECT 
					x.*
					, y.Name AS currency
				FROM sales.CountryRegionCurrency x
				JOIN sales.Currency y
				ON x.CurrencyCode = y.CurrencyCode
			) AS crc
			ON cr.CountryRegionCode = crc.CountryRegionCode	
		) AS p
		ON str.StateProvinceID = p.StateProvinceID
	) AS x
	ON cte.country_code = x.CurrencyCode
	WHERE rn = 1
) AS mean
GROUP BY country, currency, rate