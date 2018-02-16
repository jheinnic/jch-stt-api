// USING PERIODIC COMMIT

LOAD CSV WITH HEADERS FROM "file:/players.csv" AS row
MERGE (player:Player {id: row.dbid, player_id: row.player_id, character_id: row.character_id})
MERGE (player)-[i:IMPORTED {timestamp: 1}]->(snap:PlayerSnapshot {id: row.dbid, player_id: row.player_id, character_id: row.character_id, timestamp: 1})
ON CREATE SET snap.display_name = row.character_display_name, snap.level = row.level, snap.xp = row.xp;


// WITH player, snap, row.character_id AS owner_id
// LOAD CSV WITH HEADERS FROM "file:/crew_instance_stats.csv" AS row
// MERGE (crewIdent: CrewIdent {id: row.symbol})
// ON CREATE SET crewIdent.name = row.name, crewIdent.short_name = row.short_name, crewIdent.max_rarity = row.max_rarity
// MERGE (lvl:CrewLevel {id: row.symbol, level: row.level, rarity: row.rarity})-[:IS_LEVEL_FOR]->(crewIdent)
// ON CREATE SET lvl.cmd_core = row.cmd_core, lvl.cmd_rmin = row.cmd_rmin, lvl.cmd_rmax = row.cmd_rmax, lvl.dip_core = row.dip_core, lvl.dip_rmin = row.dip_rmin, lvl.dip_rmax = row.dip_rmax, lvl.eng_core = row.eng_core, lvl.eng_rmin = row.eng_rmin, lvl.eng_rmax = row.eng_rmax, lvl.sec_core = row.sec_core, lvl.sec_rmin = row.sec_rmin, lvl.sec_rmax = row.sec_rmax, lvl.med_core = row.med_core, lvl.med_rmin = row.med_rmin, lvl.med_rmax = row.med_rmax, lvl.sci_core = row.sci_core, lvl.sci_rmin = row.sci_rmin, lvl.sci_rmax = row.sci_rmax
// MERGE (snap)-[e:ENLISTED {timestamp: 1}]->(own_crew: CrewInstance {id: row.crew_id})-[:HAS_LEVEL]->(lvl)
// 
// ON CREATE SET own_crew.level = row.level, own_crew.symbol = row.symbol, own_crew.rarity = row.rarity
// RETURN player, snap, lvl, own_crew;
// 
// 
// LOAD CSV WITH HEADERS FROM "file:/crew_instance_stats.csv" AS row
// MATCH (crewIdent {id: row.symbol})
// MERGE (trait:Trait {id: trait_name, name: trait_name})
// MERGE (crewIdent)-[:HAS_TRAIT]->(trait);

// WITH crewIdent, row, row.traits as row_traits
// UNWIND split(row_traits, ';') as trait_name
