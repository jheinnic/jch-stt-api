
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/players.csv" AS row
MERGE (player:Player {dbid: row.dbid, player_id: row.player_id, character_id: row.character_id})
MERGE (player)-[i:IMPORTED {timestamp: $timestamp}]->(snap:PlayerSnapshot {dbid: row.dbid, player_id: row.player_id, character_id: row.character_id, timestamp: 1} )
ON CREATE SET snap.display_name = row.character_display_name, snap.level = row.level, snap.xp = row.xp;:


// MATCH (division:PvpDivision {rank: 'Commander'}
// MATCH (divisionEntry:PvpDivisionEntry {id: row.characterId}
// MATCH (shipInst:ShipInstance {id: row.shipId, owner: row.characterId})
// MATCH (crewInst:CrewInstance {id: row.crewId, owner: row.characterId})
// MERGE (divisionEntry)-[reg:REGISTERED_IN]->(division)
// MERGE (character)-[reg:REGISTERS]->(divisionEntry)
// MERGE (divisionEntry)-[pickShip:USES_SHIP]->(shipInst)
// MERGE (divisionEntry)-[crewOne:USES_CREW{slot_id: row.slot_id}]->(crewInst)


USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/crew_instance_stats.csv" AS row
WITH row AS owned_rows, DISTINCT row.owner_id AS owner_id
MATCH (owner:Player {character_id: owner_id})
UNWIND owned_rows AS owned_row
MERGE (crewIdent: CrewIdent {id: row.symbol})
ON CREATE SET crew.name = row.name, crew.short_name = row.short_name, crew.rarity = row.max_rarity
MERGE (lvl:CrewLevel {symbol: row.symbol, level: row.level, rarity: row.rarity})-[:IS_LEVEL_FOR]->(crewIdent)
ON CREATE SET lvl.cmd_core = row.cmd_core, lvl.cmd_rmin = row.cmd_rmin, lvl.cmd_rmax = row.cmd_rmax, lvl.dip_core = row.dip_core, lvl.dip_rmin = row.dip_rmin, lvl.dip_rmax = row.dip_rmax, lvl.eng_core = row.eng_core, lvl.eng_rmin = row.eng_rmin, lvl.eng_rmax = row.eng_rmax, lvl.sec_core = row.sec_core, lvl.sec_rmin = row.sec_rmin, lvl.sec_rmax = row.sec_rmax, lvl.med_core = row.med_core, lvl.med_rmin = row.med_rmin, lvl.med_rmax = row.med_rmax, lvl.sci_core = row.sci_core, lvl.sci_rmin = row.sci_rmin, lvl.sci_rmax = row.sci_rmax
MERGE (owner)-[e:ENLISTED {timestamp: $timestamp}]->(own_crew: CrewInstance {id: row.id})-[:HAS_LEVEL]->(lvl)
ON CREATE SET own_crew.level = row.level, own_crew.symbol = row.symbol, own_crew.rarity = row.rarity
UNWIND split(row.traits, ';') as trait_name
MERGE (trait:Trait {name: trait_name})
MERGE (crewIdent)-[:HAS_TRAIT]->(trait);

