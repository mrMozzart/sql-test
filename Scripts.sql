--1.1--
 /*
  Вывести все дублирующиеся записи из таблицы RPM_FUTURE_RETAIL 
  (комбинация полей item/location/action_date должна быть уникальна).
 */
SELECT rfr.ITEM, rfr.LOCATION, rfr.ACTION_DATE
FROM RPM_FUTURE_RETAIL rfr
GROUP BY rfr.ITEM, rfr.LOCATION, rfr.ACTION_DATE 
HAVING count(*) > 1

--1.2--
 /*
  Написать скрипт для удаления из RPM_FUTURE_RETAIL дубликатов
  (должна остаться запись с максимальным selling_retail), 
  найденные в предыдущем задании (при необходимости можно использовать несколько SQL инструкций).
 */

DELETE 
FROM RPM_FUTURE_RETAIL rfr
WHERE  rfr.ITEM || rfr.LOCATION || rfr.ACTION_DATE IN (SELECT rfr.ITEM || rfr.LOCATION || rfr.ACTION_DATE 
													  FROM RPM_FUTURE_RETAIL rfr1
													  GROUP BY rfr1.ITEM, rfr1.LOCATION, rfr1.ACTION_DATE 
													  HAVING count(*) > 1)
AND rfr.ITEM || rfr.LOCATION || rfr.ACTION_DATE || rfr.selling_retail NOT IN (SELECT rfr2.ITEM || rfr2.LOCATION || rfr2.ACTION_DATE || MAX(rfr2.selling_retail) 
													  						 FROM RPM_FUTURE_RETAIL rfr2
													  						 GROUP BY rfr2.ITEM, rfr2.LOCATION, rfr2.ACTION_DATE 
													  						 HAVING count(*) > 1);  

--1.3--
 /*
  Вывести все комбинации товар/магазин где товар имеет цену на уровне магазина, 
  но при этом вообще не имеет цены на уровне зоны, к которой привязан магазин.
*/
													  						
SELECT DISTINCT rfr.ITEM,rfr.LOCATION 
FROM RPM_FUTURE_RETAIL rfr 
WHERE rfr.SELLING_RETAIL IS NOT NULL 
AND rfr.ITEM NOT IN (SELECT DISTINCT ITEM
                 	 FROM RPM_ZONE_FUTURE_RETAIL rzfr
                 	 LEFT JOIN RPM_ZONE_LOCATION rzl ON rzfr.ZONE = rzl.ZONE_ID 
                 	 WHERE rfr.LOCATION = rzl.LOCATION)

--1.4--
  /*
   Вывести количество уникальных товаров в каждом магазине, которые имеют цену на уровне магазина, 
   но при этом не имеет цену на уровне зоны, к которой привязан магазин.
 */ 

SELECT tab.LOCATION, COUNT(tab.ITEM)
FROM
    (SELECT DISTINCT rfr.ITEM,rfr.LOCATION 
    FROM RPM_FUTURE_RETAIL rfr 
    WHERE rfr.SELLING_RETAIL IS NOT NULL 
    AND rfr.ITEM NOT IN (SELECT DISTINCT ITEM
                     	 FROM RPM_ZONE_FUTURE_RETAIL rzfr
                     	 LEFT JOIN RPM_ZONE_LOCATION rzl ON rzfr.ZONE = rzl.ZONE_ID 
                     	 WHERE rfr.LOCATION = rzl.LOCATION)
    ) tab
GROUP BY tab.LOCATION

--2.1--
 /*
 Написать SQL запрос, который покажет сколько дней цена на товар оставалась неизменной (в первой ценовой зоне). 
 Информацию предоставить в следующем виде:
 */
SELECT 	ITEM, 
		ZONE, 
		f_date, 
		selling_retail,
		NVL(l_date,TO_DATE('07.12.2017')) - f_date days
FROM (
	SELECT 	rzfr.ITEM,  
			rzfr.ZONE, 
			rzfr.ACTION_DATE f_date, 
			lead(rzfr.ACTION_DATE) OVER (PARTITION BY rzfr.ITEM ORDER BY rzfr.ACTION_DATE) l_date, 
			rzfr.SELLING_RETAIL
	FROM RPM_ZONE_FUTURE_RETAIL rzfr 
	WHERE rzfr.ZONE = 1
	ORDER BY item, ACTION_DATE
	) tab

	--2.2--
	/*
	Написать update, который позволит выравнять цены на текущую дату в системе 
	в таблице RPM_FUTURE_RETAIL используя цену на уровне ценовой зоны.
	*/
/*
WITH tab AS
(
	SELECT rfr.ITEM, rfr.ACTION_DATE, rzfr.ACTION_DATE, rfr.SELLING_RETAIL, rzfr.SELLING_RETAIL 
	FROM RPM_FUTURE_RETAIL rfr
	JOIN RPM_ZONE_LOCATION rzl ON rfr.LOCATION = rzl.LOCATION 
	JOIN RPM_ZONE_FUTURE_RETAIL rzfr ON rfr.ITEM = rzfr.ITEM AND rzl.ZONE_ID = rzfr."ZONE" 
	WHERE rfr.ACTION_DATE = TO_DATE('') 
)
*/

--3.1--
/*
Написать insert, который заполнит цену на первое число каждого месяца для товара '050374500' 
в первой ценовой зоне за период с 01.05.2017 – 01.03.2018 (информацию о цене брать из таблицы RPM_ZONE_FUTURE_RETAIL)
*/
CREATE TABLE ITEM_ZONE_PRICE (ZONE number(2), ITEM varchar2(20), m_DATE date, PRICE number(10,4));
INSERT INTO ITEM_ZONE_PRICE (ZONE, ITEM, M_DATE, PRICE)
WITH in_dates AS 
(
	 SELECT TO_DATE('01.05.2017') f_date, 
	 		TO_DATE('01.03.2018') l_date 
	 FROM dual
),
array_dates AS
(
	SELECT TRUNC(ADD_MONTHS(f_date, level-1), 'mm') m_date
	FROM in_dates
	CONNECT BY level-1 <= MONTHS_BETWEEN(l_date, f_date)
),
periods_cost AS
(
	SELECT RZFR.ZONE ZONE,
		   rzfr.ACTION_DATE f_date, 
		   NVL(lead(rzfr.ACTION_DATE) OVER (PARTITION BY rzfr.ITEM ORDER BY rzfr.ACTION_DATE),sysdate) l_date,
		   rzfr.ITEM item,
		   RZFR.SELLING_RETAIL price
	FROM RPM_ZONE_FUTURE_RETAIL rzfr 
	WHERE RZFR.item = '050374500' AND RZFR.ZONE = 1
),
costs AS 
(
	SELECT  
			pc.ZONE,
			ad.m_date m_date,
			NVL(pc.item,'050374500') item,
			pc.price price
	FROM array_dates ad
	LEFT JOIN periods_cost pc ON ad.m_date >= pc.f_date AND ad.m_date <= pc.l_date
)
SELECT ZONE, ITEM, M_DATE, PRICE FROM costs;

SELECT * FROM ITEM_ZONE_PRICE;