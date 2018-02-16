//:param timestamp timestamp()
//:param username "jheinnic@hotmail.com"
//:param gauntletTraits [ "inspiring", "hero", "desperate" ]

//:begin
MATCH (g:Gauntlet)
DETACH DELETE g;

MATCH (g:GauntletCrewInstance)
DETACH DELETE g;
//:commit

//:begin
MATCH (self:Player {username: $username})-[i:IMPORTED]->(:PlayerSnapshot)
WITH self AS player, MAX(i.timestamp) AS latest
CREATE (player)-[:ENTERED {timestamp: $timestamp}]->(g:Gauntlet)
WITH player, latest, g
MATCH (player)-[:ENLISTED {timestamp: latest}]->(ci:CrewInstance)-[:HAS_LEVEL]->(lvl:CrewLevel)-[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
WHERE gt.id IN $gauntletTraits
WITH g, ci, lvl, 1.05 + ((0.2) * count(gt)) AS stat_bonus
WITH g, ci, lvl {
    .level,
    .rarity,
    symbol: lvl.id,
    cmd: lvl.cmd_gavg * stat_bonus,
    dip: lvl.dip_gavg * stat_bonus,
    eng: lvl.eng_gavg * stat_bonus,
    sec: lvl.sec_gavg * stat_bonus,
    med: lvl.med_gavg * stat_bonus,
    sci: lvl.sci_gavg * stat_bonus
} AS g_stats
WITH g, ci, g_stats {
    .symbol,
    .level, 
    .rarity,
    cmd_dip: (g_stats.cmd + g_stats.dip),
    cmd_eng: (g_stats.cmd + g_stats.eng),
    cmd_sec: (g_stats.cmd + g_stats.sec),
    cmd_med: (g_stats.cmd + g_stats.med),
    cmd_sci: (g_stats.cmd + g_stats.sci),
    dip_eng: (g_stats.dip + g_stats.eng),
    dip_sec: (g_stats.dip + g_stats.sec),
    dip_med: (g_stats.dip + g_stats.med),
    dip_sci: (g_stats.dip + g_stats.sci),
    eng_sec: (g_stats.eng + g_stats.sec),
    eng_med: (g_stats.eng + g_stats.med),
    eng_sci: (g_stats.eng + g_stats.sci),
    sec_med: (g_stats.sec + g_stats.med),
    sec_sci: (g_stats.sec + g_stats.sci),
    med_sci: (g_stats.med + g_stats.sci)
} AS g_lvl
MERGE (g)-[:CANDIDATES]->(gci:GauntletCrewInstance)-[:DERIVED_FROM]->(ci)
ON CREATE SET gci = g_lvl
WITH g, collect(gci) AS gci_all
UNWIND gci_all AS gci_seat_one
WITH g, gci_all, gci_seat_one
WHERE none(gci_other IN gci_all WHERE gci_seat_one <> gci_other AND
    gci_seat_one.cmd_dip <= gci_other.cmd_dip AND
    gci_seat_one.cmd_eng <= gci_other.cmd_eng AND
    gci_seat_one.cmd_sec <= gci_other.cmd_sec AND
    gci_seat_one.cmd_med <= gci_other.cmd_med AND
    gci_seat_one.cmd_sci <= gci_other.cmd_sci AND
    gci_seat_one.dip_eng <= gci_other.dip_eng AND
    gci_seat_one.dip_sec <= gci_other.dip_sec AND
    gci_seat_one.dip_med <= gci_other.dip_med AND
    gci_seat_one.dip_sci <= gci_other.dip_sci AND
    gci_seat_one.eng_sec <= gci_other.eng_sec AND
    gci_seat_one.eng_med <= gci_other.eng_med AND
    gci_seat_one.eng_sci <= gci_other.eng_sci AND
    gci_seat_one.sec_med <= gci_other.sec_med AND
    gci_seat_one.sec_sci <= gci_other.sec_sci AND
    gci_seat_one.med_sci <= gci_other.med_sci)
MERGE (g)-[:FIRST_CUT]->(gt_one:GauntletTeamOne)-[:SEAT_ONE]->(gci_seat_one)
ON CREATE SET gt_one = gci_seat_one
WITH g, gci_all, gt_one
UNWIND gci_all AS gci_next
WITH g, gci_all, gt_one, {
    cmd_dip: CASE (gci_next.cmd_dip >= gt_one.cmd_dip) WHEN TRUE THEN gci_next.cmd_dip ELSE gt_one.cmd_dip END,
    cmd_eng: CASE (gci_next.cmd_eng >= gt_one.cmd_eng) WHEN TRUE THEN gci_next.cmd_eng ELSE gt_one.cmd_eng END,
    cmd_sec: CASE (gci_next.cmd_sec >= gt_one.cmd_sec) WHEN TRUE THEN gci_next.cmd_sec ELSE gt_one.cmd_sec END,
    cmd_med: CASE (gci_next.cmd_med >= gt_one.cmd_med) WHEN TRUE THEN gci_next.cmd_med ELSE gt_one.cmd_med END,
    cmd_sci: CASE (gci_next.cmd_sci >= gt_one.cmd_sci) WHEN TRUE THEN gci_next.cmd_sci ELSE gt_one.cmd_sci END,
    dip_eng: CASE (gci_next.dip_eng >= gt_one.dip_eng) WHEN TRUE THEN gci_next.dip_eng ELSE gt_one.dip_eng END,
    dip_sec: CASE (gci_next.dip_sec >= gt_one.dip_sec) WHEN TRUE THEN gci_next.dip_sec ELSE gt_one.dip_sec END,
    dip_med: CASE (gci_next.dip_med >= gt_one.dip_med) WHEN TRUE THEN gci_next.dip_med ELSE gt_one.dip_med END,
    dip_sci: CASE (gci_next.dip_sci >= gt_one.dip_sci) WHEN TRUE THEN gci_next.dip_sci ELSE gt_one.dip_sci END,
    eng_sec: CASE (gci_next.eng_sec >= gt_one.eng_sec) WHEN TRUE THEN gci_next.eng_sec ELSE gt_one.eng_sec END,
    eng_med: CASE (gci_next.eng_med >= gt_one.eng_med) WHEN TRUE THEN gci_next.eng_med ELSE gt_one.eng_med END,
    eng_sci: CASE (gci_next.eng_sci >= gt_one.eng_sci) WHEN TRUE THEN gci_next.eng_sci ELSE gt_one.eng_sci END,
    sec_med: CASE (gci_next.sec_med >= gt_one.sec_med) WHEN TRUE THEN gci_next.sec_med ELSE gt_one.sec_med END,
    sec_sci: CASE (gci_next.sec_sci >= gt_one.sec_sci) WHEN TRUE THEN gci_next.sec_sci ELSE gt_one.sec_sci END,
    med_sci: CASE (gci_next.med_sci >= gt_one.med_sci) WHEN TRUE THEN gci_next.med_sci ELSE gt_one.med_sci END
} AS gci_seat_two
WITH g, gci_all, gt_one, collect(gci_seat_two) as gci_all_two
UNWIND gci_all_two AS gci_seat_two
WITH g, gci_all, gt_one, gci_all_two, gci_seat_two
WHERE none(gci_other IN gci_all_two WHERE
    gt_one <> gci_other AND
    gci_seat_two <> gci_other AND
	  gci_seat_two.cmd_dip <= gci_other.cmd_dip AND
    gci_seat_two.cmd_eng <= gci_other.cmd_eng AND
    gci_seat_two.cmd_sec <= gci_other.cmd_sec AND
    gci_seat_two.cmd_med <= gci_other.cmd_med AND
    gci_seat_two.cmd_sci <= gci_other.cmd_sci AND
    gci_seat_two.dip_eng <= gci_other.dip_eng AND
    gci_seat_two.dip_sec <= gci_other.dip_sec AND
    gci_seat_two.dip_med <= gci_other.dip_med AND
    gci_seat_two.dip_sci <= gci_other.dip_sci AND
    gci_seat_two.eng_sec <= gci_other.eng_sec AND
    gci_seat_two.eng_med <= gci_other.eng_med AND
    gci_seat_two.eng_sci <= gci_other.eng_sci AND
    gci_seat_two.sec_med <= gci_other.sec_med AND
    gci_seat_two.sec_sci <= gci_other.sec_sci AND
    gci_seat_two.med_sci <= gci_other.med_sci)
MERGE (g)-[:SECOND_CUT]->(gt_two:GauntletTeamTwo)-[:SEAT_TWO]->(gci_seat_two)
ON CREATE SET gt_two = gci_seat_two
MERGE (g)-[:SECOND_CUT]->(gt_two:GauntletTeamTwo)-[:SEAT_ONE]->(gci_seat_one)
RETURN gt_two { .symbol, .rarity, .level, .* };
//:commit
