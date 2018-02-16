:param timestamp timestamp()
:param username "jheinnic@hotmail.com"
:param gauntletTraits [ "inspiring", "hero", "desperate" ]

MATCH (self:Player {username: $username})-[i:IMPORTED]->(:PlayerSnapshot)
RETURN self as player, max(i.timestamp) AS latest;

:begin
MATCH (g:Gauntlet)
DETACH DELETE g;

MATCH (g:GauntletCrewInstance)
DETACH DELETE g;
:commit

:begin
MATCH (self:Player {username: $username})-[i:IMPORTED]->(:PlayerSnapshot)
WITH self AS player, MAX(i.timestamp) AS latest
CREATE (player)-[:ENTERED {timestamp: $timestamp}]->(g:Gauntlet)
WITH player, latest, g
MATCH (player)-[:ENLISTED {timestamp: latest}]->(ci:CrewInstance)-[:HAS_LEVEL]->(lvl:CrewLevel)-[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
WHERE gt.id IN $gauntletTraits
WITH g, ci, lvl, 1.05 + ((0.2) * count(gt)) AS stat_bonus
WITH g, ci, lvl {
    .level, .rarity,
    symbol: lvl.id,
    cmd: lvl.cmd_gavg * stat_bonus,
    dip: lvl.dip_gavg * stat_bonus,
    eng: lvl.eng_gavg * stat_bonus,
    sec: lvl.sec_gavg * stat_bonus,
    med: lvl.med_gavg * stat_bonus,
    sci: lvl.sci_gavg * stat_bonus
} AS g_stats
WITH g, ci, g_stats {
    .symbol, .level, .rarity,
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
MERGE (g)-[:CONSIDERED]->(gci:GauntletCrewInstance)-[:DERIVED_FROM]->(ci)
ON CREATE SET gci = g_lvl
WITH gci, collect(gci) AS gci_all
WHERE none(gci_other IN gci_all WHERE gci <> gci_other AND
	gci.cmd_dip <= gci_other.cmd_dip AND
    gci.cmd_eng <= gci_other.cmd_eng AND
    gci.cmd_sec <= gci_other.cmd_sec AND
    gci.cmd_med <= gci_other.cmd_med AND
    gci.cmd_sci <= gci_other.cmd_sci AND
    gci.dip_eng <= gci_other.dip_eng AND
    gci.dip_sec <= gci_other.dip_sec AND
    gci.dip_med <= gci_other.dip_med AND
    gci.dip_sci <= gci_other.dip_sci AND
    gci.eng_sec <= gci_other.eng_sec AND
    gci.eng_med <= gci_other.eng_med AND
    gci.eng_sci <= gci_other.eng_sci AND
    gci.sec_med <= gci_other.sec_med AND
    gci.sec_sci <= gci_other.sec_sci AND
    gci.med_sci <= gci_other.med_sci)
RETURN gci.symbol, gci.rarity, gci.level, gci { .* };
:commit



/*
MATCH (self:Player {username: $username})-[i:IMPORTED]->(:PlayerSnapshot)
WITH self AS player, MAX(i.timestamp) AS latest
MATCH (player)-[:ENLISTED {timestamp: latest}]->(ci:CrewInstance)-[:HAS_LEVEL]->(lvl:CrewLevel)-[:IS_LEVEL_FOR]->(c:CrewIdentity)
WITH ci, c, lvl, collect(lvl) AS lvl_all,
WHERE none(lvl_other IN lvl_all WHERE lvl <> lvl_other AND
	lvl.cmd_rmax <= lvl_other.cmd_rmax AND lvl.cmd_rmin <= lvl_other.cmd_rmin AND
	lvl.dip_rmax <= lvl_other.dip_rmax AND lvl.dip_rmin <= lvl_other.dip_rmin AND
	lvl.eng_rmax <= lvl_other.eng_rmax AND lvl.eng_rmin <= lvl_other.eng_rmin AND
	lvl.sec_rmax <= lvl_other.sec_rmax AND lvl.sec_rmin <= lvl_other.sec_rmin AND
	lvl.med_rmax <= lvl_other.med_rmax AND lvl.med_rmin <= lvl_other.med_rmin AND
	lvl.sci_rmax <= lvl_other.sci_rmax AND lvl.sci_rmin <= lvl_other.sci_rmin)
RETURN c1.symbol, c2.symbol,
    lvl1.cmd_rmin, lvl2.cmd_rmin, lvl1.cmd_rmax, lvl2.cmd_rmax,
    lvl1.dip_rmin, lvl2.dip_rmin, lvl1.dip_rmax, lvl2.dip_rmax,
    lvl1.sec_rmin, lvl2.sec_rmin, lvl1.sec_rmax, lvl2.sec_rmax,
    lvl1.eng_rmin, lvl2.eng_rmin, lvl1.eng_rmax, lvl2.eng_rmax,
    lvl1.med_rmin, lvl2.med_rmin, lvl1.med_rmax, lvl2.med_rmax,
    lvl1.sci_rmin, lvl2.sci_rmin, lvl1.sci_rmax, lvl2.sci_rmax;


MATCH (self:Player {name:"Captain Neutrino"})-[:IMPORTED {timestamp: 1}]->(snap:PlayerSnapshot)
MATCH (snap)-[:ENLISTED {timestamp: 1}]->(ci1:CrewInstance)-[:HAS_LEVEL]->(lvl1:CrewLevel)
MATCH (snap)-[:ENLISTED {timestamp: 1}]->(ci2:CrewInstance)-[:HAS_LEVEL]->(lvl2:CrewLevel)
WITH ci1, ci2, lvl1, lvl2
WHERE ci1 <> ci2 AND lvl1.cmd_rmax <= lvl2.cmd_rmax AND lvl1.cmd_rmin <= lvl2.cmd_rmin AND
		lvl1.dip_rmax <= lvl2.dip_rmax AND lvl1.dip_rmin <= lvl2.dip_rmin AND
		lvl1.eng_rmax <= lvl2.eng_rmax AND lvl1.eng_rmin <= lvl2.eng_rmin AND
		lvl1.sec_rmax <= lvl2.sec_rmax AND lvl1.sec_rmin <= lvl2.sec_rmin AND
		lvl1.med_rmax <= lvl2.med_rmax AND lvl1.med_rmin <= lvl2.med_rmin AND
		lvl1.sci_rmax <= lvl2.sci_rmax AND lvl1.sci_rmin <= lvl2.sci_rmin
RETURN ci1.symbol, ci2.symbol;

MATCH (c1:CrewLevel)
WITH collect(c1) AS allC, c1
WHERE none(
	c2 IN allC
	WHERE c1 <> c2 AND
	      c1.cmd_rmax <= c2.cmd_rmax AND c1.cmd_rmin <= c2.cmd_rmin AND
              c1.dip_rmax <= c2.dip_rmax AND c1.dip_rmin <= c2.dip_rmin AND
              c1.eng_rmax <= c2.eng_rmax AND c1.eng_rmin <= c2.eng_rmin AND
              c1.sec_rmax <= c2.sec_rmax AND c1.sec_rmin <= c2.sec_rmin AND
              c1.med_rmax <= c2.med_rmax AND c1.med_rmin <= c2.med_rmin AND
              c1.sci_rmax <= c2.sci_rmax AND c1.sci_rmin <= c2.sci_rmin)
RETURN collect(c1) AS uniqC;
*/
