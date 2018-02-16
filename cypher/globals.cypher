MERGE (zero:ZeroGauntletScore)
ON CREATE SET
  zero.cmd_dip_min = 0, zero.cmd_dip_max = 0, zero.cmd_dip_avg = 0,
  zero.cmd_eng_min = 0, zero.cmd_eng_max = 0, zero.cmd_eng_avg = 0,
  zero.cmd_sec_min = 0, zero.cmd_sec_max = 0, zero.cmd_sec_avg = 0,
  zero.cmd_med_min = 0, zero.cmd_med_max = 0, zero.cmd_med_avg = 0,
  zero.cmd_sci_min = 0, zero.cmd_sci_max = 0, zero.cmd_sci_avg = 0,
  zero.dip_eng_min = 0, zero.dip_eng_max = 0, zero.dip_eng_avg = 0,
  zero.dip_sec_min = 0, zero.dip_sec_max = 0, zero.dip_sec_avg = 0,
  zero.dip_med_min = 0, zero.dip_med_max = 0, zero.dip_med_avg = 0,
  zero.dip_sci_min = 0, zero.dip_sci_max = 0, zero.dip_sci_avg = 0,
  zero.eng_sec_min = 0, zero.eng_sec_max = 0, zero.eng_sec_avg = 0,
  zero.eng_med_min = 0, zero.eng_med_max = 0, zero.eng_med_avg = 0,
  zero.eng_sci_min = 0, zero.eng_sci_max = 0, zero.eng_sci_avg = 0,
  zero.sec_med_min = 0, zero.sec_med_max = 0, zero.sec_med_avg = 0,
  zero.sec_sci_min = 0, zero.sec_sci_max = 0, zero.sec_sci_avg = 0,
  zero.med_sci_min = 0, zero.med_sci_max = 0, zero.med_sci_avg = 0;

MERGE (zero:ZeroCrewScore)
ON CREATE SET
  zero.cmd_rmin = 0, zero.cmd_rmax = 0, zero.cmd_gavg = 0, zero.cmd_core = 0,
  zero.dip_rmin = 0, zero.dip_rmax = 0, zero.dip_gavg = 0, zero.dip_core = 0,
  zero.eng_rmin = 0, zero.eng_rmax = 0, zero.eng_gavg = 0, zero.eng_core = 0,
  zero.sec_rmin = 0, zero.sec_rmax = 0, zero.sec_gavg = 0, zero.sec_core = 0,
  zero.med_rmin = 0, zero.med_rmax = 0, zero.med_gavg = 0, zero.med_core = 0,
  zero.sci_rmin = 0, zero.sci_rmax = 0, zero.sci_gavg = 0, zero.sci_core = 0;

MATCH (zero_score:ZeroGauntletScore)
MERGE (zero:ZeroGauntletPath)-[:SKILLS]->(zero_score)
ON CREATE SET zero.slots = {open: 5, filled: 0};

CREATE INDEX ON :Trait(id);

//CREATE CONSTRAINT ON (score:GauntletScore)
//ASSERT exists(score.cmd_dip_min);

//CREATE CONSTRAINT ON (score:GauntletScore)
//ASSERT exists(score.cmd_dip_max);

//CREATE CONSTRAINT ON (score:GauntletScore)
//ASSERT exists(score.cmd_dip_avg);

