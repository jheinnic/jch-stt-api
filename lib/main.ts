import * as fs from 'fs';
import {ICrew, IValueRange} from './model';
import {ISTTClient, STTClient} from './STTClient';
import {IPlayerSummary} from './model/values';
import through2_map = require('through2-map');

function serializeSkill(skill: IValueRange = {
   core: 0,
   range_min: 0,
   range_max: 0
})
{
   return `${skill.core},${skill.range_min},${skill.range_max}`;
}

async function runProgram(username: string): Promise<ISTTClient>
{
   const newSttClient = new STTClient();

   const playerWriteHandle = fs.createWriteStream('./players.csv');
   const crewWriteHandle = fs.createWriteStream('./crew_instance_stats.csv');
   const initSttClient: ISTTClient = await newSttClient.login(username);

   playerWriteHandle.write(
      'username,dbid,player_id,character_id,player_display_name,character_display_name,level,xp\n');
   crewWriteHandle.write(
      'owner_id,crew_id,symbol,name,short_name,traits,max_rarity,rarity,level,'
      + 'cmd_core,cmd_rmin,cmd_rmax,'
      + 'dip_core,dip_rmin,dip_rmax,'
      + 'eng_core,eng_rmin,eng_rmax,'
      + 'sec_core,sec_rmin,sec_rmax,'
      + 'med_core,med_rmin,med_rmax,'
      + 'sci_core,sci_rmin,sci_rmax\n');

   let currentPlayer: Partial<IPlayerSummary> = {
      username: username,
      player_id: -1,
      character_id: -1
   };

   const mapPlayerStream = through2_map.obj(
      (chunk: IPlayerSummary) => {
         currentPlayer = chunk;
         return `${username},${chunk.dbid},${chunk.player_id},${chunk.character_id},${chunk.player_display_name},${chunk.character_display_name},${chunk.level},${chunk.xp}\n`;
      }
   );
   mapPlayerStream.pipe(playerWriteHandle);

   const mapCrewStream = through2_map.obj(
      (chunk: any) => {
         // console.log(chunk);
         const skills = chunk.skills;
         return `${currentPlayer.character_id},${chunk.id},${chunk.symbol},${chunk.name},${chunk.short_name},${chunk.traits.join(
            ';')},${chunk.max_rarity},${chunk.rarity},${chunk.level},${serializeSkill(skills.command_skill)},${serializeSkill(skills.diplomacy_skill)},${serializeSkill(
            skills.engineering_skill)},${serializeSkill(skills.security_skill)},${serializeSkill(skills.medicine_skill)},${serializeSkill(
            skills.science_skill)}\n`;
      });
   mapCrewStream.pipe(crewWriteHandle);

   // const playerPromise = new Promise((resolve, reject) => {
      initSttClient.loadPlayerSummary()
         .do((line: any) => { console.error(line); })
         .subscribe(
            (next: any) => { mapPlayerStream.write(next); },
            (err: any) => {
               console.error(err);
               // reject(err);
            },
            () => {
               console.error('Done observing player data');
               // resolve(initSttClient);
            }
         );
   // });
   // const crewPromise = new Promise((resolve, reject) => {
      initSttClient.loadCrewData()
         .subscribe(
            (next: ICrew) => { mapCrewStream.write(next); },
            (err: any) => {
               console.error(err);
               // reject(err);
            },
            () => {
               console.error('Done observing player data');
               // resolve(initSttClient);
            }
         );
   // });

   // await playerPromise;
   // await crewPromise;

   return initSttClient;
}

runProgram('jheinnic@hotmail.com')
   .then((client: ISTTClient) => {
      console.error('Load pipelines wired');
      client.executeFlow();
      console.error('Executing load pipelines');
   })
   .catch(console.error.bind(console));
