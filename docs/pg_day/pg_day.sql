-- Identifier les lexèmes d'un document:
select to_tsvector('french', 'le meilleur SGBD Opensource') as lexèmes;
-- on obtient : 'meilleur':2 'opensourc':4 'sgbd':3

-- 2 mots peuvent retourner le même lexèmes:
select to_tsvector('french', 'animal animaux') as lexèmes;
-- retourne : 'animal':1,2


-- Identifier des tokens
select alias,description,token from ts_debug('Maif France contact@maif.fr http://maif.fr/about.html')


-- Comment interroger un tsvector?

-- Type TSQUERY
-- Comprend les lexèmes recherchés qui peuvent être combinés avec les opérateurs suivants :
-- & (AND)
-- | (OR)
-- ! (NOT)
-- L'opérateur de recherche de phrase (depuis la 9.6): <-> (FOLLOWED BY)

-- Ex: on génère une requête sur 2 lexèmes
select 'chat & chien'::tsquery;

-- OPERATEUR @@
-- permet d'interroger un tsvector
-- ici on recherche si 'chat' est bien contenu dans la représentation vectorielle de 'chat chien'
select to_tsvector('chat chien') @@ 'chat'::tsquery; -- true
select to_tsvector('chat chien') @@ 'chat & chien'::tsquery; -- true

-- OPERATEUR @@ (bis)

select to_tsvector('french', 'cheval poney') @@ 'cheval'::tsquery; -- true

select to_tsvector('french', 'cheval poney') @@ 'chevaux'::tsquery; -- false -- WTF?????

-- Pourquoi chevaux ne fonctionne pas alors que si on recheche le lexème de chevaux, on trouve bien cheval??
select to_tsquery('french', 'chevaux'); -- cheval

-- Dans les 2 premières requêtes, on compare un mot à un lexème, ça ne marche pas comme ça :(
-- on doit réfléchir en terme de lexème, on va utiliser la fonction to_tsquery pour nous aider


-- FONCTION TO_TSQUERY
-- Transforme une chaîne de texte en tsquery composée de lexèmes

select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'chevaux'); -- cette fois on a bien true


-- Quelques exemples:
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'chevaux & chat'); -- false
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'chevaux | chat'); -- true
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', '!chat'); -- true

-- + complexe:
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'aux:*'); -- false
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'chev:*'); -- true
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'chev:* & pon:*'); -- true
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', '(chev:* & tet:*) | (chev:* & pon:*)'); -- true
--select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', '(9796332b:* & 9796332d:*) | (9796332d:*) | (9796330k:*)');


-- PLAINTO_TSQUERY
-- Convertit une chaîne de text en tsquery

select to_tsvector('french', 'cheval poney') @@ to_tsquery('french', 'chevaux & poney'); -- true
-- est équivalent à:
select to_tsvector('french', 'cheval poney') @@ plainto_tsquery('french', 'chevaux poney'); -- true
-- on considère que l'espace est équivalent au &, donc:
select to_tsvector('french', 'cheval poney') @@ plainto_tsquery('french', 'chevaux chat'); -- false
