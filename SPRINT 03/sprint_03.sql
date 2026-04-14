USE marketplace;

DROP TABLE IF EXISTS credit_card;
CREATE TABLE credit_card (
id VARCHAR (20),
iban VARCHAR (50),
pan VARCHAR (30),
pin VARCHAR (10),
cvv VARCHAR (10),
expiring_date VARCHAR (20)
);


SELECT credit_card_id
FROM transaction
WHERE credit_card_id NOT IN (
    SELECT id FROM credit_card
);

ALTER TABLE transaction
MODIFY credit_card_id VARCHAR(20);

DELETE FROM transaction
WHERE credit_card_id NOT IN (
    SELECT id FROM credit_card
);
ALTER TABLE credit_card
ADD PRIMARY KEY (id);

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);
-- El Departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado
-- a la tarjeta de crédito con ID CcU-2938. La información que se mostrará para este registro es:
-- TR323456312213576817699999. Recuerde demostrar que el cambio se realizó.
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';


INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO transaction (
    id,
    credit_card_id,
    company_id,
    user_id,
    lat,
    longitude,
    timestamp,
    amount,
    declined
) VALUES (
    '108B1D1D-5B23-A76C-55EF-C568E49A99DD',
    'CcU-9999',
    'b-9999',
    9999,
    829.999,
    -117.999,
    NOW(),
    111.11,
    0
);

SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';
-- Ejercicio 4 Desde recursos humanos se le solicita que elimine 
-- la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.
ALTER TABLE credit_card
DROP COLUMN pan;
DESCRIBE credit_card;

-- Nivel 2: Ejercicio 1 Elimine de la tabla de transacciones el 
-- registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';


-- Ejercicio 2 La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. Se ha
--  solicitado una opinión para proporcionar detalles clave sobre las empresas y sus transacciones. Necesitará crear una vista llamada 
-- VistaMarketing que contenga la siguiente información: Nombre de la empresa. Teléfono de contacto. País de residencia. Compra media 
-- realizada por cada empresa. Presenta la vista creada, ordenando datos desde mayor a menor compra promedio.

CREATE  OR REPLACE VIEW VistaMarketing AS
SELECT 
    c.company_name,
    c.phone,
    c.country,
    ROUND(AVG(t.amount),2) AS media_compra
FROM company c
JOIN transaction t 
ON c.id = t.company_id
GROUP BY c.id;

SELECT *
FROM VistaMarketing
ORDER BY media_compra DESC;
-- Ejercicio 3 Filtre la vista VistaMarketing para mostrar solo las empresas que tienen su país de residencia en "Alemania"
SELECT *
FROM VistaMarketing
WHERE country = 'Germany';



-- nivel 3 ejercicio 1
-- -- Modificar tabla user
ALTER TABLE user 
MODIFY id INT;
RENAME TABLE user TO data_user;
ALTER TABLE data_user 
CHANGE email personal_email VARCHAR(150);
-- modificar tabla company
ALTER TABLE company
DROP column website;

-- Modificar tabla credit_card

ALTER TABLE credit_card 
MODIFY cvv INT;
ALTER TABLE credit_card 
MODIFY pin VARCHAR(4);

ALTER TABLE credit_card 
DROP COLUMN fecha_actual;

ALTER TABLE credit_card 
ADD fecha_actual DATE DEFAULT(NOW());

-- Modificar tabla transaction

ALTER TABLE `transaction`
MODIFY credit_card_id VARCHAR(20);


-- ejercicio 2 nivel 3

CREATE OR REPLACE VIEW ReportTecnico AS
SELECT
    t.id AS transaction_id,
    u.name AS user_name,
    u.surname AS user_surname,
    c.iban AS credit_card_iban,
    comp.company_name AS company_name
FROM transaction t
JOIN data_user u ON t.user_id = u.id
JOIN credit_card c ON t.credit_card_id = c.id
JOIN company comp ON t.company_id = comp.id;
SELECT *
FROM ReportTecnico
ORDER BY transaction_id DESC;

SELECT * FROM ReportTecnico;



















