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
MERGE (g)-[:CANDIDATES]->(gci:GauntletCrew {crew_id: crew_id, symbol: symbol, rarity:  rarity, level: level})
     -[:DERIVED_FROM]->(ci)
MERGE (g)-[:SCORES {round: 'cmd_dip'}]->(cmd_dip:GauntletRound {round: 'cmd_dip', average: (cmd_avg + dip_avg)})
MERGE (g)-[:SCORES {round: 'cmd_eng'}]->(cmd_eng:GauntletRound {round: 'cmd_eng', average: (cmd_avg + eng_avg)})
MERGE (g)-[:SCORES {round: 'cmd_sec'}]->(cmd_sec:GauntletRound {round: 'cmd_sec', average: (cmd_avg + sec_avg)})
MERGE (g)-[:SCORES {round: 'cmd_med'}]->(cmd_med:GauntletRound {round: 'cmd_med', average: (cmd_avg + med_avg)})
MERGE (g)-[:SCORES {round: 'cmd_sci'}]->(cmd_sci:GauntletRound {round: 'cmd_sci', average: (cmd_avg + sci_avg)})
MERGE (g)-[:SCORES {round: 'dip_eng'}]->(dip_eng:GauntletRound {round: 'dip_eng', average: (dip_avg + eng_avg)})
MERGE (g)-[:SCORES {round: 'dip_sec'}]->(dip_sec:GauntletRound {round: 'dip_sec', average: (dip_avg + sec_avg)})
MERGE (g)-[:SCORES {round: 'dip_med'}]->(dip_med:GauntletRound {round: 'dip_med', average: (dip_avg + med_avg)})
MERGE (g)-[:SCORES {round: 'dip_sci'}]->(dip_sci:GauntletRound {round: 'dip_sci', average: (dip_avg + sci_avg)})
MERGE (g)-[:SCORES {round: 'eng_sec'}]->(eng_sec:GauntletRound {round: 'eng_sec', average: (eng_avg + sec_avg)})
MERGE (g)-[:SCORES {round: 'eng_med'}]->(eng_med:GauntletRound {round: 'eng_med', average: (eng_avg + med_avg)})
MERGE (g)-[:SCORES {round: 'eng_sci'}]->(eng_sci:GauntletRound {round: 'eng_sci', average: (eng_avg + sci_avg)})
MERGE (g)-[:SCORES {round: 'sec_med'}]->(sec_med:GauntletRound {round: 'sec_med', average: (sec_avg + med_avg)})
MERGE (g)-[:SCORES {round: 'sec_sci'}]->(sec_sci:GauntletRound {round: 'sec_sci', average: (sec_avg + sci_avg)})
MERGE (g)-[:SCORES {round: 'med_sci'}]->(med_sci:GauntletRound {round: 'med_sci', average: (med_avg + sci_avg)})
MERGE (gci)-[:SCORES {round: 'cmd_dip'}]->(cmd_dip)
MERGE (gci)-[:SCORES {round: 'cmd_eng'}]->(cmd_eng)
MERGE (gci)-[:SCORES {round: 'cmd_sec'}]->(cmd_sec)
MERGE (gci)-[:SCORES {round: 'cmd_med'}]->(cmd_med)
MERGE (gci)-[:SCORES {round: 'cmd_sci'}]->(cmd_sci)
MERGE (gci)-[:SCORES {round: 'dip_eng'}]->(dip_eng)
MERGE (gci)-[:SCORES {round: 'dip_sec'}]->(dip_sec)
MERGE (gci)-[:SCORES {round: 'dip_med'}]->(dip_med)
MERGE (gci)-[:SCORES {round: 'dip_sci'}]->(dip_sci)
MERGE (gci)-[:SCORES {round: 'eng_sec'}]->(eng_sec)
MERGE (gci)-[:SCORES {round: 'eng_med'}]->(eng_med)
MERGE (gci)-[:SCORES {round: 'eng_sci'}]->(eng_sci)
MERGE (gci)-[:SCORES {round: 'sec_med'}]->(sec_med)
MERGE (gci)-[:SCORES {round: 'sec_sci'}]->(sec_sci)
MERGE (gci)-[:SCORES {round: 'med_sci'}]->(med_sci)
WITH g, { crew: gci, cmd_dip: cmd_dip.average, cmd_eng: cmd_eng.average, cmd_sec: cmd_sec.average, cmd_med: cmd_med.average,
cmd_sci: cmd_sci.average, dip_eng: dip_eng.average, dip_sec: dip_sec.average, dip_med: dip_med.average, dip_sci: dip_sci.average,
eng_sec: eng_sec.average, eng_med: eng_med.average, eng_sci: eng_sci.average, sec_med: sec_med.average, sec_sci: sec_sci.average,
med_sci: med_sci.average } AS crew_score
WITH g, collect(crew_score) AS all_crew_scores
WITH g, filter(
  candidate IN all_crew_scores
  WHERE none(
    gci_other IN filter(
      o IN all_crew_scores WHERE o.crew.crew_id <> candidate.crew.crew_id
    )
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
) AS gci_candidates
UNWIND gci_candidates AS candidate
MATCH (g)-[:CANDIDATES]->(kept:GauntletCrew {crew_id: candidate.crew.crew_id})
CREATE (g)-[:FILTEREED]->(kept)
RETURN kept;

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:FILTERED]->(gciOne:GauntletCrewCandidate)
MATCH (g)-[:FILTERED]->(gciTwo:GauntletCrewCandidate)
  WHERE gciOne.symbol < gciTwo.symbol
CREATE (gciOne)-[:FOLLOWS]->(gciTwo);


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


MATCH (g:GauntletAnalysis {skill: 'sec'})
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

RETURN cmd_dip_avg, med_sci_avg, s1.symbol, s2.symbol, s3.symbol
  LIMIT 5;


CALL apoc.periodic.iterate(
"MATCH (g:GauntletAnalysis {username: 'jheinnic@hotmail.com', timestamp: 1515421483505}) MATCH (g) -[:FILTERED]->(s1:GauntletCrewCandidate) -[:FOLLOWS]->(s2:GauntletCrewCandidate) -[:FOLLOWS]->(s3:GauntletCrewCandidate) -[:FOLLOWS]->(s4:GauntletCrewCandidate) -[:FOLLOWS]->(s5:GauntletCrewCandidate) RETURN s1, s2, s3, s4, s5;",
'CREATE (g)-[:SCORES]->(team:GauntletTeamCandidate) CREATE (team)-[:INCLUDES {slot: 1}]->(s1) CREATE (team)-[:INCLUDES {slot: 2}]->(s2) CREATE (team)-[:INCLUDES {slot: 3}]->(s3) CREATE (team)-[:INCLUDES {slot: 4}]->(s4) CREATE (team)-[:INCLUDES {slot: 5}]->(s5) SET team.slot_one = s1.symbol SET team.slot_two = s2.symbol SET team.slot_three = s3.symbol SET team.slot_four = s4.symbol SET team.slot_five = s5.symbol SET team.cmd_dip_avg = apoc.coll.max([ s1.cmd_dip_avg, s2.cmd_dip_avg, s3.cmd_dip_avg, s4.cmd_dip_avg, s5.cmd_dip_avg]) SET team.cmd_eng_avg = apoc.coll.max([ s1.cmd_eng_avg, s2.cmd_eng_avg, s3.cmd_eng_avg, s4.cmd_eng_avg, s5.cmd_eng_avg]) SET team.cmd_sec_avg = apoc.coll.max([ s1.cmd_sec_avg, s2.cmd_sec_avg, s3.cmd_sec_avg, s4.cmd_sec_avg, s5.cmd_sec_avg]) SET team.cmd_med_avg = apoc.coll.max([ s1.cmd_med_avg, s2.cmd_med_avg, s3.cmd_med_avg, s4.cmd_med_avg, s5.cmd_med_avg]) SET team.cmd_sci_avg = apoc.coll.max([ s1.cmd_sci_avg, s2.cmd_sci_avg, s3.cmd_sci_avg, s4.cmd_sci_avg, s5.cmd_sci_avg]) SET team.dip_eng_avg = apoc.coll.max([ s1.dip_eng_avg, s2.dip_eng_avg, s3.dip_eng_avg, s4.dip_eng_avg, s5.dip_eng_avg]) SET team.dip_sec_avg = apoc.coll.max([ s1.dip_sec_avg, s2.dip_sec_avg, s3.dip_sec_avg, s4.dip_sec_avg, s5.dip_sec_avg]) SET team.dip_med_avg = apoc.coll.max([ s1.dip_med_avg, s2.dip_med_avg, s3.dip_med_avg, s4.dip_med_avg, s5.dip_med_avg]) SET team.dip_sci_avg = apoc.coll.max([ s1.dip_sci_avg, s2.dip_sci_avg, s3.dip_sci_avg, s4.dip_sci_avg, s5.dip_sci_avg]) SET team.eng_sec_avg = apoc.coll.max([ s1.eng_sec_avg, s2.eng_sec_avg, s3.eng_sec_avg, s4.eng_sec_avg, s5.eng_sec_avg]) SET team.eng_med_avg = apoc.coll.max([ s1.eng_med_avg, s2.eng_med_avg, s3.eng_med_avg, s4.eng_med_avg, s5.eng_med_avg]) SET team.sec_sci_avg = apoc.coll.max([ s1.sec_sci_avg, s2.sec_sci_avg, s3.sec_sci_avg, s4.sec_sci_avg, s5.sec_sci_avg]) SET team.sec_med_avg = apoc.coll.max([ s1.sec_med_avg, s2.sec_med_avg, s3.sec_med_avg, s4.sec_med_avg, s5.sec_med_avg]) SET team.sec_sci_avg = apoc.coll.max([ s1.sec_sci_avg, s2.sec_sci_avg, s3.sec_sci_avg, s4.sec_sci_avg, s5.sec_sci_avg]) SET team.med_sci_avg = apoc.coll.max([ s1.med_sci_avg, s2.med_sci_avg, s3.med_sci_avg, s4.med_sci_avg, s5.med_sci_avg]);',
{batchSize: 1000, parallel: true, iterateList: true});

MATCH (g:GauntletAnalysis {username: 'jheinnic@hotmail.com', timestamp: 1515421483505})
MATCH(g)-[:FILTERED]->(s1:GauntletCrewCandidate) -[:FOLLOWS]->(s2:GauntletCrewCandidate)
       -[:FOLLOWS]->(s3:GauntletCrewCandidate) -[:FOLLOWS]->(s4:GauntletCrewCandidate)
       -[:FOLLOWS]->(s5:GauntletCrewCandidate)
RETURN s1, s2, s3, s4, s5;


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
        -[:FILTERED_PARTIAL]->(stale:GauntletPartialTeam)
//DETACH DELETE stale;
RETURN stale;


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

