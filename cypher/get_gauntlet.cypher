:param username "jheinnic@hotmail.com"
:param traits ["hunter", "cyberneticist", "maquis"]
:param mainSkill "eng"
:param timestamp timestamp()

//MATCH (g:GauntletTeam)
//MATCH (g)-[:PLAYS_CANDIDATE {slot: 1}]->(n1:GauntletCrewCandidate)
//MATCH (g)-[:PLAYS_CANDIDATE {slot: 2}]->(n2:GauntletCrewCandidate)
//MATCH (g)-[:PLAYS_CANDIDATE {slot: 3}]->(n3:GauntletCrewCandidate)
//MATCH (g)-[:PLAYS_CANDIDATE {slot: 4}]->(n4:GauntletCrewCandidate)
//MATCH (g)-[:PLAYS_CANDIDATE {slot: 5}]->(n5:GauntletCrewCandidate)
//RETURN g {. *}, n1, n2, n3, n4, n5;


MATCH (player:Player {username: $username})-[e:ENLISTED]->(:CrewInstance)
WITH player, max(e.timestamp) AS latest
CREATE(player)
    -[:RAN]->(g:GauntletAnalysis {username: $username, timestamp: $timestamp,
                                  snapshotFrom: latest, skill: $skill, traits: $traits});

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (:Player {username: $username})
    -[:ENLISTED {timestamp: g.snapshotFrom}]->(ci:CrewInstance)
    -[:HAS_LEVEL]->(lvl:CrewLevel)
    -[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
    WHERE gt.id IN g.traits
WITH g, ci, lvl, (1.05 + ((0.2) * count(gt))) AS stat_bonus, c.symbol as symbol
WITH g, ci, symbol, lvl.rarity AS rarity, lvl.level AS level,
     (lvl.cmd_rmin * stat_bonus) AS cmd_min, (lvl.cmd_rmax * stat_bonus) AS cmd_max,
     (lvl.dip_rmin * stat_bonus) AS dip_min, (lvl.dip_rmax * stat_bonus) AS dip_max,
     (lvl.eng_rmin * stat_bonus) AS eng_min, (lvl.eng_rmax * stat_bonus) AS eng_max,
     (lvl.sec_rmin * stat_bonus) AS sec_min, (lvl.sec_rmax * stat_bonus) AS sec_max,
     (lvl.med_rmin * stat_bonus) AS med_min, (lvl.med_rmax * stat_bonus) AS med_max,
     (lvl.sci_rmin * stat_bonus) AS sci_min, (lvl.sci_rmax * stat_bonus) AS sci_max
MERGE (g)
    -[:WITH_CANDIDATES]->(gci:GauntletCrewCandidate {crew_id: ci.id, symbol: c.symbol,
                                                     rarity: lvl.rarity, level: lvl.level})
    -[:DERIVED_FROM]->(ci)
SET gci.cmd_dip_min = cmd_min + dip_min
SET gci.cmd_eng_min = cmd_min + eng_min
SET gci.cmd_sec_min = cmd_min + sec_min
SET gci.cmd_med_min = cmd_min + med_min
SET gci.cmd_sci_min = cmd_min + sci_min
SET gci.dip_eng_min = dip_min + eng_min
SET gci.dip_sec_min = dip_min + sec_min
SET gci.dip_med_min = dip_min + med_min
SET gci.dip_sci_min = dip_min + sci_min
SET gci.eng_sec_min = eng_min + sec_min
SET gci.eng_med_min = eng_min + med_min
SET gci.eng_sci_min = eng_min + sci_min
SET gci.sec_med_min = sec_min + med_min
SET gci.sec_sci_min = sec_min + sci_min
SET gci.med_sci_min = med_min + sci_min;

SET gci.cmd_dip_max = cmd_max + dip_max
SET gci.cmd_eng_max = cmd_max + eng_max
SET gci.cmd_sec_max = cmd_max + sec_max
SET gci.cmd_med_max = cmd_max + med_max
SET gci.cmd_sci_max = cmd_max + sci_max
SET gci.dip_eng_max = dip_max + eng_max
SET gci.dip_sec_max = dip_max + sec_max
SET gci.dip_med_max = dip_max + med_max
SET gci.dip_sci_max = dip_max + sci_max
SET gci.eng_sec_max = eng_max + sec_max
SET gci.eng_med_max = eng_max + med_max
SET gci.eng_sci_max = eng_max + sci_max
SET gci.sec_med_max = sec_max + med_max
SET gci.sec_sci_max = sec_max + sci_max
SET gci.med_sci_max = med_max + sci_max;

SET gci.cmd_dip_avg = (gci.cmd_dip_min + gci.cmd_dip_max) / 2.0
SET gci.cmd_eng_avg = (cmd_min + cmd_max + eng_min + eng_max) / 2.0
SET gci.cmd_sec_avg = (cmd_min + cmd_max + sec_min + sec_max) / 2.0
SET gci.cmd_med_avg = (cmd_min + cmd_max + med_min + med_max) / 2.0
SET gci.cmd_sci_avg = (cmd_min + cmd_max + sci_min + sci_max) / 2.0
SET gci.dip_eng_avg = (dip_min + dip_max + eng_min + eng_max) / 2.0
SET gci.dip_sec_avg = (dip_min + dip_max + sec_min + sec_max) / 2.0
SET gci.dip_med_avg = (dip_min + dip_max + med_min + med_max) / 2.0
SET gci.dip_sci_avg = (dip_min + dip_max + sci_min + sci_max) / 2.0
SET gci.eng_sec_avg = (eng_min + eng_max + sec_min + sec_max) / 2.0
SET gci.eng_med_avg = (eng_min + eng_max + med_min + med_max) / 2.0
SET gci.eng_sci_avg = (eng_min + eng_max + sci_min + sci_max) / 2.0
SET gci.sec_med_avg = (sec_min + sec_max + med_min + med_max) / 2.0
SET gci.sec_sci_avg = (sec_min + sec_max + sci_min + sci_max) / 2.0
SET gci.med_sci_avg = (med_min + med_max + sci_min + sci_max) / 2.0


/*
MATCH (g:GauntletAnalysis {username: $username, updated: $timestamp})
MATCH (g)-[:WITH_CANDIDATES]->(gci:GauntletCrewCandidate)
SET gci.cmd_dip_min = ((lvl.cmd_rmin + lvl.dip_rmin) * stat_bonus)
SET gci.cmd_eng_min = ((lvl.cmd_rmin + lvl.eng_rmin) * stat_bonus)
SET gci.cmd_sec_min = ((lvl.cmd_rmin + lvl.sec_rmin) * stat_bonus)
SET gci.cmd_med_min = ((lvl.cmd_rmin + lvl.med_rmin) * stat_bonus)
SET gci.cmd_sci_min = ((lvl.cmd_rmin + lvl.sci_rmin) * stat_bonus)
SET gci.dip_eng_min = ((lvl.dip_rmin + lvl.eng_rmin) * stat_bonus)
SET gci.dip_sec_min = ((lvl.dip_rmin + lvl.sec_rmin) * stat_bonus)
SET gci.dip_med_min = ((lvl.dip_rmin + lvl.med_rmin) * stat_bonus)
SET gci.dip_sci_min = ((lvl.dip_rmin + lvl.sci_rmin) * stat_bonus)
SET gci.eng_sec_min = ((lvl.eng_rmin + lvl.sec_rmin) * stat_bonus)
SET gci.eng_med_min = ((lvl.eng_rmin + lvl.med_rmin) * stat_bonus)
SET gci.eng_sci_min = ((lvl.eng_rmin + lvl.sci_rmin) * stat_bonus)
SET gci.sec_med_min = ((lvl.sec_rmin + lvl.med_rmin) * stat_bonus)
SET gci.sec_sci_min = ((lvl.sec_rmin + lvl.sci_rmin) * stat_bonus)
SET gci.med_sci_min = ((lvl.med_rmin + lvl.sci_rmin) * stat_bonus);

SET gci.cmd_dip_avg = ((lvl.cmd_gavg + lvl.dip_gavg) * stat_bonus)
SET gci.cmd_eng_avg = ((lvl.cmd_gavg + lvl.eng_gavg) * stat_bonus)
SET gci.cmd_sec_avg = ((lvl.cmd_gavg + lvl.sec_gavg) * stat_bonus)
SET gci.cmd_med_avg = ((lvl.cmd_gavg + lvl.med_gavg) * stat_bonus)
SET gci.cmd_sci_avg = ((lvl.cmd_gavg + lvl.sci_gavg) * stat_bonus)
SET gci.dip_eng_avg = ((lvl.dip_gavg + lvl.eng_gavg) * stat_bonus)
SET gci.dip_sec_avg = ((lvl.dip_gavg + lvl.sec_gavg) * stat_bonus)
SET gci.dip_med_avg = ((lvl.dip_gavg + lvl.med_gavg) * stat_bonus)
SET gci.dip_sci_avg = ((lvl.dip_gavg + lvl.sci_gavg) * stat_bonus)
SET gci.eng_sec_avg = ((lvl.eng_gavg + lvl.sec_gavg) * stat_bonus)
SET gci.eng_med_avg = ((lvl.eng_gavg + lvl.med_gavg) * stat_bonus)
SET gci.eng_sci_avg = ((lvl.eng_gavg + lvl.sci_gavg) * stat_bonus)
SET gci.sec_med_avg = ((lvl.sec_gavg + lvl.med_gavg) * stat_bonus)
SET gci.sec_sci_avg = ((lvl.sec_gavg + lvl.sci_gavg) * stat_bonus)
SET gci.med_sci_avg = ((lvl.med_gavg + lvl.sci_gavg) * stat_bonus);

SET gci.cmd_dip_max = ((lvl.cmd_rmax + lvl.dip_rmax) * stat_bonus)
SET gci.cmd_eng_max = ((lvl.cmd_rmax + lvl.eng_rmax) * stat_bonus)
SET gci.cmd_sec_max = ((lvl.cmd_rmax + lvl.sec_rmax) * stat_bonus)
SET gci.cmd_med_max = ((lvl.cmd_rmax + lvl.med_rmax) * stat_bonus)
SET gci.cmd_sci_max = ((lvl.cmd_rmax + lvl.sci_rmax) * stat_bonus)
SET gci.dip_eng_max = ((lvl.dip_rmax + lvl.eng_rmax) * stat_bonus)
SET gci.dip_sec_max = ((lvl.dip_rmax + lvl.sec_rmax) * stat_bonus)
SET gci.dip_med_max = ((lvl.dip_rmax + lvl.med_rmax) * stat_bonus)
SET gci.dip_sci_max = ((lvl.dip_rmax + lvl.sci_rmax) * stat_bonus)
SET gci.eng_sec_max = ((lvl.eng_rmax + lvl.sec_rmax) * stat_bonus)
SET gci.eng_med_max = ((lvl.eng_rmax + lvl.med_rmax) * stat_bonus)
SET gci.eng_sci_max = ((lvl.eng_rmax + lvl.sci_rmax) * stat_bonus)
SET gci.sec_med_max = ((lvl.sec_rmax + lvl.med_rmax) * stat_bonus)
SET gci.sec_sci_max = ((lvl.sec_rmax + lvl.sci_rmax) * stat_bonus)
SET gci.med_sci_max = ((lvl.med_rmax + lvl.sci_rmax) * stat_bonus);
*/


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
    -[:WITH_CANDIDATES]->(gci:GauntletCrewCandidate)
WITH g, collect(gci) AS gci_all
WITH g, filter(
  candidate IN gci_all
  WHERE none(
    gci_other IN filter(
      o IN gci_all
      WHERE o <> candidate
    )
    WHERE
      (gci_other.cmd_dip_max >= candidate.cmd_dip_max) AND
      (gci_other.cmd_eng_max >= candidate.cmd_eng_max) AND
      (gci_other.cmd_sec_max >= candidate.cmd_sec_max) AND
      (gci_other.cmd_med_max >= candidate.cmd_med_max) AND
      (gci_other.cmd_sci_max >= candidate.cmd_sci_max) AND
      (gci_other.dip_eng_max >= candidate.dip_eng_max) AND
      (gci_other.dip_sec_max >= candidate.dip_sec_max) AND
      (gci_other.dip_med_max >= candidate.dip_med_max) AND
      (gci_other.dip_sci_max >= candidate.dip_sci_max) AND
      (gci_other.eng_sec_max >= candidate.eng_sec_max) AND
      (gci_other.eng_med_max >= candidate.eng_med_max) AND
      (gci_other.eng_sci_max >= candidate.eng_sci_max) AND
      (gci_other.sec_med_max >= candidate.sec_med_max) AND
      (gci_other.sec_sci_max >= candidate.sec_sci_max) AND
      (gci_other.med_sci_max >= candidate.med_sci_max) AND
      (gci_other.cmd_dip_min >= candidate.cmd_dip_min) AND
      (gci_other.cmd_eng_min >= candidate.cmd_eng_min) AND
      (gci_other.cmd_sec_min >= candidate.cmd_sec_min) AND
      (gci_other.cmd_med_min >= candidate.cmd_med_min) AND
      (gci_other.cmd_sci_min >= candidate.cmd_sci_min) AND
      (gci_other.dip_eng_min >= candidate.dip_eng_min) AND
      (gci_other.dip_sec_min >= candidate.dip_sec_min) AND
      (gci_other.dip_med_min >= candidate.dip_med_min) AND
      (gci_other.dip_sci_min >= candidate.dip_sci_min) AND
      (gci_other.eng_sec_min >= candidate.eng_sec_min) AND
      (gci_other.eng_med_min >= candidate.eng_med_min) AND
      (gci_other.eng_sci_min >= candidate.eng_sci_min) AND
      (gci_other.sec_med_min >= candidate.sec_med_min) AND
      (gci_other.sec_sci_min >= candidate.sec_sci_min) AND
      (gci_other.med_sci_min >= candidate.med_sci_min)
  )
) AS gci_candidates
FOREACH (
  candidate IN gci_candidates |
  CREATE (g)-[:FILTERED]->(candidate)
)
RETURN gci_candidates;


//MERGE (g)-[:RANKED]->
