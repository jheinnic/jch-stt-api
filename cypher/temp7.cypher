:param timestamp timestamp()
:param username "jheinnic@hotmail.com"
:param gauntletTraits [ "inspiring", "hero", "desperate" ]

//:begin
MATCH (g:GauntletAnalysis)-->(gt:GauntletTeam)
DETACH DELETE gt;

MATCH (g:GauntletAnalysis)-->(gc:GauntletCrewCandidate)
DETACH DELETE gc;

MATCH (g:GauntletAnalysis)
DETACH DELETE g;


// Prune all crew that score less than at least one other crew in all rounds.

//:begin
MATCH (player:Player {username: $username})-[e:ENLISTED]->(:CrewInstance)
WITH player, max(e.timestamp) AS latest
MATCH(player)-[e:ENLISTED {timestamp: latest}]->(ci:CrewInstance)-[:HAS_LEVEL]->(lvl:CrewLevel)
       -[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
  WHERE gt.id IN $gauntletTraits
WITH player, latest, ci, lvl, c, (1.05 + ((0.2) * count(gt))) AS stat_bonus
MERGE (player)-[:RAN_ANALYSIS]->(g:GauntletAnalysis {username: $username, timestamp: $timestamp, snapshot_from: latest})
MERGE (g)-[:OF_CANDIDATES]->(gci:GauntletCrewCandidate)-[:DERIVED_FROM]->(ci)
  ON CREATE SET
  gci.symbol = c.symbol,
  gci.rarity = lvl.rarity,
  gci.level = lvl.level,
  gci.cmd_dip = ((lvl.cmd_gavg + lvl.dip_gavg) * stat_bonus),
  gci.cmd_eng = ((lvl.cmd_gavg + lvl.eng_gavg) * stat_bonus),
  gci.cmd_sec = ((lvl.cmd_gavg + lvl.sec_gavg) * stat_bonus),
  gci.cmd_med = ((lvl.cmd_gavg + lvl.med_gavg) * stat_bonus),
  gci.cmd_sci = ((lvl.cmd_gavg + lvl.sci_gavg) * stat_bonus),
  gci.dip_eng = ((lvl.dip_gavg + lvl.eng_gavg) * stat_bonus),
  gci.dip_sec = ((lvl.dip_gavg + lvl.sec_gavg) * stat_bonus),
  gci.dip_med = ((lvl.dip_gavg + lvl.med_gavg) * stat_bonus),
  gci.dip_sci = ((lvl.dip_gavg + lvl.sci_gavg) * stat_bonus),
  gci.eng_sec = ((lvl.eng_gavg + lvl.sec_gavg) * stat_bonus),
  gci.eng_med = ((lvl.eng_gavg + lvl.med_gavg) * stat_bonus),
  gci.eng_sci = ((lvl.eng_gavg + lvl.sci_gavg) * stat_bonus),
  gci.sec_med = ((lvl.sec_gavg + lvl.med_gavg) * stat_bonus),
  gci.sec_sci = ((lvl.sec_gavg + lvl.sci_gavg) * stat_bonus),
  gci.med_sci = ((lvl.med_gavg + lvl.sci_gavg) * stat_bonus);

MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})-[:OF_CANDIDATES]->(gci:GauntletCrewCandidate)
WITH g, collect(gci) AS gci_all
UNWIND gci_all AS gci_seat_one
WITH g, gci_all, gci_seat_one, gci_seat_one {
.cmd_dip, .cmd_eng, .cmd_sec, .cmd_med, .cmd_sci,
.dip_eng, .dip_sec, .dip_med, .dip_sci,
.eng_sec, .eng_med, .eng_sci, .sec_med, .sec_sci, .med_sci
} AS g_team_one
WHERE none(gci_other IN gci_all
WHERE
(gci_seat_one <> gci_other) AND
(g_team_one.cmd_dip <= gci_other.cmd_dip) AND
(g_team_one.cmd_eng <= gci_other.cmd_eng) AND
(g_team_one.cmd_sec <= gci_other.cmd_sec) AND
(g_team_one.cmd_med <= gci_other.cmd_med) AND
(g_team_one.cmd_sci <= gci_other.cmd_sci) AND
(g_team_one.dip_eng <= gci_other.dip_eng) AND
(g_team_one.dip_sec <= gci_other.dip_sec) AND
(g_team_one.dip_med <= gci_other.dip_med) AND
(g_team_one.dip_sci <= gci_other.dip_sci) AND
(g_team_one.eng_sec <= gci_other.eng_sec) AND
(g_team_one.eng_med <= gci_other.eng_med) AND
(g_team_one.eng_sci <= gci_other.eng_sci) AND
(g_team_one.sec_med <= gci_other.sec_med) AND
(g_team_one.sec_sci <= gci_other.sec_sci) AND
(g_team_one.med_sci <= gci_other.med_sci)
)

CREATE (g)-[:SIZE_ONE]->(full_team:GauntletTeam)
SET full_team += g_team_one
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one)
RETURN full_team, gci_seat_one;


MATCH (g:GauntletAnalysis {username: $username, timestamp: $timestamp})-[:SIZE_ONE]->(g_team_one:GauntletTeam)
MATCH (g_team_one)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
WITH g, collect(gci_seat_one) AS gci_seats
UNWIND gci_seats AS gci_seat_one
WITH g, gci_seat_one, gci_seats
//WITH g, collect(gci) AS gci_all, gci AS gci_seat_one
UNWIND g, gci_seats AS gci_seat_two
//MATCH (g_team_one:GauntletTeam)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
WITH g, gci_seat_one, gci_seat_two, [gci_seat_two, gci_seat_one] AS temp_pair
  WHERE gci_seat_two.symbol > gci_seat_one.symbol
UNWIND temp_pair AS temp_team
WITH g, gci_seat_one, gci_seat_two, temp_team {
  cmd_dip:max(temp_team.cmd_dip),
  cmd_eng:max(temp_team.cmd_eng),
  cmd_sec:max(temp_team.cmd_sec),
  cmd_med:max(temp_team.cmd_med),
  cmd_sci:max(temp_team.cmd_sci),
  dip_eng:max(temp_team.dip_eng),
  dip_sec:max(temp_team.dip_sec),
  dip_med:max(temp_team.dip_med),
  dip_sci:max(temp_team.dip_sci),
  eng_sec:max(temp_team.eng_sec),
  eng_med:max(temp_team.eng_med),
  eng_sci:max(temp_team.eng_sci),
  sec_med:max(temp_team.sec_med),
  sec_sci:max(temp_team.sec_sci),
  med_sci:max(temp_team.med_sci)
} AS g_team_two
WITH g, gci_seat_one, gci_seat_two, g_team_two, collect(g_team_two) AS g_team_all
  WHERE none(gci_other IN g_team_all
    WHERE
    (g_team_two <> gci_other) AND
    (g_team_two.cmd_dip <= gci_other.cmd_dip) AND
    (g_team_two.cmd_eng <= gci_other.cmd_eng) AND
    (g_team_two.cmd_sec <= gci_other.cmd_sec) AND
    (g_team_two.cmd_med <= gci_other.cmd_med) AND
    (g_team_two.cmd_sci <= gci_other.cmd_sci) AND
    (g_team_two.dip_eng <= gci_other.dip_eng) AND
    (g_team_two.dip_sec <= gci_other.dip_sec) AND
    (g_team_two.dip_med <= gci_other.dip_med) AND
    (g_team_two.dip_sci <= gci_other.dip_sci) AND
    (g_team_two.eng_sec <= gci_other.eng_sec) AND
    (g_team_two.eng_med <= gci_other.eng_med) AND
    (g_team_two.eng_sci <= gci_other.eng_sci) AND
    (g_team_two.sec_med <= gci_other.sec_med) AND
    (g_team_two.sec_sci <= gci_other.sec_sci)
  )
CREATE (g)-[:SIZE_TWO]->(full_team:GauntletTeam)
SET full_team += g_team_two
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two)
RETURN full_team, gci_seat_one, gci_seat_two;


MATCH(g:GauntletAnalysis {username: $username, timestamp: $timestamp})-[:SIZE_ONE]->(g_team_one:GauntletTeam)
       -[:PLAYS_CANDIDATE {slot: 1}]->(gci:GauntletCrewCandidate)
WITH g, g_team_one, collect(gci) AS gci_all
UNWIND gci_all AS gci_seat_three
MATCH(g)-[:SIZE_TWO]->(g_team_two:GauntletTeam)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
MATCH(g)-[:SIZE_TWO]->(g_team_two:GauntletTeam)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two:GauntletCrewCandidate)
WITH  gci_all, gci_seat_one, gci_seat_two, gci_seat_three, g_team_two, [gci_seat_three, g_team_two] AS temp_pair
  WHERE gci_seat_three.symbol > gci_seat_two.symbol
UNWIND temp_pair AS temp_team
WITH  gci_all, gci_seat_one, gci_seat_two, gci_seat_three, g_team_two, temp_team {
  cmd_dip:max(temp_team.cmd_dip),
  cmd_eng:max(temp_team.cmd_eng),
  cmd_sec:max(temp_team.cmd_sec),
  cmd_med:max(temp_team.cmd_med),
  cmd_sci:max(temp_team.cmd_sci),
  dip_eng:max(temp_team.dip_eng),
  dip_sec:max(temp_team.dip_sec),
  dip_med:max(temp_team.dip_med),
  dip_sci:max(temp_team.dip_sci),
  eng_sec:max(temp_team.eng_sec),
  eng_med:max(temp_team.eng_med),
  eng_sci:max(temp_team.eng_sci),
  sec_med:max(temp_team.sec_med),
  sec_sci:max(temp_team.sec_sci),
  med_sci:max(temp_team.med_sci)
} AS g_team_three
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, g_team_three, collect(g_team_three) AS g_team_all
  WHERE none(gci_other IN g_team_all
    WHERE
    (g_team_three <> gci_other) AND
    (g_team_three.cmd_dip <= gci_other.cmd_dip) AND
    (g_team_three.cmd_eng <= gci_other.cmd_eng) AND
    (g_team_three.cmd_sec <= gci_other.cmd_sec) AND
    (g_team_three.cmd_med <= gci_other.cmd_med) AND
    (g_team_three.cmd_sci <= gci_other.cmd_sci) AND
    (g_team_three.dip_eng <= gci_other.dip_eng) AND
    (g_team_three.dip_sec <= gci_other.dip_sec) AND
    (g_team_three.dip_med <= gci_other.dip_med) AND
    (g_team_three.dip_sci <= gci_other.dip_sci) AND
    (g_team_three.eng_sec <= gci_other.eng_sec) AND
    (g_team_three.eng_med <= gci_other.eng_med) AND
    (g_team_three.eng_sci <= gci_other.eng_sci) AND
    (g_team_three.sec_med <= gci_other.sec_med) AND
    (g_team_three.sec_sci <= gci_other.sec_sci)
  )
CREATE (g)-[:SIZE_THREE]->(full_team:GauntletTeam)
SET full_team += g_team_three
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 3}]->(gci_seat_three)
RETURN full_team, gci_seat_one, gci_seat_two, gci_seat_three;


MATCH(g:GauntletAnalysis {username: $username, timestamp: $timestamp})-[:SIZE_ONE]->(g_team_one:GauntletTeam)
       -[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
WITH g, collect(gci_seat_one) AS gci_all
UNWIND gci_all AS gci_seat_four
MATCH (g)-[:SIZE_THREE]->(g_team_three:GauntletTeam)
MATCH (g_team_three)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
MATCH (g_team_three)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two:GauntletCrewCandidate)
MATCH (g_team_three)-[:PLAYS_CANDIDATE {slot: 3}]->(gci_seat_three:GauntletCrewCandidate)
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, g_team_three,
     [gci_seat_four, g_team_three] AS temp_pair
  WHERE gci_seat_four.symbol > gci_seat_three.symbol
UNWIND temp_pair AS temp_team
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, g_team_three, temp_team {
  cmd_dip:max(temp_team.cmd_dip),
  cmd_eng:max(temp_team.cmd_eng),
  cmd_sec:max(temp_team.cmd_sec),
  cmd_med:max(temp_team.cmd_med),
  cmd_sci:max(temp_team.cmd_sci),
  dip_eng:max(temp_team.dip_eng),
  dip_sec:max(temp_team.dip_sec),
  dip_med:max(temp_team.dip_med),
  dip_sci:max(temp_team.dip_sci),
  eng_sec:max(temp_team.eng_sec),
  eng_med:max(temp_team.eng_med),
  eng_sci:max(temp_team.eng_sci),
  sec_med:max(temp_team.sec_med),
  sec_sci:max(temp_team.sec_sci),
  med_sci:max(temp_team.med_sci)
} AS g_team_four
WITH
  g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, g_team_four, collect(g_team_four) AS g_team_all
  WHERE none(gci_other IN g_team_all
    WHERE
    (g_team_four <> gci_other) AND
    (g_team_four.cmd_dip <= gci_other.cmd_dip) AND
    (g_team_four.cmd_eng <= gci_other.cmd_eng) AND
    (g_team_four.cmd_sec <= gci_other.cmd_sec) AND
    (g_team_four.cmd_med <= gci_other.cmd_med) AND
    (g_team_four.cmd_sci <= gci_other.cmd_sci) AND
    (g_team_four.dip_eng <= gci_other.dip_eng) AND
    (g_team_four.dip_sec <= gci_other.dip_sec) AND
    (g_team_four.dip_med <= gci_other.dip_med) AND
    (g_team_four.dip_sci <= gci_other.dip_sci) AND
    (g_team_four.eng_sec <= gci_other.eng_sec) AND
    (g_team_four.eng_med <= gci_other.eng_med) AND
    (g_team_four.eng_sci <= gci_other.eng_sci) AND
    (g_team_four.sec_med <= gci_other.sec_med) AND
    (g_team_four.sec_sci <= gci_other.sec_sci)
  )
CREATE (g)-[:SIZE_FOUR]->(full_team:GauntletTeam)
SET full_team += g_team_four
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 3}]->(gci_seat_three)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 4}]->(gci_seat_four)
RETURN full_team, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four;

MATCH(g:GauntletAnalysis {username: $username, timestamp: $timestamp})-[:SIZE_ONE]->(g_team_one:GauntletTeam)
       -[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
WITH g, collect(gci_seat_one) AS gci_all
UNWIND gci_all AS gci_seat_five
MATCH (g)-[:SIZE_FOUR]->(g_team_four:GauntletTeam)
MATCH (g_team_four)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one:GauntletCrewCandidate)
MATCH (g_team_four)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two:GauntletCrewCandidate)
MATCH (g_team_four)-[:PLAYS_CANDIDATE {slot: 3}]->(gci_seat_three:GauntletCrewCandidate)
MATCH (g_team_four)-[:PLAYS_CANDIDATE {slot: 4}]->(gci_seat_four:GauntletCrewCandidate)
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, gci_seat_five, g_team_four,
     [gci_seat_five, g_team_four] AS temp_pair
  WHERE gci_seat_four.symbol > gci_seat_three.symbol
UNWIND temp_pair AS temp_team
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, gci_seat_five, g_team_four, temp_team {
  cmd_dip:max(temp_team.cmd_dip),
  cmd_eng:max(temp_team.cmd_eng),
  cmd_sec:max(temp_team.cmd_sec),
  cmd_med:max(temp_team.cmd_med),
  cmd_sci:max(temp_team.cmd_sci),
  dip_eng:max(temp_team.dip_eng),
  dip_sec:max(temp_team.dip_sec),
  dip_med:max(temp_team.dip_med),
  dip_sci:max(temp_team.dip_sci),
  eng_sec:max(temp_team.eng_sec),
  eng_med:max(temp_team.eng_med),
  eng_sci:max(temp_team.eng_sci),
  sec_med:max(temp_team.sec_med),
  sec_sci:max(temp_team.sec_sci),
  med_sci:max(temp_team.med_sci)
} AS g_team_five
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, gci_seat_five, g_team_five,
     collect(g_team_five) AS g_team_all
  WHERE none(gci_other IN gci_all
    WHERE // Prune all crew that score less than at least one other crew in all rounds.
    (g_team_five <> gci_other) AND
    (g_team_five.cmd_dip <= gci_other.cmd_dip) AND
    (g_team_five.cmd_eng <= gci_other.cmd_eng) AND
    (g_team_five.cmd_sec <= gci_other.cmd_sec) AND
    (g_team_five.cmd_med <= gci_other.cmd_med) AND
    (g_team_five.cmd_sci <= gci_other.cmd_sci) AND
    (g_team_five.dip_eng <= gci_other.dip_eng) AND
    (g_team_five.dip_sec <= gci_other.dip_sec) AND
    (g_team_five.dip_med <= gci_other.dip_med) AND
    (g_team_five.dip_sci <= gci_other.dip_sci) AND
    (g_team_five.eng_sec <= gci_other.eng_sec) AND
    (g_team_five.eng_med <= gci_other.eng_med) AND
    (g_team_five.eng_sci <= gci_other.eng_sci) AND
    (g_team_five.sec_med <= gci_other.sec_med) AND
    (g_team_five.sec_sci <= gci_other.sec_sci)
  )
CREATE (g)-[:IDEAL_TEAMS]->(full_team:GauntletTeam)
SET full_team += g_team_five
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 3}]->(gci_seat_three)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 4}]->(gci_seat_four)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 5}]->(gci_seat_five)
RETURN full_team, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, gci_seat_five;
//:commit


//MERGE (g)-[:FILTERS {size: 1}]->(gt:GauntletTeam)-[:USES_CREW {slot: 1}]->(gci)
//  ON CREATE SET gt += gci
//RETURN g, gt, gci;
