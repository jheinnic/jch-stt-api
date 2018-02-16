//:param username "jheinnic@hotmail.com"
//:param traits ["hunter", "cyberneticist", "maquis"]
//:param mainSkill "eng"
//:param timestamp timestamp()

MATCH (player:Player {username: $username})-[e:ENLISTED]->(:CrewInstance)
WITH player, max(e.timestamp) AS latest
CREATE(player)
        -[:RAN]->(g:GauntletAnalysis {username:     $username, timestamp: $timestamp,
                                      snapshotFrom: latest, skill: $skill, traits: $traits})
RETURN g;

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (:Player {username: $username})
        -[:ENLISTED {timestamp: g.snapshotFrom}]->(ci:CrewInstance)
        -[:HAS_LEVEL]->(lvl:CrewLevel)
        -[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
  WHERE gt.id IN g.traits
WITH g, ci, lvl, (1.05 + ((0.2) * count(gt))) AS stat_bonus, c.symbol AS symbol
WITH g, ci, symbol, ci.id AS crew_id, lvl.rarity AS rarity, lvl.level AS level,
     (lvl.cmd_rmin * stat_bonus) AS cmd_min, (lvl.cmd_rmax * stat_bonus) AS cmd_max,
     (lvl.dip_rmin * stat_bonus) AS dip_min, (lvl.dip_rmax * stat_bonus) AS dip_max,
     (lvl.eng_rmin * stat_bonus) AS eng_min, (lvl.eng_rmax * stat_bonus) AS eng_max,
     (lvl.sec_rmin * stat_bonus) AS sec_min, (lvl.sec_rmax * stat_bonus) AS sec_max,
     (lvl.med_rmin * stat_bonus) AS med_min, (lvl.med_rmax * stat_bonus) AS med_max,
     (lvl.sci_rmin * stat_bonus) AS sci_min, (lvl.sci_rmax * stat_bonus) AS sci_max
WITH g, ci, symbol, crew_id, rarity, level,
     ((cmd_min + cmd_max) / 2.0) AS cmd_avg, ((dip_min + dip_max) / 2.0) AS dip_avg,
     ((eng_min + eng_max) / 2.0) AS eng_avg, ((sec_min + sec_max) / 2.0) AS sec_avg,
     ((med_min + med_max) / 2.0) AS med_avg, ((sci_min + sci_max) / 2.0) AS sci_avg
MERGE (g)-[:CANDIDATES]->(gci:GauntletCrew {crew_id: crew_id, symbol: symbol, rarity: rarity, level: level})
  -[:DERIVED_FROM]->(ci)
SET gci.cmd_dip = (cmd_avg + dip_avg), gci.cmd_eng = (cmd_avg + eng_avg), gci.cmd_sec = (cmd_avg + sec_avg),
gci.cmd_med = (cmd_avg + med_avg), gci.cmd_sci = (cmd_avg + sci_avg), gci.dip_eng = (dip_avg + eng_avg),
gci.dip_sec = (dip_avg + sec_avg), gci.dip_med = (dip_avg + med_avg), gci.dip_sci = (dip_avg + sci_avg),
gci.eng_sec = (eng_avg + sec_avg), gci.eng_med = (eng_avg + med_avg), gci.eng_sci = (eng_avg + sci_avg),
gci.sec_med = (sec_avg + med_avg), gci.sec_sci = (sec_avg + sci_avg), gci.med_sci = (med_avg + sci_avg);


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:CANDIDATES]->(candidate:GauntletCrew)
  WHERE none(
  gci_other IN [
  (g)-[:CANDIDATES]->(other:GauntletCrew)
    WHERE candidate <> other | other
  ]
    WHERE
    (gci_other.cmd_dip >= candidate.cmd_dip) AND
    (gci_other.cmd_eng >= candidate.cmd_eng) AND
    (gci_other.cmd_sec >= candidate.cmd_sec) AND
    (gci_other.cmd_med >= candidate.cmd_med) AND
    (gci_other.cmd_sci >= candidate.cmd_sci) AND
    (gci_other.dip_eng >= candidate.dip_eng) AND
    (gci_other.dip_sec >= candidate.dip_sec) AND
    (gci_other.dip_med >= candidate.dip_med) AND
    (gci_other.dip_sci >= candidate.dip_sci) AND
    (gci_other.eng_sec >= candidate.eng_sec) AND
    (gci_other.eng_med >= candidate.eng_med) AND
    (gci_other.eng_sci >= candidate.eng_sci) AND
    (gci_other.sec_med >= candidate.sec_med) AND
    (gci_other.sec_sci >= candidate.sec_sci) AND
    (gci_other.med_sci >= candidate.med_sci)
  )
WITH g, candidate ORDER BY candidate.symbol ASCENDING
WITH g, collect(candidate) AS candidate_order
UNWIND candidate_order AS gci_one
WITH g, candidate_order, gci_one
CREATE (g)-[:BUILDING {size: 1}]->(gt:GauntletTeam)
SET gt += gci_one
CREATE (gt)-[:INCLUDES]->(gci_one)
WITH candidate_order, gci_one
FOREACH (
  gci_two IN candidate_order[(1 + apoc.coll.indexOf(candidate_order, gci_one))..] |
  CREATE (gci_one)-[:FOLLOWED_BY]->(gci_two)
);


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
WITH g, range(1, 4) AS sizes
UNWIND sizes AS src_size
MATCH (g)
        -[:BUILDING {size: src_size}]->(base: GauntletTeam)
        -[:INCLUDES]->(assigned:GauntletCrew)
        -[:FOLLOWED_BY]->(candidate:GauntletCrew)
CREATE (g)-[:NEXT_TIER {size: (src_size + 1)}]->(team:GauntletTeam)
CREATE (team)-[:INCLUDES]->(candidate)
CREATE (team)-[:BASED_ON]->(base)
SET team.cmd_dip = apoc.coll.max([base.cmd_dip, candidate.cmd_dip])
SET team.cmd_eng = apoc.coll.max([base.cmd_eng, candidate.cmd_eng])
SET team.cmd_sec = apoc.coll.max([base.cmd_sec, candidate.cmd_sec])
SET team.cmd_med = apoc.coll.max([base.cmd_med, candidate.cmd_med])
SET team.cmd_sci = apoc.coll.max([base.cmd_sci, candidate.cmd_sci])
SET team.dip_eng = apoc.coll.max([base.dip_eng, candidate.dip_eng])
SET team.dip_sec = apoc.coll.max([base.dip_sec, candidate.dip_sec])
SET team.dip_med = apoc.coll.max([base.dip_med, candidate.dip_med])
SET team.dip_sci = apoc.coll.max([base.dip_sci, candidate.dip_sci])
SET team.eng_sec = apoc.coll.max([base.eng_sec, candidate.eng_sec])
SET team.eng_med = apoc.coll.max([base.eng_med, candidate.eng_med])
SET team.sec_sci = apoc.coll.max([base.sec_sci, candidate.sec_sci])
SET team.sec_med = apoc.coll.max([base.sec_med, candidate.sec_med])
SET team.sec_sci = apoc.coll.max([base.sec_sci, candidate.sec_sci])
SET team.med_sci = apoc.coll.max([base.med_sci, candidate.med_sci])
WITH g, (src_size + 1) AS dst_size
MATCH (g)-[:NEXT_TIER {size: dst_size}]->(candidate:GauntletTeam)
WHERE none(
  gci_other IN [
  (g)-[:NEXT_TIER {size: dst_size}]->(other:GauntletTeam)
    WHERE candidate <> other | other
  ]
    WHERE
    (gci_other.cmd_dip >= candidate.cmd_dip) AND
    (gci_other.cmd_eng >= candidate.cmd_eng) AND
    (gci_other.cmd_sec >= candidate.cmd_sec) AND
    (gci_other.cmd_med >= candidate.cmd_med) AND
    (gci_other.cmd_sci >= candidate.cmd_sci) AND
    (gci_other.dip_eng >= candidate.dip_eng) AND
    (gci_other.dip_sec >= candidate.dip_sec) AND
    (gci_other.dip_med >= candidate.dip_med) AND
    (gci_other.dip_sci >= candidate.dip_sci) AND
    (gci_other.eng_sec >= candidate.eng_sec) AND
    (gci_other.eng_med >= candidate.eng_med) AND
    (gci_other.eng_sci >= candidate.eng_sci) AND
    (gci_other.sec_med >= candidate.sec_med) AND
    (gci_other.sec_sci >= candidate.sec_sci) AND
    (gci_other.med_sci >= candidate.med_sci)
  )
CREATE (g)-[:BUILDING {size: dst_size}]->(candidate);


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
    -[b:BUILDING]->(base: GauntletTeam)
RETURN b.size, base;

/*
MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
        -[:PARTIAL]->(gct:GauntletPartialTeam)
WITH g, collect(gct) AS gct_all
MATCH (g)-[:PARTIAL {size: 3}]->(candidate:GauntletPartialTeam)
  WHERE none(
  gct_other IN filter(
  o IN gct_all
    WHERE o <> candidate
  )
    WHERE
    (gct_other.cmd_dip_avg >= candidate.cmd_dip_avg) AND
    (gct_other.cmd_eng_avg >= candidate.cmd_eng_avg) AND
    (gct_other.cmd_sec_avg >= candidate.cmd_sec_avg) AND
    (gct_other.cmd_med_avg >= candidate.cmd_med_avg) AND
    (gct_other.cmd_sci_avg >= candidate.cmd_sci_avg) AND
    (gct_other.dip_eng_avg >= candidate.dip_eng_avg) AND
    (gct_other.dip_sec_avg >= candidate.dip_sec_avg) AND
    (gct_other.dip_med_avg >= candidate.dip_med_avg) AND
    (gct_other.dip_sci_avg >= candidate.dip_sci_avg) AND
    (gct_other.eng_sec_avg >= candidate.eng_sec_avg) AND
    (gct_other.eng_med_avg >= candidate.eng_med_avg) AND
    (gct_other.eng_sci_avg >= candidate.eng_sci_avg) AND
    (gct_other.sec_med_avg >= candidate.sec_med_avg) AND
    (gct_other.sec_sci_avg >= candidate.sec_sci_avg) AND
    (gct_other.med_sci_avg >= candidate.med_sci_avg)
  )
CREATE (g)-[:FILTERED_PARTIAL]->(candidate);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)
        -[:FILTERED_PARTIAL]->(s12:GauntletPartialTeam)
        -[:INCLUDES {slot: 1}]->(s1:GauntletCrewCandidate)
MATCH (s12)-[:INCLUDES {slot: 2}]->(s2:GauntletCrewCandidate)
        -[:FOLLOWS]->(s3:GauntletCrewCandidate)
CREATE (g)-[:PARTIAL {size: 3}]->(team:GauntletPartialTeam)
CREATE (team)-[:INCLUDES {slot: 1}]->(s1)
CREATE (team)-[:INCLUDES {slot: 2}]->(s2)
CREATE (team)-[:INCLUDES {slot: 3}]->(s3)
SET team.slot_one = s1.symbol
SET team.slot_two = s2.symbol
SET team.slot_three = s3.symbol
SET team.cmd_dip_avg = apoc.coll.max([s1.cmd_dip_avg, s3.cmd_dip_avg])
SET team.cmd_eng_avg = apoc.coll.max([s1.cmd_eng_avg, s3.cmd_eng_avg])
SET team.cmd_sec_avg = apoc.coll.max([s1.cmd_sec_avg, s3.cmd_sec_avg])
SET team.cmd_med_avg = apoc.coll.max([s1.cmd_med_avg, s3.cmd_med_avg])
SET team.cmd_sci_avg = apoc.coll.max([s1.cmd_sci_avg, s3.cmd_sci_avg])
SET team.dip_eng_avg = apoc.coll.max([s1.dip_eng_avg, s3.dip_eng_avg])
SET team.dip_sec_avg = apoc.coll.max([s1.dip_sec_avg, s3.dip_sec_avg])
SET team.dip_med_avg = apoc.coll.max([s1.dip_med_avg, s3.dip_med_avg])
SET team.dip_sci_avg = apoc.coll.max([s1.dip_sci_avg, s3.dip_sci_avg])
SET team.eng_sec_avg = apoc.coll.max([s1.eng_sec_avg, s3.eng_sec_avg])
SET team.eng_med_avg = apoc.coll.max([s1.eng_med_avg, s3.eng_med_avg])
SET team.sec_sci_avg = apoc.coll.max([s1.sec_sci_avg, s3.sec_sci_avg])
SET team.sec_med_avg = apoc.coll.max([s1.sec_med_avg, s3.sec_med_avg])
SET team.sec_sci_avg = apoc.coll.max([s1.sec_sci_avg, s3.sec_sci_avg])
SET team.med_sci_avg = apoc.coll.max([s1.med_sci_avg, s3.med_sci_avg]);
*/
