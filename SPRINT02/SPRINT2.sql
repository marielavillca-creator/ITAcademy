USE transactions;
SHOW TABLES;
DESCRIBE company;
DESCRIBE transaction;
SELECT * FROM company LIMIT 10;
SELECT * FROM transaction LIMIT 10;
SHOW CREATE TABLE company;
SHOW CREATE TABLE transaction;

-- Muestra las características principales del esquema creado y explica las 
-- diferentes tablas y variables que existen. Asegúrate de incluir un diagrama que
-- ilustre la relación entre las distintas tablas y variables.
SHOW TABLES;
DESCRIBE company;
DESCRIBE transaction;
SELECT * FROM company LIMIT 10;
SELECT * FROM transaction LIMIT 10;

-- Usando JOIN realizarás las siguientes consultas:
-- Listado de países que están generando ventas.
-- A partir de cuántos países se generan las ventas.
-- Identifica la empresa con mayor promedio de ventas.
 
SELECT DISTINCT c.country
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

SELECT COUNT(DISTINCT c.country) AS paisescon_fact
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;


SELECT c.company_name,ROUND(AVG(t.amount) ,2)AS promedio
FROM company c
JOIN transaction t on c.id = t.company_id
WHERE t.declined = 0
group by c.company_name
ORDER BY promedio DESC
LIMIT 1;

-- Ejercicio 3 Usando solo subconsultas (sin usar JOIN):
-- Muestra todas las transacciones realizadas por empresas en Alemania.
-- Enumere las empresas que han realizado transacciones por parte de un propietario superiores al promedio de todas las transacciones.
-- Eliminarán del sistema las empresas que no tengan transacciones registradas, entregarán el listado de estas empresas.

SELECT *
FROM transaction t
WHERE company_id IN ( SELECT id
					  FROM company
                      WHERE country = 'Germany'
);

						
SELECT company_name
FROM company
WHERE id IN ( SELECT company_id
			  FROM transaction
              WHERE amount > ( SELECT AVG (amount) 
							   FROM transaction
              )
);                       

SELECT *
FROM company
WHERE id NOT IN (
    SELECT DISTINCT company_id FROM transaction
);

-- Nivel 2
-- Ejercicio 1
-- Identifica los cinco días en los que se generó la mayor cantidad de ingresos en la empresa 
-- por ventas. Muestra la fecha de cada transacción junto con las ventas totales.

SELECT DATE(timestamp) AS fecha, ROUND(SUM(amount),2) AS  suma_total
FROM transaction t
WHERE declined = 0
GROUP BY  DATE(timestamp)
ORDER BY SUM(amount) DESC
limit 5;

-- Ejercicio 2
-- ¿Cuáles son las ventas promedio por país? Presenta los resultados ordenados de mayor a menor medio.
SELECT c.country, ROUND(AVG(amount),2) AS promedio
FROM 	company c
JOIN transaction t ON c.id = t.company_id
WHERE declined =0
GROUP BY country
ORDER BY AVG(amount) DESC;

-- Ejercicio 3
-- En su empresa se propone un nuevo proyecto para lanzar algunas campañas publicitarias para
-- competir en la empresa “Non Institute”. Para ello, le solicitan el listado de todas las 
-- transacciones realizadas por empresas que se encuentran ubicadas en el mismo país que esta empresa.
-- Muestra la lista aplicando JOIN y subconsultas.
-- Muestra la lista aplicando únicamente subconsultas.

SELECT c.country, t.timestamp,t.amount
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE c.country = ( SELECT country
				  FROM company 
                  WHERE company_name = 'Non Institute'           
);

-- transaction_id, company_id, amount, timestamp
SELECT *
FROM transaction 
WHERE company_id IN ( SELECT id
					FROM company
                    WHERE country IN ( SELECT country
									  FROM company 
                                      WHERE company_name = 'Non Institute' 
									)
);

-- Nivel 3
-- Ejercicio 1
-- Presenta el nombre, teléfono, país, fecha y propietario, de aquellas empresas que realizaron 
-- operaciones con un valor comprendido entre 350 y 400 euros y en cualquiera de estas 
-- fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordene los resultados de más a menos.
SELECT  c.company_name, c.phone, c.country, t.amount, date(timestamp) AS fecha
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE amount BETWEEN 350 AND 400 AND DATE(timestamp) IN ('2015-04-29','2018-07-20','2024-03-13')
ORDER BY amount DESC;

-- Ejercicio 2
-- Necesitamos optimizar la asignación de recursos y dependerá de la capacidad operativa requerida,
-- por eso te piden información sobre la cantidad de transacciones que realizan las empresas, pero 
-- el departamento de recursos humanos es exigente y quiere un listado de empresas donde especifiques 
-- si tienen más de 400 transacciones o menos.

-- cantidad de transacciones por empresa, q tengan mas de 400 transaaciones o menos

SELECT company_name,COUNT(*) AS total_trans,
   CASE
      WHEN COUNT(*) > 400 THEN 'mas de 400'
	  ELSE 'menos de 400' 
   END AS categoria
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined =0
GROUP BY c.id, company_name;

