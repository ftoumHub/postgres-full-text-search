Démarrer le conteneur et exécuter des commandes
```bash
docker-compose up --remove-orphans -d

docker exec -it pg_fts bash
```
Connection à la BD Postgresql
```bash
-- enter a psql session as the user 'postgres'
psql -U postgres

-- let's list out our databases
\l

-- cool.  let's connect to our pg_fts database
\connect pg_fts

-- create our card_fts schema
CREATE schema card_fts;

-- lets create our table for cards
CREATE TABLE card_fts.card(name varchar(50), artist varchar(256), text TEXT);

-- now we need to import our CSV file into this table.
-- luckily Postgres makes this super easy
COPY card_fts.card FROM '/data/10E.csv' DELIMITER ';' CSV;

-- Done!  now lets execute some SQL queries
select count(*) from card_fts.card;
 count 
-------
   384
(1 row)
```

Quitter psql:
```bash
\q
```

Sortir du conteneur:
```bash
exit
```

```bash
docker-compose stop

docker-compose rm -f
```