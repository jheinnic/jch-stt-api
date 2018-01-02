export interface IPlayerData {
   [anyPropName: string]: any;
   dbid: string;
   character: ICharacterData;
}

export interface ICharacterData {
   crew: ICrew[];
}

export interface ICrew {
   id: string;
   name: string;
   traits: string[];
   skills: ISkills;
}

export interface ISkills {
   command_skill: ISkillStat;
   diplomacy_skill: ISkillStat;
   engineering_skill: ISkillStat;
   security_skill: ISkillStat;
   science_skill: ISkillStat;
   medical_skill: ISkillStat;
}

export interface ISkillStat {
   core: number;
   range_min: number;
   range_max: number;
}

export class PlayerData implements IPlayerData {
   [anyPropName: string]: any;
   dbid: string;
   character: ICharacterData;
}
