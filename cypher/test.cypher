LOAD CSV WITH HEADERS FROM "file:/foo.csv" AS outer
WITH outer
LOAD CSV WITH HEADERS FROM "file:/bar.csv" AS inner
WITH outer, inner
WHERE inner.owner = outer.id
RETURN outer.id, inner.id, inner.color;

LOAD CSV WITH HEADERS FROM "file:/foo.csv" AS outer
LOAD CSV WITH HEADERS FROM "file:/bar.csv" AS inner
WITH outer, inner
WHERE inner.owner = outer.id
RETURN outer.id, inner.id, inner.color;

LOAD CSV WITH HEADERS FROM "file:/foo.csv" AS outer
LOAD CSV WITH HEADERS FROM "file:/bar.csv" AS inner
WITH inner, outer
WHERE inner.owner = outer.id
RETURN outer.id, inner.id, inner.color;

LOAD CSV WITH HEADERS FROM "file:/bar.csv" AS inner
WITH inner
ORDER BY inner.color ASC
LOAD CSV WITH HEADERS FROM "file:/foo.csv" AS outer
WITH outer, inner
ORDER BY outer.id ASC
WHERE inner.owner = outer.id
RETURN outer.id, inner.id, inner.color;

LOAD CSV WITH HEADERS FROM "file:/bar.csv" AS inner
WITH DISTINCT inner.owner
RETURN inner.owner
