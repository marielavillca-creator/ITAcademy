USE store;
SET GLOBAL LOCAL_INFILE=1;
-- usuarios
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    region VARCHAR(20)
);

-- cargado de amercanos
LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/PRACTICAS ANALIST DE DATOS/CURSO_MYSQL/SPRINT 4/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
id, name, surname, phone, email,
birth_date, country, city, postal_code, address
)
SET region = 'America';

-- cargada de europeos
LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/PRACTICAS ANALIST DE DATOS/CURSO_MYSQL/SPRINT 4/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
id, name, surname, phone, email,
birth_date, country, city, postal_code, address
)
SET region = 'Europe';

SELECT * FROM users;
-- limpieza
UPDATE users
SET birth_date = CASE
    WHEN birth_date LIKE '%,%' 
        THEN STR_TO_DATE(birth_date, '%b %d, %Y')
    WHEN birth_date LIKE '%-%' 
        THEN STR_TO_DATE(birth_date, '%d-%b-%y')
    ELSE NULL
END;

-- companies
DROP TABLE IF EXISTS companies;
CREATE TABLE companies (
    company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(100)
);
LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/PRACTICAS ANALIST DE DATOS/CURSO_MYSQL/SPRINT 4/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- credit_cards tabla estructura
DROP TABLE IF EXISTS credit_cards;
CREATE TABLE credit_cards (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(10),
    cvv VARCHAR(10),
    track1 TEXT,
    track2 TEXT,
    expiring_date VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- carga de datos a credit cards
LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/PRACTICAS ANALIST DE DATOS/CURSO_MYSQL/SPRINT 4/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- limpieza de credit_cards
UPDATE credit_cards
SET expiring_date = CASE
    WHEN expiring_date LIKE '%/%/%'
        THEN STR_TO_DATE(expiring_date, '%m/%d/%y')
    WHEN expiring_date LIKE '%-%'
        THEN STR_TO_DATE(expiring_date, '%m-%y')
    ELSE NULL
END;
-- produts
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price VARCHAR(20),
    colour VARCHAR(20),
    weight VARCHAR(20),
    warehouse_id VARCHAR(20)
);

LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/PRACTICAS ANALIST DE DATOS/CURSO_MYSQL/SPRINT 4/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- limpieza
UPDATE products
SET 
    price = REPLACE(price, '$', ''),
    weight = REPLACE(weight, 'kg', '');
--    transactions
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp VARCHAR(50),
    amount VARCHAR(50),
    declined VARCHAR(10),
    product_ids VARCHAR(255), 
    user_id INT,
    lat VARCHAR(50),
    longitude VARCHAR(50),
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- carga de datos transactions
LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/PRACTICAS ANALIST DE DATOS/CURSO_MYSQL/SPRINT 4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- limpieza de trtansactions
UPDATE transactions
SET 
    timestamp = CASE
        WHEN timestamp LIKE '%-%-% %:%:%'
            THEN STR_TO_DATE(timestamp, '%Y-%m-%d %H:%i:%s')
        WHEN timestamp LIKE '%/%/% %:%'
            THEN STR_TO_DATE(timestamp, '%d/%m/%Y %H:%i')
        ELSE NULL
    END,
    amount = REPLACE(amount, '$', ''),
    declined = CASE
        WHEN declined IN ('1','true','TRUE') THEN 1
        ELSE 0
    END;
SELECT * FROM transactions;
    -- ejercicio 1 nivel 1
    -- Realice una subconsulta que muestre a todos los usuarios 
    -- con más de 80 transacciones utilizando al menos 2 tablas.
SELECT 
    u.id,
    u.name,
    u.surname,
    COUNT(t.id) AS total_transactions
FROM users u
JOIN transactions t ON u.id = t.user_id
GROUP BY u.id, u.name, u.surname
HAVING COUNT(t.id) > 80;
-- Muestra el monto promedio del propietario de una tarjeta de 
-- crédito IBAN en Donec Ltd, utiliza al menos 2 tablas.
SELECT 
    c.company_name,
    cc.iban,
    AVG(t.amount) AS avg_amount
FROM transactions t
JOIN credit_cards cc ON t.card_id = cc.id
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY  cc.iban;

-- nivel 2: Cree una nueva tabla que refleje el estado de las tarjetas de crédito
--  según Si las últimas tres transacciones han sido rechazadas, entonces está inactivo;
--  si al menos una no es rechazada, entonces está activa. Comenzando en esta tabla, responde:
-- Ejercicio 1 ¿Cuántas cartas están activas?

CREATE TABLE card_status AS
WITH ranked AS (
    SELECT
        t.card_id,
        t.declined,
        t.timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY t.card_id
            ORDER BY t.timestamp DESC
        ) AS rn
    FROM transactions t
),
last_3 AS (
    SELECT *
    FROM ranked
    WHERE rn <= 3
)
SELECT
    card_id,
    CASE
        WHEN SUM(declined) = 3 THEN 'inactive'
        ELSE 'active'
    END AS status
FROM last_3
GROUP BY card_id;

SELECT COUNT(*) AS active_cards
FROM card_status
WHERE status = 'active';

-- nivel 3: Crea una tabla con la que podamos adjuntar los datos del nuevo archivo products.csv 
-- con la base de datos creada, dado que desde la transacción tienes product_ids. Genera la siguiente consulta:
-- Ejercicio 1: Necesitamos saber el número de veces que se ha vendido cada producto.
CREATE TABLE transaction_products (
    transaction_id VARCHAR(50),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id)
);
INSERT INTO transaction_products (transaction_id, product_id)
SELECT 
    t.id,
    jt.product_id
FROM transactions t,
JSON_TABLE(
    CONCAT('[', t.product_ids, ']'),
    "$[*]" COLUMNS(product_id INT PATH "$")
) AS jt;
SELECT
    p.id,
    p.product_name,
    COUNT(tp.product_id) AS times_sold
FROM transaction_products tp
JOIN products p ON p.id = tp.product_id
GROUP BY p.id, p.product_name
ORDER BY times_sold DESC;