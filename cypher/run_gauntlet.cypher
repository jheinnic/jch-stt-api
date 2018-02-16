//:param username "jheinnic@hotmail.com"
//:param traits ["hunter", "cyberneticist", "maquis"]
//:param mainSkill "eng"
//:param timestamp timestamp()

MATCH (player:Player {username: $username})-[e:ENLISTED]->(:CrewInstance)
WITH player, max(e.timestamp) AS latest
CREATE(player)
    -[:RAN]->(g:GauntletAnalysis {username: $username, timestamp: $timestamp,
                                  snapshotFrom: latest, skill: $skill, traits: $traits})
return g;

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (:Player {username: $username})
    -[:ENLISTED {timestamp: g.snapshotFrom}]->(ci:CrewInstance)
    -[:HAS_LEVEL]->(lvl:CrewLevel)
    -[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
    WHERE gt.id IN g.traits
WITH g, ci, lvl, (1.05 + ((0.2) * count(gt))) AS stat_bonus, c.symbol as symbol
WITH g, ci, symbol, ci.id AS crew_id, lvl.rarity AS rarity, lvl.level AS level,
     (lvl.cmd_rmin * stat_bonus) AS cmd_min, (lvl.cmd_rmax * stat_bonus) AS cmd_max,
     (lvl.dip_rmin * stat_bonus) AS dip_min, (lvl.dip_rmax * stat_bonus) AS dip_max,
     (lvl.eng_rmin * stat_bonus) AS eng_min, (lvl.eng_rmax * stat_bonus) AS eng_max,
     (lvl.sec_rmin * stat_bonus) AS sec_min, (lvl.sec_rmax * stat_bonus) AS sec_max,
     (lvl.med_rmin * stat_bonus) AS med_min, (lvl.med_rmax * stat_bonus) AS med_max,
     (lvl.sci_rmin * stat_bonus) AS sci_min, (lvl.sci_rmax * stat_bonus) AS sci_max
MERGE (g)
    -[:WITH_CANDIDATES]->(gci:GauntletCrewCandidate {crew_id: crew_id, symbol: symbol,
                                                     rarity: rarity, level: level})
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
SET gci.med_sci_min = med_min + sci_min

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
SET gci.med_sci_max = med_max + sci_max

SET gci.cmd_dip_avg = (gci.cmd_dip_min + gci.cmd_dip_max) / 2.0
SET gci.cmd_eng_avg = (gci.cmd_eng_min + gci.cmd_eng_max) / 2.0
SET gci.cmd_sec_avg = (gci.cmd_sec_min + gci.cmd_sec_max) / 2.0
SET gci.cmd_med_avg = (gci.cmd_med_min + gci.cmd_med_max) / 2.0
SET gci.cmd_sci_avg = (gci.cmd_sci_min + gci.cmd_sci_max) / 2.0
SET gci.dip_eng_avg = (gci.dip_eng_min + gci.dip_eng_max) / 2.0
SET gci.dip_sec_avg = (gci.dip_sec_min + gci.dip_sec_max) / 2.0
SET gci.dip_med_avg = (gci.dip_med_min + gci.dip_med_max) / 2.0
SET gci.dip_sci_avg = (gci.dip_sci_min + gci.dip_sci_max) / 2.0
SET gci.eng_sec_avg = (gci.eng_sec_min + gci.eng_sec_max) / 2.0
SET gci.eng_med_avg = (gci.eng_med_min + gci.eng_med_max) / 2.0
SET gci.eng_sci_avg = (gci.eng_sci_min + gci.eng_sci_max) / 2.0
SET gci.sec_med_avg = (gci.sec_med_min + gci.sec_med_max) / 2.0
SET gci.sec_sci_avg = (gci.sec_sci_min + gci.sec_sci_max) / 2.0
SET gci.med_sci_avg = (gci.med_sci_min + gci.med_sci_max) / 2.0
RETURN collect(gci);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
    -[:WITH_CANDIDATES]->(gci:GauntletCrewCandidate)
WITH g, gci ORDER BY gci.symbol ASCENDING
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

//MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
//    -[:BUILDING]->(oldgp:GauntletPath)
//DETACH DELETE oldgp;

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
OPTIONAL MATCH (g)-[:BUILDING]->(old_gp:GauntletPath)
DETACH DELETE old_gp
WITH g
MATCH (g)-[:FILTERED]->(gci:GauntletCrewCandidate)
WITH g, collect(gci) AS gci_candidates, range(1, 2) AS path_lens
UNWIND gci_candidates AS next_gci
CREATE (g)-[:BUILDING {filled: 1}]->(src:GauntletPath)
SET src += properties(next_gci)
WITH g, path_lens, gci_candidates, next_gci, src
UNWIND path_lens AS path_len
MATCH (g)-[:BUILDING {filled: path_len}]->(src:GauntletPath)
WITH g, gci_candidates, collect(src) AS path_heads, (path_len + 1) AS next_len
UNWIND path_heads AS src
MATCH (src)-[:ASSIGNS]->(latest_gci:GauntletCrewCandidate)
UNWIND gci_candidates AS next_gci
UNWIND [src, next_gci] AS skills
WITH
  g, next_len, src, next_gci, latest_gci,
  max(skills.cmd_dip_avg) AS cmd_dip_avg,
  max(skills.cmd_eng_avg) AS cmd_eng_avg,
  max(skills.cmd_sec_avg) AS cmd_sec_avg,
  max(skills.cmd_med_avg) AS cmd_med_avg,
  max(skills.cmd_sci_avg) AS cmd_sci_avg,
  max(skills.dip_eng_avg) AS dip_eng_avg,
  max(skills.dip_sec_avg) AS dip_sec_avg,
  max(skills.dip_med_avg) AS dip_med_avg,
  max(skills.dip_sci_avg) AS dip_sci_avg,
  max(skills.eng_sec_avg) AS eng_sec_avg,
  max(skills.eng_med_avg) AS eng_med_avg,
  max(skills.eng_sci_avg) AS eng_sci_avg,
  max(skills.sec_med_avg) AS sec_med_avg,
  max(skills.sec_sci_avg) AS sec_sci_avg,
  max(skills.med_sci_avg) AS med_sci_avg
WHERE next_gci.symbol > latest_gci.symbol
CREATE (g)-[:BUILDING {filled: next_len}]->(dst:GauntletPath)
MERGE (src)-[:TO]->(dst)-[:ASSIGNS]->(next_gci)
SET dst.cmd_dip_avg = cmd_dip_avg
SET dst.cmd_eng_avg = cmd_eng_avg
SET dst.cmd_sec_avg = cmd_sec_avg
SET dst.cmd_med_avg = cmd_med_avg
SET dst.cmd_sci_avg = cmd_sci_avg
SET dst.dip_eng_avg = dip_eng_avg
SET dst.dip_sec_avg = dip_sec_avg
SET dst.dip_med_avg = dip_med_avg
SET dst.dip_sci_avg = dip_sci_avg
SET dst.eng_sec_avg = eng_sec_avg
SET dst.eng_med_avg = eng_med_avg
SET dst.eng_sci_avg = eng_sci_avg
SET dst.sec_med_avg = sec_med_avg
SET dst.sec_sci_avg = sec_sci_avg
SET dst.med_sci_avg = med_sci_avg;

//MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
//MATCH (g)-[:FILTERED]->(gci:GauntletCrewCandidate)
//CREATE (gci)-[:PARENT]->(g);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:FILTERED]->(gciOne:GauntletCrewCandidate)
MATCH (g)-[:FILTERED]->(gciTwo:GauntletCrewCandidate)
WHERE gciOne.symbol < gciTwo.symbol
CREATE (gciOne)-[:FOLLOWS]->(gciTwo);


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)
        -[:FILTERED]->(s1:GauntletCrewCandidate)
        -[:FOLLOWS]->(s2:GauntletCrewCandidate)
        -[:FOLLOWS]->(s3:GauntletCrewCandidate)
        -[:FOLLOWS]->(s4:GauntletCrewCandidate)
        -[:FOLLOWS]->(s5:GauntletCrewCandidate)
CREATE (g)-[:SCORES]->(team:GauntletTeamCandidate)
CREATE (team)-[:INCLUDES {slot: 1}]->(s1)
CREATE (team)-[:INCLUDES {slot: 2}]->(s2)
CREATE (team)-[:INCLUDES {slot: 3}]->(s3)
CREATE (team)-[:INCLUDES {slot: 4}]->(s4)
CREATE (team)-[:INCLUDES {slot: 5}]->(s5)
SET team.slot_one = s1.symbol
SET team.slot_two = s2.symbol
SET team.slot_three = s3.symbol
SET team.slot_four = s4.symbol
SET team.slot_five = s5.symbol
SET team.cmd_dip_avg = apoc.coll.max([
  s1.cmd_dip_avg, s2.cmd_dip_avg, s3.cmd_dip_avg, s4.cmd_dip_avg, s5.cmd_dip_avg])
SET team.cmd_eng_avg = apoc.coll.max([
  s1.cmd_eng_avg, s2.cmd_eng_avg, s3.cmd_eng_avg, s4.cmd_eng_avg, s5.cmd_eng_avg])
SET team.cmd_sec_avg = apoc.coll.max([
  s1.cmd_sec_avg, s2.cmd_sec_avg, s3.cmd_sec_avg, s4.cmd_sec_avg, s5.cmd_sec_avg])
SET team.cmd_med_avg = apoc.coll.max([
  s1.cmd_med_avg, s2.cmd_med_avg, s3.cmd_med_avg, s4.cmd_med_avg, s5.cmd_med_avg])
SET team.cmd_sci_avg = apoc.coll.max([
  s1.cmd_sci_avg, s2.cmd_sci_avg, s3.cmd_sci_avg, s4.cmd_sci_avg, s5.cmd_sci_avg])
SET team.dip_eng_avg = apoc.coll.max([
  s1.dip_eng_avg, s2.dip_eng_avg, s3.dip_eng_avg, s4.dip_eng_avg, s5.dip_eng_avg])
SET team.dip_sec_avg = apoc.coll.max([
  s1.dip_sec_avg, s2.dip_sec_avg, s3.dip_sec_avg, s4.dip_sec_avg, s5.dip_sec_avg])
SET team.dip_med_avg = apoc.coll.max([
  s1.dip_med_avg, s2.dip_med_avg, s3.dip_med_avg, s4.dip_med_avg, s5.dip_med_avg])
SET team.dip_sci_avg = apoc.coll.max([
  s1.dip_sci_avg, s2.dip_sci_avg, s3.dip_sci_avg, s4.dip_sci_avg, s5.dip_sci_avg])
SET team.eng_sec_avg = apoc.coll.max([
  s1.eng_sec_avg, s2.eng_sec_avg, s3.eng_sec_avg, s4.eng_sec_avg, s5.eng_sec_avg])
SET team.eng_med_avg = apoc.coll.max([
  s1.eng_med_avg, s2.eng_med_avg, s3.eng_med_avg, s4.eng_med_avg, s5.eng_med_avg])
SET team.sec_sci_avg = apoc.coll.max([
  s1.sec_sci_avg, s2.sec_sci_avg, s3.sec_sci_avg, s4.sec_sci_avg, s5.sec_sci_avg])
SET team.sec_med_avg = apoc.coll.max([
  s1.sec_med_avg, s2.sec_med_avg, s3.sec_med_avg, s4.sec_med_avg, s5.sec_med_avg])
SET team.sec_sci_avg = apoc.coll.max([
  s1.sec_sci_avg, s2.sec_sci_avg, s3.sec_sci_avg, s4.sec_sci_avg, s5.sec_sci_avg])
SET team.med_sci_avg = apoc.coll.max([
  s1.med_sci_avg, s2.med_sci_avg, s3.med_sci_avg, s4.med_sci_avg, s5.med_sci_avg]);


MATCH (g:GauntletAnalysis {skill: "sec"})
        -[:FILTERED]->(s1:GauntletCrewCandidate)
        -[:FOLLOWS]->(s2:GauntletCrewCandidate)
        -[:FOLLOWS]->(s3:GauntletCrewCandidate)
UNWIND [s1, s2, s3] AS skills
WITH
  s1, // s2, s3,
  max(skills.cmd_dip_avg) AS cmd_dip_avg,
  max(skills.cmd_eng_avg) AS cmd_eng_avg,
  max(skills.cmd_sec_avg) AS cmd_sec_avg,
  max(skills.cmd_med_avg) AS cmd_med_avg,
  max(skills.cmd_sci_avg) AS cmd_sci_avg,
  max(skills.dip_eng_avg) AS dip_eng_avg,
  max(skills.dip_sec_avg) AS dip_sec_avg,
  max(skills.dip_med_avg) AS dip_med_avg,
  max(skills.dip_sci_avg) AS dip_sci_avg,
  max(skills.eng_sec_avg) AS eng_sec_avg,
  max(skills.eng_med_avg) AS eng_med_avg,
  max(skills.eng_sci_avg) AS eng_sci_avg,
  max(skills.sec_med_avg) AS sec_med_avg,
  max(skills.sec_sci_avg) AS sec_sci_avg,
  max(skills.med_sci_avg) AS med_sci_avg
CREATE (g)-[:SCORES]->(team:GauntletTeamCandidate)
CREATE (team)-[:INCLUDES {slot: 1}]->(s1)
CREATE (team)-[:INCLUDES {slot: 2}]->(s2)
CREATE (team)-[:INCLUDES {slot: 3}]->(s3);
RETURN cmd_dip_avg, med_sci_avg, s1.symbol, s2.symbol, s3.symbol LIMIT 5;


call apoc.periodic.iterate(
'MATCH (g:GauntletAnalysis {username: \'jheinnic@hotmail.com\', timestamp: 1515421483505}) MATCH (g) -[:FILTERED]->(s1:GauntletCrewCandidate) -[:FOLLOWS]->(s2:GauntletCrewCandidate) -[:FOLLOWS]->(s3:GauntletCrewCandidate) -[:FOLLOWS]->(s4:GauntletCrewCandidate) -[:FOLLOWS]->(s5:GauntletCrewCandidate) RETURN s1, s2, s3, s4, s5;',
'CREATE (g)-[:SCORES]->(team:GauntletTeamCandidate) CREATE (team)-[:INCLUDES {slot: 1}]->(s1) CREATE (team)-[:INCLUDES {slot: 2}]->(s2) CREATE (team)-[:INCLUDES {slot: 3}]->(s3) CREATE (team)-[:INCLUDES {slot: 4}]->(s4) CREATE (team)-[:INCLUDES {slot: 5}]->(s5) SET team.slot_one = s1.symbol SET team.slot_two = s2.symbol SET team.slot_three = s3.symbol SET team.slot_four = s4.symbol SET team.slot_five = s5.symbol SET team.cmd_dip_avg = apoc.coll.max([ s1.cmd_dip_avg, s2.cmd_dip_avg, s3.cmd_dip_avg, s4.cmd_dip_avg, s5.cmd_dip_avg]) SET team.cmd_eng_avg = apoc.coll.max([ s1.cmd_eng_avg, s2.cmd_eng_avg, s3.cmd_eng_avg, s4.cmd_eng_avg, s5.cmd_eng_avg]) SET team.cmd_sec_avg = apoc.coll.max([ s1.cmd_sec_avg, s2.cmd_sec_avg, s3.cmd_sec_avg, s4.cmd_sec_avg, s5.cmd_sec_avg]) SET team.cmd_med_avg = apoc.coll.max([ s1.cmd_med_avg, s2.cmd_med_avg, s3.cmd_med_avg, s4.cmd_med_avg, s5.cmd_med_avg]) SET team.cmd_sci_avg = apoc.coll.max([ s1.cmd_sci_avg, s2.cmd_sci_avg, s3.cmd_sci_avg, s4.cmd_sci_avg, s5.cmd_sci_avg]) SET team.dip_eng_avg = apoc.coll.max([ s1.dip_eng_avg, s2.dip_eng_avg, s3.dip_eng_avg, s4.dip_eng_avg, s5.dip_eng_avg]) SET team.dip_sec_avg = apoc.coll.max([ s1.dip_sec_avg, s2.dip_sec_avg, s3.dip_sec_avg, s4.dip_sec_avg, s5.dip_sec_avg]) SET team.dip_med_avg = apoc.coll.max([ s1.dip_med_avg, s2.dip_med_avg, s3.dip_med_avg, s4.dip_med_avg, s5.dip_med_avg]) SET team.dip_sci_avg = apoc.coll.max([ s1.dip_sci_avg, s2.dip_sci_avg, s3.dip_sci_avg, s4.dip_sci_avg, s5.dip_sci_avg]) SET team.eng_sec_avg = apoc.coll.max([ s1.eng_sec_avg, s2.eng_sec_avg, s3.eng_sec_avg, s4.eng_sec_avg, s5.eng_sec_avg]) SET team.eng_med_avg = apoc.coll.max([ s1.eng_med_avg, s2.eng_med_avg, s3.eng_med_avg, s4.eng_med_avg, s5.eng_med_avg]) SET team.sec_sci_avg = apoc.coll.max([ s1.sec_sci_avg, s2.sec_sci_avg, s3.sec_sci_avg, s4.sec_sci_avg, s5.sec_sci_avg]) SET team.sec_med_avg = apoc.coll.max([ s1.sec_med_avg, s2.sec_med_avg, s3.sec_med_avg, s4.sec_med_avg, s5.sec_med_avg]) SET team.sec_sci_avg = apoc.coll.max([ s1.sec_sci_avg, s2.sec_sci_avg, s3.sec_sci_avg, s4.sec_sci_avg, s5.sec_sci_avg]) SET team.med_sci_avg = apoc.coll.max([ s1.med_sci_avg, s2.med_sci_avg, s3.med_sci_avg, s4.med_sci_avg, s5.med_sci_avg]);',
{batchSize: 1000, parallel: true, iterateList: true});

MATCH (g:GauntletAnalysis {username: 'jheinnic@hotmail.com', timestamp: 1515421483505}) MATCH (g) -[:FILTERED]->(s1:GauntletCrewCandidate) -[:FOLLOWS]->(s2:GauntletCrewCandidate) -[:FOLLOWS]->(s3:GauntletCrewCandidate) -[:FOLLOWS]->(s4:GauntletCrewCandidate) -[:FOLLOWS]->(s5:GauntletCrewCandidate) RETURN s1, s2, s3, s4, s5;


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)
        -[:FILTERED]->(s1:GauntletCrewCandidate)
        -[:FOLLOWS]->(s2:GauntletCrewCandidate)
CREATE (g)-[:PARTIAL]->(team:GauntletPartialTeam)
CREATE (team)-[:INCLUDES {slot: 1}]->(s1)
CREATE (team)-[:INCLUDES {slot: 2}]->(s2)
SET team.slot_one = s1.symbol
SET team.slot_two = s2.symbol
SET team.cmd_dip_avg = apoc.coll.max([s1.cmd_dip_avg, s2.cmd_dip_avg])
SET team.cmd_eng_avg = apoc.coll.max([s1.cmd_eng_avg, s2.cmd_eng_avg])
SET team.cmd_sec_avg = apoc.coll.max([s1.cmd_sec_avg, s2.cmd_sec_avg])
SET team.cmd_med_avg = apoc.coll.max([s1.cmd_med_avg, s2.cmd_med_avg])
SET team.cmd_sci_avg = apoc.coll.max([s1.cmd_sci_avg, s2.cmd_sci_avg])
SET team.dip_eng_avg = apoc.coll.max([s1.dip_eng_avg, s2.dip_eng_avg])
SET team.dip_sec_avg = apoc.coll.max([s1.dip_sec_avg, s2.dip_sec_avg])
SET team.dip_med_avg = apoc.coll.max([s1.dip_med_avg, s2.dip_med_avg])
SET team.dip_sci_avg = apoc.coll.max([s1.dip_sci_avg, s2.dip_sci_avg])
SET team.eng_sec_avg = apoc.coll.max([s1.eng_sec_avg, s2.eng_sec_avg])
SET team.eng_med_avg = apoc.coll.max([s1.eng_med_avg, s2.eng_med_avg])
SET team.sec_sci_avg = apoc.coll.max([s1.sec_sci_avg, s2.sec_sci_avg])
SET team.sec_med_avg = apoc.coll.max([s1.sec_med_avg, s2.sec_med_avg])
SET team.sec_sci_avg = apoc.coll.max([s1.sec_sci_avg, s2.sec_sci_avg])
SET team.med_sci_avg = apoc.coll.max([s1.med_sci_avg, s2.med_sci_avg]);


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
    -[:FILTERED_PARTIAL]->(stale: GauntletPartialTeam)
//DETACH DELETE stale;
RETURN stale;


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
        -[:PARTIAL]->(gct:GauntletPartialTeam)
WITH g, collect(gct) AS gct_all
MATCH (g)-[:PARTIAL {size: 3}]->(candidate:GauntletPartialTeam)
WHERE none(
  gct_other IN filter(
    o IN gct_all WHERE o <> candidate
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

