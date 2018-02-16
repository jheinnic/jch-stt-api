:param username "jheinnic@hotmail.com"
:param timestamp timestamp()

MATCH (n)
DETACH DELETE n;

:begin
// USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/players.csv" AS player_row
MERGE (player:Player {username: player_row.username, dbid: player_row.dbid, player_id: toInteger(player_row.player_id), character_id: toInteger(player_row.character_id)})
CREATE (player)-[:IMPORTED {timestamp: $timestamp}]->(snap:PlayerSnapshot {display_name: player_row.character_display_name, level: toInteger(player_row.level), xp: 400})
WITH player
LOAD CSV WITH HEADERS FROM "file:/crew_instance_stats.csv" AS crew_row
WITH player, crew_row
WHERE toInteger(crew_row.owner_id) = player.character_id
MERGE (crew_shared:CrewIdentity {symbol: crew_row.symbol})
ON CREATE SET crew_shared.name = crew_row.name, crew_shared.short_name = crew_row.short_name, crew_shared.max_rarity = toInteger(crew_row.max_rarity)
MERGE (crew_lvl:CrewLevel {id: crew_row.symbol, level: toInteger(crew_row.level), rarity: toInteger(crew_row.rarity)})-[:IS_LEVEL_FOR]->(crew_shared)
ON CREATE SET
    crew_lvl.cmd_core = toInteger(crew_row.cmd_core),
    crew_lvl.cmd_rmin = toInteger(crew_row.cmd_rmin), crew_lvl.cmd_rmax = toInteger(crew_row.cmd_rmax),
    crew_lvl.cmd_gavg = (toFloat(crew_row.cmd_rmin) + toFloat(crew_row.cmd_rmax)) / 2,
    crew_lvl.dip_core = toInteger(crew_row.dip_core),
    crew_lvl.dip_rmin = toInteger(crew_row.dip_rmin), crew_lvl.dip_rmax = toInteger(crew_row.dip_rmax),
    crew_lvl.dip_gavg = (toFloat(crew_row.dip_rmin) + toFloat(crew_row.dip_rmax)) / 2,
    crew_lvl.eng_core = toInteger(crew_row.eng_core),
    crew_lvl.eng_rmin = toInteger(crew_row.eng_rmin), crew_lvl.eng_rmax = toInteger(crew_row.eng_rmax),
    crew_lvl.eng_gavg = (toFloat(crew_row.eng_rmin) + toFloat(crew_row.eng_rmax)) / 2,
    crew_lvl.sec_core = toInteger(crew_row.sec_core),
    crew_lvl.sec_rmin = toInteger(crew_row.sec_rmin), crew_lvl.sec_rmax = toInteger(crew_row.sec_rmax),
    crew_lvl.sec_gavg = (toFloat(crew_row.sec_rmin) + toFloat(crew_row.sec_rmax)) / 2,
    crew_lvl.med_core = toInteger(crew_row.med_core),
    crew_lvl.med_rmin = toInteger(crew_row.med_rmin), crew_lvl.med_rmax = toInteger(crew_row.med_rmax),
    crew_lvl.med_gavg = (toFloat(crew_row.med_rmin) + toFloat(crew_row.med_rmax)) / 2,
    crew_lvl.sci_core = toInteger(crew_row.sci_core),
    crew_lvl.sci_rmin = toInteger(crew_row.sci_rmin), crew_lvl.sci_rmax = toInteger(crew_row.sci_rmax),
    crew_lvl.sci_gavg = (toFloat(crew_row.sci_rmin) + toFloat(crew_row.sci_rmax)) / 2
MERGE (player)-[e:ENLISTED {timestamp: $timestamp}]->(crew_owned: CrewInstance {id: toInteger(crew_row.crew_id), timestamp: $timestamp})-[:HAS_LEVEL]->(crew_lvl)
ON CREATE SET crew_owned.level = toInteger(crew_row.level), crew_owned.symbol = crew_row.symbol, crew_owned.rarity = toInteger(crew_row.rarity)
WITH player, crew_owned, crew_lvl, crew_shared, crew_row.traits as crew_traits
UNWIND split(crew_traits, ';') as trait_name
MERGE (trait:Trait {id: trait_name})
MERGE (crew_shared)-[:HAS_TRAIT]->(trait)
RETURN player, crew_shared, crew_lvl, crew_owned, collect(trait) as traits;
:commit
