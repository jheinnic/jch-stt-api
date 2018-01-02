// import {SuperAgent, SuperAgentRequest} 'superagent';
// import {Request, Response} from 'superagent';
import {agent, Response, SuperAgent, SuperAgentRequest} from 'superagent';
import {ICrew, IPlayerData} from './model/TempTypes';
import CONFIG from './CONFIG';
import 'reflect-metadata';

class Client
{
   private readonly _agent: SuperAgent<SuperAgentRequest>;

   private _accessToken: string;

   private _autoLogin: boolean;

   private _playerData: IPlayerData;

   constructor()
   {
      this._accessToken = '';
      this._autoLogin = false;
      this._agent = agent();
   }

   login(username = 'jheinnic@hotmail.com', password = 'Vdu+9gG2', autoLogin = false)
   {
      return this._agent.post(CONFIG.URL_PLATFORM + "oauth2/token")
            .set('Content-Type', 'application/x-www-form-urlencoded')
            .send({
               "username": username,
               "password": password,
               "client_id": CONFIG.CLIENT_ID,
               "grant_type": "password"
            })
            .then((data: Response) => {
               if (data.error) {
                  return Promise.reject(data.error);
               } else if (data.body.access_token) {
                  return this._loginWithAccessToken(data.body.access_token, autoLogin);
               }

               return Promise.reject("Invalid data for login!");
            })
            .catch((err: any) => {
               console.error(err);

               return Promise.reject("Fatal error during login");
            })
   }


   private _loginWithAccessToken(accessToken: string, autoLogin: boolean)
   {
      this._accessToken = accessToken;
      this._autoLogin = autoLogin;
      return Promise.resolve(accessToken);
   }

   private _enrichApiTokens(qs: any = {}): any
   {
      return Object.assign({
         client_api: CONFIG.CLIENT_API_VERSION,
         access_token: this._accessToken
      }, qs)
   }

   private _executeGetRequest(resourceUrl: string, qs: any = {}): Promise<any>
   {
      if (this._accessToken === undefined) {
         return Promise.reject("Not logged in!");
      }

      const apiQuery = this._enrichApiTokens(qs);
      return this._agent.get(CONFIG.URL_SERVER + resourceUrl)
            .query(apiQuery)
            .then((resp: Response) => {
               return Promise.resolve(resp.body);
            })
            .catch((err: any) => {
               console.error(err);

               return Promise.reject("Fatal error for call to " + resourceUrl);
            });
   }

   loadPlayerData(): Promise<IPlayerData>
   {
      const apiQuery = this._enrichApiTokens();

      return this._agent.get(CONFIG.URL_SERVER + "player")
            .query(apiQuery)
            .then((data: Response) => {
               if (data.ok) {
                  // this._playerData = plainToClass(PlayerData, data.body.playerData);
                  this._playerData = data.body.player;
                  console.info("Loaded data body: ", data.body);
                  console.info("Loaded player data: ", data.body.player);
                  return Promise.resolve(this._playerData);
               }

               return Promise.reject("Invalid player data!!");
            })
            .catch((err: any) => {
               console.error(err);

               return Promise.reject("Fatal error when loading player data");
            });
   }
}

export interface IncrementalLoad
{
   accessToken: string;
   playerData?: IPlayerData; // | Promise<IPlayerData>;
}

const client = new Client();
client.login()
      .then((value: string) => {
         console.log(value);
         return Promise.resolve({accessToken: value});
      })
      .then((outerValue: IncrementalLoad) => {
         return client.loadPlayerData()
               .then((innerValue: IPlayerData) => {
                  return Promise.resolve(
                        Object.assign({playerData: innerValue}, outerValue));
               });
      })
      .then((value: IncrementalLoad) => {
         console.log(JSON.stringify(value.playerData!));
         return (value.playerData!.character.crew);
      })
      .then((values: ICrew[]) => {
         console.log(JSON.stringify(values[0]));
         const retVal = values.map((nextCrew: ICrew) => {
            const plucked = {
               name: nextCrew.name,
               traits: nextCrew.traits.join(';'),
               skills: Object.assign({
                  command_skill: { core: 0, range_min: 0, range_max: 0 },
                  diplomacy_skill: { core: 0, range_min: 0, range_max: 0 },
                  engineering_skill: { core: 0, range_min: 0, range_max: 0 },
                  security_skill: { core: 0, range_min: 0, range_max: 0 },
                  medicine_skill: { core: 0, range_min: 0, range_max: 0 },
                  science_skill: { core: 0, range_min: 0, range_max: 0 }
               }, nextCrew.skills)
            };
            console.log(plucked);
            return [
               plucked.name,
               plucked.traits, // .join(';'),
               plucked.skills.command_skill.range_min,
               plucked.skills.command_skill.range_max,
               plucked.skills.diplomacy_skill.range_min,
               plucked.skills.diplomacy_skill.range_max,
               plucked.skills.engineering_skill.range_min,
               plucked.skills.engineering_skill.range_max,
               plucked.skills.security_skill.range_min,
               plucked.skills.security_skill.range_max,
               plucked.skills.medicine_skill.range_min,
               plucked.skills.medicine_skill.range_max,
               plucked.skills.science_skill.range_min,
               plucked.skills.science_skill.range_max
            ].join(',')
         }).join('\n');
         console.log(retVal);
         return retVal;
      })
      .catch((err: any) => {
         console.error(err);
      });
