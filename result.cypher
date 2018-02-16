MATCH(g:GauntletAnalysis)-[b:BUILDING]->(t:GauntletTeam)
    RETURN b.size, count(t);

MATCH(g:GauntletAnalysis)-[:BUILDING {size: 5}]->(slot5:GauntletTeam)
       -[:BASED_ON]->(slot4:GauntletTeam)
       -[:BASED_ON]->(slot3:GauntletTeam)
       -[:BASED_ON]->(slot2:GauntletTeam)
       -[:BASED_ON]->(slot1:GauntletTeam)
MATCH (slot5)-[:INCLUDES]->(c5:GauntletCrew)
MATCH (slot4)-[:INCLUDES]->(c4:GauntletCrew)
MATCH (slot3)-[:INCLUDES]->(c3:GauntletCrew)
MATCH (slot2)-[:INCLUDES]->(c2:GauntletCrew)
MATCH (slot1)-[:INCLUDES]->(c1:GauntletCrew)
RETURN
  (slot5.cmd_dip + slot5.cmd_eng + slot5.cmd_sec + slot5.cmd_med + slot5.cmd_sci + slot5.dip_eng + slot5.dip_sec +
    slot5.dip_med + slot5.dip_sci + slot5.eng_sec + slot5.eng_med + slot5.eng_sci + slot5.sec_med + slot5.sec_sci +
    slot5.med_sci) AS all_sum,
  slot5.cmd_dip, slot5.cmd_eng, slot5.cmd_sec, slot5.cmd_med, slot5.cmd_sci, slot5.dip_eng, slot5.dip_sec,
  slot5.dip_med, slot5.dip_sci, slot5.eng_sec, slot5.eng_med, slot5.eng_sci, slot5.sec_med, slot5.sec_sci,
  slot5.med_sci,
  c5.symbol, c4.symbol, c3.symbol, c2.symbol, c1.symbol
  ORDER BY all_sum DESCENDING;
