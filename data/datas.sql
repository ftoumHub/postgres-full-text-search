-- create our card_fts schema
CREATE SCHEMA card_fts;

-- lets create our table for cards
CREATE TABLE card_fts.card(name varchar(50), artist varchar(256), text TEXT);

-- now we need to import our CSV file into this table.
-- luckily Postgres makes this super easy
COPY card_fts.card FROM '/data/10E.csv' DELIMITER ';' CSV;

SELECT count(*) FROM card_fts.card c;