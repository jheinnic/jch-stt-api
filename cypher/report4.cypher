:param username "jheinnic@hotmail.com"
:param traits ["exobiology", "hologram", "civilian"]
:param skill "sci"
:param timestamp timestamp()


MATCH (g:GauntletAnalysis {username: $username})
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

