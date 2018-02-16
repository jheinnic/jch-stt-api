// USING PERIODIC COMMIT

LOAD CSV WITH HEADERS FROM "file:/players.csv" AS row
RETURN row.player_id, row.dbid, row.character_id;

LOAD CSV WITH HEADERS FROM "file:/players.csv" AS row
MERGE (player:Player {id: row.dbid, player_id: row.player_id, character_id: row.character_id})
MERGE (player)-[i:IMPORTED {timestamp: 1}]->(snap:PlayerSnapshot {id: row.dbid, player_id: row.player_id, character_id: row.character_id, timestamp: 1})
ON CREATE SET snap.display_name = row.character_display_name, snap.level = row.level, snap.xp = row.xp;
