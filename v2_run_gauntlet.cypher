:param username "jheinnic@hotmail.com"
:param traits ["undercover operative", "brutal", "borg"]
:param skill "sci"
:param timestamp timestamp()

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
MATCH (g)
        -[:BUILDING {size: 1}]->(base: GauntletTeam)
        -[:INCLUDES]->(assigned:GauntletCrew)
        -[:FOLLOWED_BY]->(candidate:GauntletCrew)
CREATE (g)-[:NEXT_TIER {size: 2}]->(team:GauntletTeam)
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
SET team.eng_sci = apoc.coll.max([base.eng_sci, candidate.eng_sci])
SET team.sec_med = apoc.coll.max([base.sec_med, candidate.sec_med])
SET team.sec_sci = apoc.coll.max([base.sec_sci, candidate.sec_sci])
SET team.med_sci = apoc.coll.max([base.med_sci, candidate.med_sci]);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 2}]->(candidate:GauntletTeam)
WHERE none(
  gci_other IN [
  (g)-[:NEXT_TIER {size: 2}]->(other:GauntletTeam)
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
CREATE (g)-[:BUILDING {size: 2}]->(candidate);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 2}]->(candidate:GauntletTeam)
WHERE NOT (g)-[:BUILDING {size: 2}]->(candidate)
DETACH DELETE candidate;

// Find Team Size 3

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)
        -[:BUILDING {size: 2}]->(base: GauntletTeam)
        -[:INCLUDES]->(assigned:GauntletCrew)
        -[:FOLLOWED_BY]->(candidate:GauntletCrew)
CREATE (g)-[:NEXT_TIER {size: 3}]->(team:GauntletTeam)
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
SET team.eng_sci = apoc.coll.max([base.eng_sci, candidate.eng_sci])
SET team.sec_med = apoc.coll.max([base.sec_med, candidate.sec_med])
SET team.sec_sci = apoc.coll.max([base.sec_sci, candidate.sec_sci])
SET team.med_sci = apoc.coll.max([base.med_sci, candidate.med_sci]);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 3}]->(candidate:GauntletTeam)
WHERE none(
  gci_other IN [
  (g)-[:NEXT_TIER {size: 3}]->(other:GauntletTeam)
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
CREATE (g)-[:BUILDING {size: 3}]->(candidate);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 3}]->(candidate:GauntletTeam)
WHERE NOT (g)-[:BUILDING {size: 3}]->(candidate)
DETACH DELETE candidate;

// Find Team Size 4

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)
        -[:BUILDING {size: 3}]->(base: GauntletTeam)
        -[:INCLUDES]->(assigned:GauntletCrew)
        -[:FOLLOWED_BY]->(candidate:GauntletCrew)
CREATE (g)-[:NEXT_TIER {size: 4}]->(team:GauntletTeam)
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
SET team.eng_sci = apoc.coll.max([base.eng_sci, candidate.eng_sci])
SET team.sec_med = apoc.coll.max([base.sec_med, candidate.sec_med])
SET team.sec_sci = apoc.coll.max([base.sec_sci, candidate.sec_sci])
SET team.med_sci = apoc.coll.max([base.med_sci, candidate.med_sci]);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 4}]->(candidate:GauntletTeam)
WHERE none(
  gci_other IN [
  (g)-[:NEXT_TIER {size: 4}]->(other:GauntletTeam)
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
CREATE (g)-[:BUILDING {size: 4}]->(candidate);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 4}]->(candidate:GauntletTeam)
WHERE NOT (g)-[:BUILDING {size: 4}]->(candidate)
DETACH DELETE candidate;

// Find Team Size 5

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)
        -[:BUILDING {size: 4}]->(base: GauntletTeam)
        -[:INCLUDES]->(assigned:GauntletCrew)
        -[:FOLLOWED_BY]->(candidate:GauntletCrew)
CREATE (g)-[:NEXT_TIER {size: 5}]->(team:GauntletTeam)
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
SET team.eng_sci = apoc.coll.max([base.eng_sci, candidate.eng_sci])
SET team.sec_med = apoc.coll.max([base.sec_med, candidate.sec_med])
SET team.sec_sci = apoc.coll.max([base.sec_sci, candidate.sec_sci])
SET team.med_sci = apoc.coll.max([base.med_sci, candidate.med_sci]);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 5}]->(candidate:GauntletTeam)
WHERE none(
  gci_other IN [
  (g)-[:NEXT_TIER {size: 5}]->(other:GauntletTeam)
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
CREATE (g)-[:BUILDING {size: 5}]->(candidate);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:NEXT_TIER {size: 5}]->(candidate:GauntletTeam)
WHERE NOT (g)-[:BUILDING {size: 5}]->(candidate)
DETACH DELETE candidate;

// Report on results!

/*
// MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g:GauntletAnalysis)
MATCH (g)-[:BUILDING {size: 5}]->(candidate:GauntletTeam)
WITH [
  gci_other IN [
  (g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
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
    (gci_other.med_sci >= candidate.med_sci) | gci_other
] as others, candidate
RETURN candidate, size(others), others[0];
*/

MATCH(g:GauntletAnalysis)-[b:BUILDING]->(t:GauntletTeam)
RETURN b.size, count(t);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})
MATCH (g)-[:BUILDING {size: 5}]->(slot5:GauntletTeam)
       -[:BASED_ON]->(slot4:GauntletTeam)
       -[:BASED_ON]->(slot3:GauntletTeam)
       -[:BASED_ON]->(slot2:GauntletTeam)
       -[:BASED_ON]->(slot1:GauntletTeam)
MATCH (slot5)-[:INCLUDES]->(c5:GauntletCrew)
MATCH (slot4)-[:INCLUDES]->(c4:GauntletCrew)
MATCH (slot3)-[:INCLUDES]->(c3:GauntletCrew)
MATCH (slot2)-[:INCLUDES]->(c2:GauntletCrew)
MATCH (slot1)-[:INCLUDES]->(c1:GauntletCrew)
WITH slot5, c1, c2, c3, c4, c5,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.cmd_dip > slot5.cmd_dip) | other]) as cmd_dip_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.cmd_eng > slot5.cmd_eng) | other]) as cmd_eng_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.cmd_sec > slot5.cmd_sec) | other]) as cmd_sec_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.cmd_med > slot5.cmd_med) | other]) as cmd_med_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.cmd_sci > slot5.cmd_sci) | other]) as cmd_sci_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.dip_eng > slot5.dip_eng) | other]) as dip_eng_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.dip_sec > slot5.dip_sec) | other]) as dip_sec_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.dip_med > slot5.dip_med) | other]) as dip_med_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.dip_sci > slot5.dip_sci) | other]) as dip_sci_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.eng_sec > slot5.eng_sec) | other]) as eng_sec_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.eng_med > slot5.eng_med) | other]) as eng_med_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.eng_sci > slot5.eng_sci) | other]) as eng_sci_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.sec_med > slot5.sec_med) | other]) as sec_med_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.sec_sci > slot5.sec_sci) | other]) as sec_sci_nlt,
     size([(g)-[:BUILDING {size: 5}]->(other:GauntletTeam)
       WHERE (other.med_sci > slot5.med_sci) | other]) as med_sci_nlt,
     apoc.coll.min([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci,
       slot5.dip_eng, slot5.dip_sec, slot5.dip_med, slot5.dip_sci, slot5.eng_sec,
       slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci]) AS all_min,
     CASE $skill WHEN 'cmd' THEN apoc.coll.min([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci])
       WHEN 'dip' THEN apoc.coll.min([
       slot5.cmd_dip, slot5.dip_eng, slot5.dip_sec, slot5.dip_med, slot5.dip_sci])
       WHEN 'eng' THEN apoc.coll.min([
       slot5.cmd_eng, slot5.dip_eng, slot5.eng_sec, slot5.eng_med, slot5.eng_sci])
       WHEN 'sec' THEN apoc.coll.min([
       slot5.cmd_sec, slot5.dip_sec, slot5.eng_sec, slot5.sec_med, slot5.sec_sci])
       WHEN 'med' THEN apoc.coll.min([
       slot5.cmd_med, slot5.dip_med, slot5.eng_med, slot5.sec_med, slot5.med_sci])
       WHEN 'sci' THEN apoc.coll.min([
       slot5.cmd_sci, slot5.dip_sci, slot5.eng_sci, slot5.sec_sci, slot5.med_sci])
       END AS skill_min,
     CASE $skill WHEN 'cmd' THEN apoc.coll.avg([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
       slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci])
     WHEN 'dip' THEN apoc.coll.avg([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
       slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
       slot5.cmd_dip, slot5.dip_eng, slot5.dip_sec, slot5.dip_med, slot5.dip_sci])
     WHEN 'eng' THEN apoc.coll.avg([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
       slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
       slot5.cmd_eng, slot5.dip_eng, slot5.eng_sec, slot5.eng_med, slot5.eng_sci])
     WHEN 'sec' THEN apoc.coll.avg([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
       slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
       slot5.cmd_sec, slot5.dip_sec, slot5.eng_sec, slot5.sec_med, slot5.sec_sci])
     WHEN 'med' THEN apoc.coll.avg([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
       slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
       slot5.cmd_med, slot5.dip_med, slot5.eng_med, slot5.sec_med, slot5.med_sci])
     WHEN 'sci' THEN apoc.coll.avg([
       slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
       slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
       slot5.cmd_sci, slot5.dip_sci, slot5.eng_sci, slot5.sec_sci, slot5.med_sci])
     END AS biased_avg
RETURN
(slot5.cmd_dip + slot5.cmd_eng + slot5.cmd_sec + slot5.cmd_med + slot5.cmd_sci + slot5.dip_eng + slot5.dip_sec +
slot5.dip_med + slot5.dip_sci + slot5.eng_sec + slot5.eng_med + slot5.eng_sci + slot5.sec_med + slot5.sec_sci + slot5.med_sci) AS all_sum,
biased_avg, skill_min, all_min,
c5.symbol, c4.symbol, c3.symbol, c2.symbol, c1.symbol,
slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci,
slot5.dip_eng, slot5.dip_sec, slot5.dip_med, slot5.dip_sci, slot5.eng_sec,
slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci, slot5.med_sci,
  cmd_dip_nlt, cmd_eng_nlt, cmd_sec_nlt, cmd_med_nlt, cmd_sci_nlt,
  dip_eng_nlt, dip_sec_nlt, dip_med_nlt, dip_sci_nlt, eng_sec_nlt,
  eng_med_nlt, eng_sci_nlt, sec_med_nlt, sec_sci_nlt, med_sci_nlt,
(cmd_dip_nlt + cmd_eng_nlt + cmd_sec_nlt + cmd_med_nlt + cmd_sci_nlt +
 dip_eng_nlt + dip_sec_nlt + dip_med_nlt + dip_sci_nlt + eng_sec_nlt +
 eng_med_nlt + eng_sci_nlt + sec_med_nlt + sec_sci_nlt + med_sci_nlt) AS any_nlt,
CASE $skill
  WHEN 'cmd' THEN (cmd_dip_nlt + cmd_eng_nlt + cmd_sec_nlt + cmd_med_nlt + cmd_sci_nlt)
  WHEN 'dip' THEN (cmd_dip_nlt + dip_eng_nlt + dip_sec_nlt + dip_med_nlt + dip_sci_nlt)
  WHEN 'eng' THEN (cmd_eng_nlt + dip_eng_nlt + eng_sec_nlt + eng_med_nlt + eng_sci_nlt)
  WHEN 'sec' THEN (cmd_sec_nlt + dip_sec_nlt + eng_sec_nlt + sec_med_nlt + sec_sci_nlt)
  WHEN 'med' THEN (cmd_med_nlt + dip_med_nlt + eng_med_nlt + sec_med_nlt + med_sci_nlt)
  WHEN 'sci' THEN (cmd_sci_nlt + dip_sci_nlt + eng_sci_nlt + sec_sci_nlt + med_sci_nlt)
END AS skill_nlt,
(c1.cmd_dip + c2.cmd_dip + c3.cmd_dip + c4.cmd_dip + c5.cmd_dip) AS sum_cmd_dip,
(c1.cmd_eng + c2.cmd_eng + c3.cmd_eng + c4.cmd_eng + c5.cmd_eng) AS sum_cmd_eng,
(c1.cmd_sec + c2.cmd_sec + c3.cmd_sec + c4.cmd_sec + c5.cmd_sec) AS sum_cmd_sec,
(c1.cmd_med + c2.cmd_med + c3.cmd_med + c4.cmd_med + c5.cmd_med) AS sum_cmd_med,
(c1.cmd_sci + c2.cmd_sci + c3.cmd_sci + c4.cmd_sci + c5.cmd_sci) AS sum_cmd_sci,
(c1.dip_eng + c2.dip_eng + c3.dip_eng + c4.dip_eng + c5.dip_eng) AS sum_dip_eng,
(c1.dip_sec + c2.dip_sec + c3.dip_sec + c4.dip_sec + c5.dip_sec) AS sum_dip_sec,
(c1.dip_med + c2.dip_med + c3.dip_med + c4.dip_med + c5.dip_med) AS sum_dip_med,
(c1.dip_sci + c2.dip_sci + c3.dip_sci + c4.dip_sci + c5.dip_sci) AS sum_dip_sci,
(c1.eng_sec + c2.eng_sec + c3.eng_sec + c4.eng_sec + c5.eng_sec) AS sum_eng_sec,
(c1.eng_med + c2.eng_med + c3.eng_med + c4.eng_med + c5.eng_med) AS sum_eng_med,
(c1.eng_sci + c2.eng_sci + c3.eng_sci + c4.eng_sci + c5.eng_sci) AS sum_eng_sci,
(c1.sec_med + c2.sec_med + c3.sec_med + c4.sec_med + c5.sec_med) AS sum_sec_med,
(c1.sec_sci + c2.sec_sci + c3.sec_sci + c4.sec_sci + c5.sec_sci) AS sum_sec_sci,
(c1.med_sci + c2.med_sci + c3.med_sci + c4.med_sci + c5.med_sci) AS sum_med_sci
ORDER BY
(biased_avg+apoc.coll.avg([all_min+skill_min])) DESCENDING,
all_min DESCENDING,
biased_avg DESCENDING,
skill_min DESCENDING,
(biased_avg/(skill_nlt + any_nlt)) DESCENDING,
(skill_nlt + any_nlt) ASCENDING,
apoc.coll.avg([cmd_dip_nlt, cmd_eng_nlt, cmd_sec_nlt, cmd_med_nlt, cmd_sci_nlt, dip_eng_nlt, dip_sec_nlt, dip_med_nlt, dip_sci_nlt, eng_sec_nlt, eng_med_nlt, eng_sci_nlt, sec_med_nlt, sec_sci_nlt, med_sci_nlt]) ASCENDING,
all_sum DESCENDING, skill_nlt ASCENDING, any_nlt ASCENDING;

