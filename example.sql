SELECT name, artist, text FROM card_fts.card

-- On recherche le mot 'Wall' dans la colonne name
SELECT name, artist, text FROM card_fts.card
WHERE to_tsvector(name) @@ to_tsquery('Wall');

-- On peut recherche un terme sur plusieurs colonnes (name et text)
SELECT name, artist, text FROM card_fts.card
WHERE to_tsvector(name || ' ' || text) @@ to_tsquery('Wall');

-- On peut étendre cela sur autant de colonnes qu'on le souhaite
SELECT name, artist, text FROM card_fts.card
WHERE to_tsvector(name || ' ' || artist || ' ' || text) @@ to_tsquery('Avon');


-- Meilleurs PERF
-- jusqu'à présent, on a indexé (ou vectorisé) les colonnes à la volée,
-- ce qui n'est pas le plus performant, en particulier si la base est conséquente

-- on va ajouter une colonne de type 'tsvector'
ALTER TABLE card_fts.card ADD COLUMN document tsvector;
UPDATE card_fts.card SET document = to_tsvector(name || ' ' || artist || ' ' || text);

--  ce qui permet de requêter directement le champ
SELECT name, artist, text from card_fts.card
where document @@ to_tsquery('Avon');

-- on peut comparer les temps d'exécution de cette façon:
explain analyze select name, artist, text from card_fts.card where to_tsvector(name || ' ' || artist || ' ' || text) @@ to_tsquery('Avon');

explain analyze select name, artist, text from card_fts.card where document @@ to_tsquery('Avon');



ALTER TABLE card_fts.card ADD COLUMN document_with_idx tsvector;
UPDATE card_fts.card set document_with_idx = to_tsvector(name || ' ' || artist || ' ' || coalesce(text, ''));
CREATE INDEX document_idx ON card_fts.card USING GIN (document_with_idx);

  explain analyze select name, artist, text
                  from card_fts.card
                  where document @@ to_tsquery('Avon');
  explain analyze select name, artist, text
                  from card_fts.card
                  where document_with_idx @@ to_tsquery('Avon');


-- On va maintenant vouloir évaluer nos items grâce à ts_rank
select name, artist, text from card_fts.card
where document_with_idx @@ plainto_tsquery('island')
order by ts_rank(document_with_idx, plainto_tsquery('island'));


ALTER TABLE card_fts.card ADD COLUMN document_with_weights tsvector;

UPDATE card_fts.card
  SET document_with_weights = setweight(to_tsvector(name), 'A') ||
    setweight(to_tsvector(artist), 'B') ||
      setweight(to_tsvector(coalesce(text, '')), 'C');
CREATE INDEX document_weights_idx ON card_fts.card USING GIN (document_with_weights);

select name, artist, text from card_fts.card
where document_with_weights @@ plainto_tsquery('island')
order by ts_rank(document_with_weights, plainto_tsquery('island')) desc;

select name, artist, text, ts_rank(document_with_weights, plainto_tsquery('island')) from card_fts.card
where document_with_weights @@ plainto_tsquery('island')
order by ts_rank(document_with_weights, plainto_tsquery('island')) desc;


CREATE FUNCTION card_tsvector_trigger() RETURNS trigger AS $$
begin
  new.document :=
  setweight(to_tsvector('english', coalesce(new.name, '')), 'A')
  || setweight(to_tsvector('english', coalesce(new.artist, '')), 'B')
  || setweight(to_tsvector('english', coalesce(new.text, '')), 'C');
  return new;
end
$$ LANGUAGE plpgsql;


CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON card_fts.card FOR EACH ROW EXECUTE PROCEDURE card_tsvector_trigger();