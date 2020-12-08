Basé sur la vidéo : https://www.youtube.com/watch?v=szfUbzsKvtE

Build du conteneur
```bash
docker-compose up --build
```

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