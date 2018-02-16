//:param timestamp timestamp()
//:param username "jheinnic@hotmail.com"
//:param gauntletTraits [ "inspiring", "hero", "desperate" ]

//:begin
//MATCH (g:GauntletAnalysis)-->(gt:GauntletTeam)
//DETACH DELETE gt;
//MATCH (g:GauntletAnalysis)-->(gc:GauntletCrewCandidate)
//DETACH DELETE gc;
//MATCH (g:GauntletAnalysis)
//DETACH DELETE g;


// Prune all crew that score less than at least one other crew in all rounds.

//:begin
MATCH (player:Player {username: $username})-[e:ENLISTED]->(:CrewInstance)
WITH player, max(e.timestamp) AS latest
MATCH (player)-[e:ENLISTED {timestamp: latest}]->(ci:CrewInstance)-[:HAS_LEVEL]->(lvl:CrewLevel)-[:IS_LEVEL_FOR]->(c:CrewIdentity)
OPTIONAL MATCH (c)-[:HAS_TRAIT]->(gt:Trait)
WHERE gt.id IN $gauntletTraits
WITH player, latest, ci, lvl, c, (1.05 + ((0.2) * count(gt))) AS stat_bonus
MERGE (player)-[:RAN_ANALYSIS {timestamp: $timestamp}]->(g:GauntletAnalysis)-[:FOR_CANDIDATES]->(gci: GauntletCrewCandidate)-[:FROM_SNAPSHOT {timestamp: latest}]->(ci)
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
    gci.med_sci = ((lvl.med_gavg + lvl.sci_gavg) * stat_bonus)
WITH collect(gci) AS gci_all, player
MATCH (player)-[:RAN_ANALYSIS {timestamp: $timestamp}]->(g:GauntletAnalysis)-[:FOR_CANDIDATES]->(gci: GauntletCrewCandidate)
WITH g, gci, gci_all
WHERE none(gci_other IN gci_all WHERE
        (gci <> gci_other) AND
        (gci.cmd_dip <= gci_other.cmd_dip) AND
        (gci.cmd_eng <= gci_other.cmd_eng) AND
        (gci.cmd_sec <= gci_other.cmd_sec) AND
        (gci.cmd_med <= gci_other.cmd_med) AND
        (gci.cmd_sci <= gci_other.cmd_sci) AND
        (gci.dip_eng <= gci_other.dip_eng) AND
        (gci.dip_sec <= gci_other.dip_sec) AND
        (gci.dip_med <= gci_other.dip_med) AND
        (gci.dip_sci <= gci_other.dip_sci) AND
        (gci.eng_sec <= gci_other.eng_sec) AND
        (gci.eng_med <= gci_other.eng_med) AND
        (gci.eng_sci <= gci_other.eng_sci) AND
        (gci.sec_med <= gci_other.sec_med) AND
        (gci.sec_sci <= gci_other.sec_sci) AND
        (gci.med_sci <= gci_other.med_sci)
)
MERGE (g)-[:FILTERS {size: 1}]->(gt:GauntletTeam)-[:USES_CREW {slot: 1}]->(gci)
ON CREATE SET gt += gci
RETURN g, gt, gci;

/*
UNWIND gci_all AS gci_seat_two
WITH g, gci_all, gci_seat_one, team_one, gci_seat_two, {
        cmd_dip: CASE (gci_seat_two.cmd_dip >= team_one.cmd_dip) WHEN true THEN gci_seat_two.cmd_dip ELSE team_one.cmd_dip END,
        cmd_eng: CASE (gci_seat_two.cmd_eng >= team_one.cmd_eng) WHEN true THEN gci_seat_two.cmd_eng ELSE team_one.cmd_eng END,
        cmd_sec: CASE (gci_seat_two.cmd_sec >= team_one.cmd_sec) WHEN true THEN gci_seat_two.cmd_sec ELSE team_one.cmd_sec END,
        cmd_med: CASE (gci_seat_two.cmd_med >= team_one.cmd_med) WHEN true THEN gci_seat_two.cmd_med ELSE team_one.cmd_med END,
        cmd_sci: CASE (gci_seat_two.cmd_sci >= team_one.cmd_sci) WHEN true THEN gci_seat_two.cmd_sci ELSE team_one.cmd_sci END,
        dip_eng: CASE (gci_seat_two.dip_eng >= team_one.dip_eng) WHEN true THEN gci_seat_two.dip_eng ELSE team_one.dip_eng END,
        dip_sec: CASE (gci_seat_two.dip_sec >= team_one.dip_sec) WHEN true THEN gci_seat_two.dip_sec ELSE team_one.dip_sec END,
        dip_med: CASE (gci_seat_two.dip_med >= team_one.dip_med) WHEN true THEN gci_seat_two.dip_med ELSE team_one.dip_med END,
        dip_sci: CASE (gci_seat_two.dip_sci >= team_one.dip_sci) WHEN true THEN gci_seat_two.dip_sci ELSE team_one.dip_sci END,
        eng_sec: CASE (gci_seat_two.eng_sec >= team_one.eng_sec) WHEN true THEN gci_seat_two.eng_sec ELSE team_one.eng_sec END,
        eng_med: CASE (gci_seat_two.eng_med >= team_one.eng_med) WHEN true THEN gci_seat_two.eng_med ELSE team_one.eng_med END,
        eng_sci: CASE (gci_seat_two.eng_sci >= team_one.eng_sci) WHEN true THEN gci_seat_two.eng_sci ELSE team_one.eng_sci END,
        sec_med: CASE (gci_seat_two.sec_med >= team_one.sec_med) WHEN true THEN gci_seat_two.sec_med ELSE team_one.sec_med END,
        sec_sci: CASE (gci_seat_two.sec_sci >= team_one.sec_sci) WHEN true THEN gci_seat_two.sec_sci ELSE team_one.sec_sci END,
        med_sci: CASE (gci_seat_two.med_sci >= team_one.med_sci) WHEN true THEN gci_seat_two.med_sci ELSE team_one.med_sci END
} AS team_two
  WHERE none(gci_other IN gci_all WHERE // Prune all crew that score less than at least one other crew in all rounds.
    (gci_seat_one <> gci_other) AND (gci_seat_two <> gci_other) AND
    (team_two.cmd_dip <= gci_other.cmd_dip) AND (team_two.cmd_dip <= team_one.cmd_dip) AND
    (team_two.cmd_eng <= gci_other.cmd_eng) AND (team_two.cmd_eng <= team_one.cmd_eng) AND
    (team_two.cmd_sec <= gci_other.cmd_sec) AND (team_two.cmd_sec <= team_one.cmd_sec) AND
    (team_two.cmd_med <= gci_other.cmd_med) AND (team_two.cmd_med <= team_one.cmd_med) AND
    (team_two.cmd_sci <= gci_other.cmd_sci) AND (team_two.cmd_sci <= team_one.cmd_sci) AND
    (team_two.dip_eng <= gci_other.dip_eng) AND (team_two.dip_eng <= team_one.dip_eng) AND
    (team_two.dip_sec <= gci_other.dip_sec) AND (team_two.dip_sec <= team_one.dip_sec) AND
    (team_two.dip_med <= gci_other.dip_med) AND (team_two.dip_med <= team_one.dip_med) AND
    (team_two.dip_sci <= gci_other.dip_sci) AND (team_two.dip_sci <= team_one.dip_sci) AND
    (team_two.eng_sec <= gci_other.eng_sec) AND (team_two.eng_sec <= team_one.eng_sec) AND
    (team_two.eng_med <= gci_other.eng_med) AND (team_two.eng_med <= team_one.eng_med) AND
    (team_two.eng_sci <= gci_other.eng_sci) AND (team_two.eng_sci <= team_one.eng_sci) AND
    (team_two.sec_med <= gci_other.sec_med) AND (team_two.sec_med <= team_one.sec_med) AND
    (team_two.sec_sci <= gci_other.sec_sci) AND (team_two.sec_sci <= team_one.sec_sci)
  )
UNWIND gci_all AS gci_seat_three
WITH g, gci_all, gci_seat_one, gci_seat_two, team_two, gci_seat_three, {
        cmd_dip: CASE (gci_seat_three.cmd_dip >= team_two.cmd_dip) WHEN true THEN gci_seat_three.cmd_dip ELSE team_two.cmd_dip END,
        cmd_eng: CASE (gci_seat_three.cmd_eng >= team_two.cmd_eng) WHEN true THEN gci_seat_three.cmd_eng ELSE team_two.cmd_eng END,
        cmd_sec: CASE (gci_seat_three.cmd_sec >= team_two.cmd_sec) WHEN true THEN gci_seat_three.cmd_sec ELSE team_two.cmd_sec END,
        cmd_med: CASE (gci_seat_three.cmd_med >= team_two.cmd_med) WHEN true THEN gci_seat_three.cmd_med ELSE team_two.cmd_med END,
        cmd_sci: CASE (gci_seat_three.cmd_sci >= team_two.cmd_sci) WHEN true THEN gci_seat_three.cmd_sci ELSE team_two.cmd_sci END,
        dip_eng: CASE (gci_seat_three.dip_eng >= team_two.dip_eng) WHEN true THEN gci_seat_three.dip_eng ELSE team_two.dip_eng END,
        dip_sec: CASE (gci_seat_three.dip_sec >= team_two.dip_sec) WHEN true THEN gci_seat_three.dip_sec ELSE team_two.dip_sec END,
        dip_med: CASE (gci_seat_three.dip_med >= team_two.dip_med) WHEN true THEN gci_seat_three.dip_med ELSE team_two.dip_med END,
        dip_sci: CASE (gci_seat_three.dip_sci >= team_two.dip_sci) WHEN true THEN gci_seat_three.dip_sci ELSE team_two.dip_sci END,
        eng_sec: CASE (gci_seat_three.eng_sec >= team_two.eng_sec) WHEN true THEN gci_seat_three.eng_sec ELSE team_two.eng_sec END,
        eng_med: CASE (gci_seat_three.eng_med >= team_two.eng_med) WHEN true THEN gci_seat_three.eng_med ELSE team_two.eng_med END,
        eng_sci: CASE (gci_seat_three.eng_sci >= team_two.eng_sci) WHEN true THEN gci_seat_three.eng_sci ELSE team_two.eng_sci END,
        sec_med: CASE (gci_seat_three.sec_med >= team_two.sec_med) WHEN true THEN gci_seat_three.sec_med ELSE team_two.sec_med END,
        sec_sci: CASE (gci_seat_three.sec_sci >= team_two.sec_sci) WHEN true THEN gci_seat_three.sec_sci ELSE team_two.sec_sci END,
        med_sci: CASE (gci_seat_three.med_sci >= team_two.med_sci) WHEN true THEN gci_seat_three.med_sci ELSE team_two.med_sci END
} AS team_three
  WHERE none(gci_other IN gci_all
    WHERE // Prune all crew that score less than at least one other crew in all rounds.
    (gci_seat_two <> gci_other) AND (gci_seat_three <> gci_other) AND (gci_seat_three <> gci_other) AND
    (team_three.cmd_dip <= gci_other.cmd_dip) AND (team_three.cmd_dip <= team_two.cmd_dip) AND
    (team_three.cmd_eng <= gci_other.cmd_eng) AND (team_three.cmd_eng <= team_two.cmd_eng) AND
    (team_three.cmd_sec <= gci_other.cmd_sec) AND (team_three.cmd_sec <= team_two.cmd_sec) AND
    (team_three.cmd_med <= gci_other.cmd_med) AND (team_three.cmd_med <= team_two.cmd_med) AND
    (team_three.cmd_sci <= gci_other.cmd_sci) AND (team_three.cmd_sci <= team_two.cmd_sci) AND
    (team_three.dip_eng <= gci_other.dip_eng) AND (team_three.dip_eng <= team_two.dip_eng) AND
    (team_three.dip_sec <= gci_other.dip_sec) AND (team_three.dip_sec <= team_two.dip_sec) AND
    (team_three.dip_med <= gci_other.dip_med) AND (team_three.dip_med <= team_two.dip_med) AND
    (team_three.dip_sci <= gci_other.dip_sci) AND (team_three.dip_sci <= team_two.dip_sci) AND
    (team_three.eng_sec <= gci_other.eng_sec) AND (team_three.eng_sec <= team_two.eng_sec) AND
    (team_three.eng_med <= gci_other.eng_med) AND (team_three.eng_med <= team_two.eng_med) AND
    (team_three.eng_sci <= gci_other.eng_sci) AND (team_three.eng_sci <= team_two.eng_sci) AND
    (team_three.sec_med <= gci_other.sec_med) AND (team_three.sec_med <= team_two.sec_med) AND
    (team_three.sec_sci <= gci_other.sec_sci) AND (team_three.sec_sci <= team_two.sec_sci)
  )
UNWIND gci_all AS gci_seat_four
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, team_three, gci_seat_four, {
        cmd_dip: CASE (gci_seat_four.cmd_dip >= team_three.cmd_dip) WHEN true THEN gci_seat_four.cmd_dip ELSE team_three.cmd_dip END,
        cmd_eng: CASE (gci_seat_four.cmd_eng >= team_three.cmd_eng) WHEN true THEN gci_seat_four.cmd_eng ELSE team_three.cmd_eng END,
        cmd_sec: CASE (gci_seat_four.cmd_sec >= team_three.cmd_sec) WHEN true THEN gci_seat_four.cmd_sec ELSE team_three.cmd_sec END,
        cmd_med: CASE (gci_seat_four.cmd_med >= team_three.cmd_med) WHEN true THEN gci_seat_four.cmd_med ELSE team_three.cmd_med END,
        cmd_sci: CASE (gci_seat_four.cmd_sci >= team_three.cmd_sci) WHEN true THEN gci_seat_four.cmd_sci ELSE team_three.cmd_sci END,
        dip_eng: CASE (gci_seat_four.dip_eng >= team_three.dip_eng) WHEN true THEN gci_seat_four.dip_eng ELSE team_three.dip_eng END,
        dip_sec: CASE (gci_seat_four.dip_sec >= team_three.dip_sec) WHEN true THEN gci_seat_four.dip_sec ELSE team_three.dip_sec END,
        dip_med: CASE (gci_seat_four.dip_med >= team_three.dip_med) WHEN true THEN gci_seat_four.dip_med ELSE team_three.dip_med END,
        dip_sci: CASE (gci_seat_four.dip_sci >= team_three.dip_sci) WHEN true THEN gci_seat_four.dip_sci ELSE team_three.dip_sci END,
        eng_sec: CASE (gci_seat_four.eng_sec >= team_three.eng_sec) WHEN true THEN gci_seat_four.eng_sec ELSE team_three.eng_sec END,
        eng_med: CASE (gci_seat_four.eng_med >= team_three.eng_med) WHEN true THEN gci_seat_four.eng_med ELSE team_three.eng_med END,
        eng_sci: CASE (gci_seat_four.eng_sci >= team_three.eng_sci) WHEN true THEN gci_seat_four.eng_sci ELSE team_three.eng_sci END,
        sec_med: CASE (gci_seat_four.sec_med >= team_three.sec_med) WHEN true THEN gci_seat_four.sec_med ELSE team_three.sec_med END,
        sec_sci: CASE (gci_seat_four.sec_sci >= team_three.sec_sci) WHEN true THEN gci_seat_four.sec_sci ELSE team_three.sec_sci END,
        med_sci: CASE (gci_seat_four.med_sci >= team_three.med_sci) WHEN true THEN gci_seat_four.med_sci ELSE team_three.med_sci END
} AS team_four
  WHERE none(gci_other IN gci_all WHERE // Prune all crew that score less than at least one other crew in all rounds.
    (gci_seat_one <> gci_other) AND (gci_seat_two <> gci_other) AND
    (gci_seat_three <> gci_other) AND (gci_seat_four <> gci_other) AND
    (team_four.cmd_dip <= gci_other.cmd_dip) AND (team_four.cmd_dip <= team_three.cmd_dip) AND
    (team_four.cmd_eng <= gci_other.cmd_eng) AND (team_four.cmd_eng <= team_three.cmd_eng) AND
    (team_four.cmd_sec <= gci_other.cmd_sec) AND (team_four.cmd_sec <= team_three.cmd_sec) AND
    (team_four.cmd_med <= gci_other.cmd_med) AND (team_four.cmd_med <= team_three.cmd_med) AND
    (team_four.cmd_sci <= gci_other.cmd_sci) AND (team_four.cmd_sci <= team_three.cmd_sci) AND
    (team_four.dip_eng <= gci_other.dip_eng) AND (team_four.dip_eng <= team_three.dip_eng) AND
    (team_four.dip_sec <= gci_other.dip_sec) AND (team_four.dip_sec <= team_three.dip_sec) AND
    (team_four.dip_med <= gci_other.dip_med) AND (team_four.dip_med <= team_three.dip_med) AND
    (team_four.dip_sci <= gci_other.dip_sci) AND (team_four.dip_sci <= team_three.dip_sci) AND
    (team_four.eng_sec <= gci_other.eng_sec) AND (team_four.eng_sec <= team_three.eng_sec) AND
    (team_four.eng_med <= gci_other.eng_med) AND (team_four.eng_med <= team_three.eng_med) AND
    (team_four.eng_sci <= gci_other.eng_sci) AND (team_four.eng_sci <= team_three.eng_sci) AND
    (team_four.sec_med <= gci_other.sec_med) AND (team_four.sec_med <= team_three.sec_med) AND
    (team_four.sec_sci <= gci_other.sec_sci) AND (team_four.sec_sci <= team_three.sec_sci)
  )
UNWIND gci_all AS gci_seat_five
WITH g, gci_all, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, team_four, gci_seat_five, {
      cmd_dip: CASE (gci_seat_five.cmd_dip >= team_four.cmd_dip) WHEN true THEN gci_seat_five.cmd_dip ELSE team_four.cmd_dip END,
    cmd_eng: CASE (gci_seat_five.cmd_eng >= team_four.cmd_eng) WHEN true THEN gci_seat_five.cmd_eng ELSE team_four.cmd_eng END,
    cmd_sec: CASE (gci_seat_five.cmd_sec >= team_four.cmd_sec) WHEN true THEN gci_seat_five.cmd_sec ELSE team_four.cmd_sec END,
    cmd_med: CASE (gci_seat_five.cmd_med >= team_four.cmd_med) WHEN true THEN gci_seat_five.cmd_med ELSE team_four.cmd_med END,
    cmd_sci: CASE (gci_seat_five.cmd_sci >= team_four.cmd_sci) WHEN true THEN gci_seat_five.cmd_sci ELSE team_four.cmd_sci END,
    dip_eng: CASE (gci_seat_five.dip_eng >= team_four.dip_eng) WHEN true THEN gci_seat_five.dip_eng ELSE team_four.dip_eng END,
    dip_sec: CASE (gci_seat_five.dip_sec >= team_four.dip_sec) WHEN true THEN gci_seat_five.dip_sec ELSE team_four.dip_sec END,
    dip_med: CASE (gci_seat_five.dip_med >= team_four.dip_med) WHEN true THEN gci_seat_five.dip_med ELSE team_four.dip_med END,
    dip_sci: CASE (gci_seat_five.dip_sci >= team_four.dip_sci) WHEN true THEN gci_seat_five.dip_sci ELSE team_four.dip_sci END,
    eng_sec: CASE (gci_seat_five.eng_sec >= team_four.eng_sec) WHEN true THEN gci_seat_five.eng_sec ELSE team_four.eng_sec END,
    eng_med: CASE (gci_seat_five.eng_med >= team_four.eng_med) WHEN true THEN gci_seat_five.eng_med ELSE team_four.eng_med END,
    eng_sci: CASE (gci_seat_five.eng_sci >= team_four.eng_sci) WHEN true THEN gci_seat_five.eng_sci ELSE team_four.eng_sci END,
    sec_med: CASE (gci_seat_five.sec_med >= team_four.sec_med) WHEN true THEN gci_seat_five.sec_med ELSE team_four.sec_med END,
    sec_sci: CASE (gci_seat_five.sec_sci >= team_four.sec_sci) WHEN true THEN gci_seat_five.sec_sci ELSE team_four.sec_sci END,
    med_sci: CASE (gci_seat_five.med_sci >= team_four.med_sci) WHEN true THEN gci_seat_five.med_sci ELSE team_four.med_sci END
} AS team_five
WHERE none(gci_other IN gci_all
      WHERE // Prune all crew that score less than at least one other crew in all rounds.
      (gci_seat_one <> gci_other) AND (gci_seat_two <> gci_other) AND
      (gci_seat_three <> gci_other) AND
      (gci_seat_four <> gci_other) AND (gci_seat_five <> gci_other) AND
      (team_five.cmd_dip <= gci_other.cmd_dip) AND (team_five.cmd_dip <= team_four.cmd_dip) AND
      (team_five.cmd_eng <= gci_other.cmd_eng) AND (team_five.cmd_eng <= team_four.cmd_eng) AND
      (team_five.cmd_sec <= gci_other.cmd_sec) AND (team_five.cmd_sec <= team_four.cmd_sec) AND
      (team_five.cmd_med <= gci_other.cmd_med) AND (team_five.cmd_med <= team_four.cmd_med) AND
      (team_five.cmd_sci <= gci_other.cmd_sci) AND (team_five.cmd_sci <= team_four.cmd_sci) AND
      (team_five.dip_eng <= gci_other.dip_eng) AND (team_five.dip_eng <= team_four.dip_eng) AND
      (team_five.dip_sec <= gci_other.dip_sec) AND (team_five.dip_sec <= team_four.dip_sec) AND
      (team_five.dip_med <= gci_other.dip_med) AND (team_five.dip_med <= team_four.dip_med) AND
      (team_five.dip_sci <= gci_other.dip_sci) AND (team_five.dip_sci <= team_four.dip_sci) AND
      (team_five.eng_sec <= gci_other.eng_sec) AND (team_five.eng_sec <= team_four.eng_sec) AND
      (team_five.eng_med <= gci_other.eng_med) AND (team_five.eng_med <= team_four.eng_med) AND
      (team_five.eng_sci <= gci_other.eng_sci) AND (team_five.eng_sci <= team_four.eng_sci) AND
      (team_five.sec_med <= gci_other.sec_med) AND (team_five.sec_med <= team_four.sec_med) AND
      (team_five.sec_sci <= gci_other.sec_sci) AND (team_five.sec_sci <= team_four.sec_sci)
)
MERGE (g)-[:IDEAL_TEAMS]->(full_team:GauntletTeam)
ON CREATE SET full_team = team_five
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 1}]->(gci_seat_one)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 2}]->(gci_seat_two)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 3}]->(gci_seat_three)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 4}]->(gci_seat_four)
MERGE (full_team)-[:PLAYS_CANDIDATE {slot: 5}]->(gci_seat_five)
RETURN full_team, gci_seat_one, gci_seat_two, gci_seat_three, gci_seat_four, gci_seat_five;
*/
//:commit


