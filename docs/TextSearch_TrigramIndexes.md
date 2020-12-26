https://medium.com/@sukorenomw/when-to-use-postgresql-full-text-search-and-trigram-indexes-4c7c36223421

ALTER TABLE card_fts.card ADD COLUMN document tsvector;

UPDATE card_fts.card SET document = to_tsvector(name || ' ' || artist || ' ' || text);


select * from card_fts.card where document @@ to_tsquery('Avon');

select * from card_fts.card where document @@ to_tsquery('von');

select * from card_fts.card where document @@ to_tsquery('von:*');


select show_trgm('avn');

select * from card_fts.card where similarity(artist, 'avn') > 0.1 order by similarity(artist, 'avn') desc;





select * from card_fts.card c 

explain analyze select name, artist, text from card_fts.card where to_tsvector(name || ' ' || artist || ' ' || text) @@ to_tsquery('Avon');

explain analyze select name, artist, text from card_fts.card where document @@ to_tsquery('Avon');

## Full Text Search

FTS is powerful enough to achieve advanced data searching especially when we want to search the data based 
on several column, but there is a problem for particular case, the words in full text search are broken up 
according to the rules defined by the language of the text. For example, PostgreSQL converting ```“Ayana Long 
Dress”``` to a text vector results in the values ```'ayana'```, ```'dress'``` and ```'long'``` This means 
that searching for ```'ayana'```, ```'dress'``` and ```'long'``` will match the data, but searching for 
```'ong'``` or ```'yana'``` will not. This is problematic when you don’t know exactly what you’re looking 
for, for example when you’re looking for a product name but only know part of its word.

## Trigram Indexes

One of benefits using PostgreSQL is they has some extra solution: trigram indexes. Trigram indexes work by 
breaking up text in trigrams. Trigrams are basically words broken up into sequences of 3 letters. For example, 
the trigram for “hello” would be: ```'hel', 'ell', 'llo'```

You need to enable the pg_trgm extension in order to use trigram indexes on PostgreSQL. This extension adds 
a few functions, operators, and support for trigram indexes (using GIN or GiST indexes to be exact). We can 
use the following query to see what trigrams PostgreSQL can produce:

```sql
SELECT show_trgm('hello');
```

This following query will generate trigrams of ‘hello’:
```
           show_trgm            
---------------------------------
 {"  h"," he",ell,hel,llo,"lo "}
```