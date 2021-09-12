--1.1--
 /*
  Вывести все дублирующиеся записи из таблицы RPM_FUTURE_RETAIL 
  (комбинация полей item/location/action_date должна быть уникальна).
 */
SELECT rfr.ITEM, rfr.LOCATION, rfr.ACTION_DATE
FROM RPM_FUTURE_RETAIL rfr
GROUP BY rfr.ITEM, rfr.LOCATION, rfr.ACTION_DATE 
HAVING count(rfr.ITEM) > 1

--1.2--
 /*
  Написать скрипт для удаления из RPM_FUTURE_RETAIL дубликатов
  (должна остаться запись с максимальным selling_retail), 
  найденные в предыдущем задании (при необходимости можно использовать несколько SQL инструкций).
 */
WITH TAB AS 
(SELECT rfr.ITEM || rfr.LOCATION || rfr.ACTION_DATE str, MAX(RFR.selling_retail) selling_retail
FROM RPM_FUTURE_RETAIL rfr
GROUP BY rfr.ITEM, rfr.LOCATION, rfr.ACTION_DATE 
HAVING count(rfr.ITEM) > 1)

DELETE 
FROM RPM_FUTURE_RETAIL rfr
WHERE  rfr.ITEM || rfr.LOCATION || rfr.ACTION_DATE = (SELECT tab.str FROM tab) 
AND NOT rfr.ITEM || rfr.LOCATION || rfr.ACTION_DATE || RFR.selling_retail = (SELECT tab.str || tab.selling_retail FROM tab);  

--1.3--
 /*
  Вывести все комбинации товар/магазин где товар имеет цену на уровне магазина, 
  но при этом вообще не имеет цены на уровне зоны, к которой привязан магазин.
 
SELECT DISTINCT rfr.ITEM,rfr.LOCATION 
FROM RPM_FUTURE_RETAIL rfr 
WHERE rfr.SELLING_RETAIL IS NOT NULL AND rfr.ITEM IN (SELECT DISTINCT ITEM
                                                      FROM RPM_ZONE_FUTURE_RETAIL rzfr
                                                      JOIN RPM_ZONE_LOCATION rzl ON rzfr.ZONE = rzl.ZONE_ID 
                                                      WHERE rzfr.SELLING_RETAIL IS NULL AND rfr.LOCATION = rzl.LOCATION)
*/
--1.4--
  /*
   Вывести количество уникальных товаров в каждом магазине, которые имеют цену на уровне магазина, 
   но при этом не имеет цену на уровне зоны, к которой привязан магазин.
  

SELECT tab.LOCATION, COUNT(tab.ITEM)
FROM
    (SELECT DISTINCT rfr.ITEM,rfr.LOCATION 
    FROM RPM_FUTURE_RETAIL rfr 
    WHERE rfr.SELLING_RETAIL IS NOT NULL AND rfr.ITEM IN (SELECT DISTINCT ITEM
                                                          FROM RPM_ZONE_FUTURE_RETAIL rzfr
                                                          JOIN RPM_ZONE_LOCATION rzl ON rzfr.ZONE = rzl.ZONE_ID 
                                                          WHERE rzfr.SELLING_RETAIL IS NULL AND rfr.LOCATION = rzl.LOCATION)
    ) tab
GROUP BY tab.LOCATION
*/
--2.1--
 /*
 Написать SQL запрос, который покажет сколько дней цена на товар оставалась неизменной (в первой ценовой зоне). 
 Информацию предоставить в следующем виде:
 */
