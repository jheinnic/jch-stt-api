import {agent, Response, SuperAgent, SuperAgentRequest} from 'superagent';
import {PassThrough, Writable} from 'stream';
import {Observable} from 'rxjs/Observable';
import 'rxjs/add/observable/fromEvent';
import 'rxjs/add/observable/zip';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/merge';
import 'rxjs/add/operator/take';
import 'rxjs/add/operator/shareReplay';
import * as JSONStream from 'jsonstream';
import {IPlayerSummary} from './model/values';
import {ICrew} from './model/index';
import CONFIG from './CONFIG';
import * as _ from 'lodash';
import * as util from 'util';
import through2_map = require('through2-map');

export interface ISTTClient
{
   login(username: string, password: string): Promise<ISTTClient>;

   loginWithAccessToken(accessToken: string): ISTTClient;

   /**
    * Methods that return Observables add or reuse queries in the STTClient plan, but do not actually
    * begin executing until executeFlow() is called.  Calling executeFlow() activates queries backing any
    * outstanding Observables, and also resets work queue so next call to executeFlow() will only issue
    * query work for Observables requested since previous call to executeFlow().
    */
   executeFlow(): void;

   loadPlayerSummary(): Observable<IPlayerSummary>;

   loadCrewData(): Observable<ICrew>;
}

export class STTClient implements ISTTClient
{
   private readonly _agent: SuperAgent<SuperAgentRequest>;

   private _accessToken?: string;

   private _playerUnit?: PlayerDataQuery;

   constructor()
   {
      this._agent = agent();
      this._accessToken = '';
      this._playerUnit = undefined;
   }

   async login(username = 'username@example.org', password = 'bwahbwahbwah'): Promise<ISTTClient>
   {
      const response = await
         this._agent.post(CONFIG.URL_PLATFORM + 'oauth2/token')
            .set('Content-Type', 'application/x-www-form-urlencoded')
            .send({
               'username': username,
               'password': password,
               'client_id': CONFIG.CLIENT_ID,
               'grant_type': 'password'
            });

      if (response.error) {
         throw Error(response.error.message);
      } else if (response.body && response.body.access_token) {
         return this.loginWithAccessToken(response.body.access_token);
      }

      throw Error('Invalid data for login!');
   }

   async loginWithFacebook(facebookAccessToken: string, facebookUserId: string): Promise<ISTTClient>
   {
      const response: Response = await
         this._agent.post(CONFIG.URL_PLATFORM + 'oauth2/token')
            .set('Content-Type', 'application/x-www-form-urlencoded')
            .send({
               'third_party.third_party': 'facebook',
               'third_party.access_token': facebookAccessToken,
               'third_party.uid': facebookUserId,
               'client_id': CONFIG.CLIENT_ID,
               'grant_type': 'third_party'
            });

      if (response.error) {
         throw Error(response.error.message);
      } else if (response.body && response.body.access_token) {
         return this.loginWithAccessToken(response.body.access_token);
      }

      throw Error('Received data unusable for login: ' + response.body);
   }

   loginWithAccessToken(accessToken: string): ISTTClient
   {
      if (!!accessToken) {
         this._accessToken = accessToken;
         return this
      }

      this._accessToken = undefined;
      throw Error('No access token provided');
   }

   private _enrichApiTokens(qs: any = {}): object
   {
      if (this._accessToken === undefined) {
         throw Error('Not logged in!');
      }

      return Object.assign({
         client_api: CONFIG.CLIENT_API_VERSION,
         access_token: this._accessToken
      }, qs);
   }

   _executeGetRequest(resourceUrl: string, qs: object = {}): SuperAgentRequest
   {
      const request = this._agent.get(CONFIG.URL_SERVER + resourceUrl)
         .buffer(false)
         .query(this._enrichApiTokens(qs));

      request.on('response', (res: Response) => {
         if ((res.status !== 200) || (!res.ok) || (res.error)) {
            request.abort();
         }
      });

      return request;
   }

   _executePostRequest(resourceUrl: string, bodyData: object = {}): SuperAgentRequest
   {
      const request = this._agent.post(CONFIG.URL_SERVER + resourceUrl)
         .buffer(false)
         .set('Content-Type', 'application/x-www-form-urlencoded')
         .send(this._enrichApiTokens(bodyData));

      request.on('response', (res: Response) => {
         if ((res.status !== 200) || (!res.ok) || (res.error)) {
            request.abort();
         }
      });

      return request;
   }

   executeFlow(): void
   {
      if (!!this._playerUnit) {
         this._playerUnit.activateFlow(this);
         this._playerUnit = undefined;
      }
   }

   loadPlayerSummary(): Observable<any>
   {
      if (!this._playerUnit) {
         this._playerUnit = new PlayerDataQuery();
      }
      return this._playerUnit.accessPlayerSummary();
   }

   loadCrewData(): Observable<ICrew>
   {
      if (!this._playerUnit) {
         this._playerUnit = new PlayerDataQuery();
      }
      return this._playerUnit.accessCrewData();
   }

   /*
      loadServerConfig(): Promise<any> {
         return this._executeGetRequest('config', {
            platform:'WebGLPlayer',
            device_type:'Desktop',
            client_version:CONFIG.CLIENT_VERSION,
            platform_folder:CONFIG.CLIENT_PLATFORM
         }).then((data: any) => {
            this._serverConfig = data;
            console.info('Loaded server config');
            return Promise.resolve();
         });
      }

      loadCrewArchetypes(): Promise<any> {
         return this._executeGetRequest('character/get_avatar_crew_archetypes').then((data: any) => {
            if (data.crew_avatars) {
               this._crewAvatars = data.crew_avatars;
               console.info('Loaded ' + data.crew_avatars.length +' crew avatars');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for crew avatars!');
            }
         });
      }

      loadPlatformConfig(): Promise<any> {
         return this._executeGetRequest('config/platform').then((data: any) => {
            this._platformConfig = data;
            console.info('Loaded platform config');
            return Promise.resolve();
         });
      }

      resyncPlayerCurrencyData(): Promise<any> {
         // this code reloads minimal stuff to update the player information and merge things back in
         // 'player/resync_inventory' is more heavy-handed and has the potential to overwrite some stuff we added on like images, but can also bring in any new items, crew or ships
         return this._executeGetRequest('player/resync_currency').then((data: any) => {
            if (data.player) {
               this._playerData.player = mergeDeep(this._playerData.player, data.player);
               console.info('Resynced player currency data');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for player!');
            }
         });
      }

      loadShipSchematics(): Promise<any> {
         return this._executeGetRequest('ship_schematic').then((data: any) => {
            if (data.schematics) {
               this._shipSchematics = data.schematics;
               console.info('Loaded ' + data.schematics.length + ' ship schematics');

               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for ship schematics!');
            }
         });
      }

      loadFrozenCrew(symbol: string): Promise<any> {
         return this._executePostRequest('stasis_vault/immortal_restore_info', { symbol: symbol }).then((data: any) => {
            if (data.crew) {
               //console.info('Loaded frozen crew stats for ' + symbol);
               return Promise.resolve(data.crew);
            } else {
               return Promise.reject('Invalid data for frozen crew!');
            }
         });
      }

      loadFleetMemberInfo(guildId: string): Promise<any> {
         return this._executePostRequest('fleet/complete_member_info', { guild_id: guildId }).then((data: any) => {
            if (data) {
               this._fleetMemberInfo = data;
               console.info('Loaded fleet member info');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for fleet member info!');
            }
         });
      }

      loadFleetData(guildId: string): Promise<any> {
         return this._executeGetRequest('fleet/' + guildId).then((data: any) => {
            if (data.fleet) {
               this._fleetData = data.fleet;
               console.info('Loaded fleet data');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for fleet!');
            }
         });
      }

      loadStarbaseData(guildId: string): Promise<any> {
         return this._executeGetRequest('starbase/get').then((data: any) => {
            if (data) {
               this._starbaseData = data;
               console.info('Loaded starbase data');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for starbase!');
            }
         });
      }

      loadVoyage(voyageId: number, newOnly: boolean = true): Promise<any> {
         return this._executePostRequest('voyage/refresh', { voyage_status_id: voyageId, new_only: newOnly }).then((data: any) => {
            if (data) {
               let voyageNarrative: any[] = [];

               data.forEach((action: any) => {
                  if (action.character) {
                     // TODO: if DB adds support for more than one voyage at a time this hack won't work
                     this._playerData.player.character.voyage[0] = mergeDeep(this._playerData.player.character.voyage[0], action.character.voyage[0]);
                  }
                  else if (action.voyage_narrative) {
                     voyageNarrative = action.voyage_narrative;
                  }
               });

               //console.info('Loaded voyage info');
               return Promise.resolve(voyageNarrative);
            } else {
               return Promise.reject('Invalid data for voyage!');
            }
         });
      }

      recallVoyage(voyageId: number): Promise<void> {
         return this._executePostRequest('voyage/recall', { voyage_status_id: voyageId }).then((data: any) => {
            if (data) {
               //console.info('Recalled voyage');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for voyage!');
            }
         });
      }

      reviveVoyage(voyageId: number): Promise<void> {
         return this._executePostRequest('voyage/revive', { voyage_status_id: voyageId }).then((data: any) => {
            if (data) {
               //console.info('Revived voyage');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for voyage!');
            }
         });
      }

      resolveDilemma(voyageId: number, dilemmaId: number, index: number): Promise<void> {
         return this._executePostRequest('voyage/resolve_dilemma', { voyage_status_id: voyageId, dilemma_id: dilemmaId, resolution_index: index }).then((data: any) => {
            if (data) {
               //console.info('Resolved dilemma');
               return Promise.resolve();
            } else {
               return Promise.reject('Invalid data for voyage!');
            }
         });
      }
   */
}

interface IRequestFactory
{
   _executeGetRequest(resourceUrl: string, qs?: object): SuperAgentRequest;

   _executePostRequest(resourceUrl: string, bodyData?: object): SuperAgentRequest;
}

abstract class UnitOfQuery
{
   abstract activateFlow(requestFactory: IRequestFactory): void;

   protected _wrapForSharing(request: SuperAgentRequest): PassThrough
   {
      const destroyable = new PassThrough({
         readableObjectMode: false,
         writableObjectMode: false
      });

      request.pipe(destroyable);

      return destroyable;
   }
}

interface ISummaryPathMap
{
   readonly fromPath: string | any[];
   readonly toProp: string;
}

interface ISummaryProperty
{
   readonly parser: NodeJS.ReadWriteStream;
   readonly joiner: NodeJS.ReadWriteStream;
   readonly observable: Observable<[string, any]>;
}

const PLAYER_SUMMARY_PATTERNS: ISummaryPathMap[] = [
   {
      fromPath: 'player.dbid',
      toProp: 'dbid'
   },
   {
      fromPath: 'player.id',
      toProp: 'player_id'
   },
   {
      fromPath: 'player.character.id',
      toProp: 'character_id'
   },
   {
      fromPath: 'player.display_name',
      toProp: 'player_display_name'
   },
   {
      fromPath: 'player.character.display_name',
      toProp: 'character_display_name'
   },
   {
      fromPath: 'player.character.level',
      toProp: 'level'
   },
   {
      fromPath: 'player.character.xp',
      toProp: 'xp'
   }
];

class PlayerDataQuery extends UnitOfQuery
{
   private _playerSource: Writable;

   private _parsePlayerData: ISummaryProperty[];

   private _parseCrewData: NodeJS.ReadWriteStream;

   private _playerDataObs: Observable<any>;

   private _crewDataObs: Observable<ICrew>;

   activateFlow(requestFactory: IRequestFactory)
   {
      this._verifyFlowInactive();

      if (!!this._crewDataObs || !!this._playerDataObs) {
         this._playerSource = this._wrapForSharing(
            requestFactory._executeGetRequest('player'));

         if (!!this._playerDataObs) {
            this._parsePlayerData.forEach((nextProperty: ISummaryProperty) => {
               this._playerSource.pipe(nextProperty.parser);
            });
         }

         if (!!this._crewDataObs) {
            this._playerSource.pipe(this._parseCrewData);
         }
      } else {
         throw Error('No observables from PlayerDataQuery unit have been activated.');
      }
   }

   accessPlayerSummary(): Observable<IPlayerSummary>
   {
      this._verifyFlowInactive();

      if (!this._playerDataObs) {
         this._parsePlayerData = PLAYER_SUMMARY_PATTERNS.map((nextMap: ISummaryPathMap) => {
            const parser = JSONStream.parse(nextMap.fromPath);
            const joiner = through2_map.obj(function (value: any): [string, any] {
               const retVal: [string, any] = [nextMap.toProp, value];
               // console.error('Found ' + util.inspect(retVal));
               return retVal;
            });

            const observable = Observable.fromEvent<any>(joiner, 'data')
               // .do<any>((value: any) => { console.error(value); })
               // .take(1);
            parser.pipe(joiner);

            // parser.on('end', (args: any[]) => { console.log('end parser', util.inspect(nextMap)); });
            // parser.on('finish', (args: any[]) => { console.log('finish parser', util.inspect(nextMap)); });
            // joiner.on('end', (args: any[]) => { console.log('end joiner', util.inspect(nextMap)); });
            // joiner.on('finish', (args: any[]) => { console.log('finish joiner', util.inspect(nextMap)); });
            // joiner.addListener('data', (chunk: Buffer | string) => { console.error('Listen ', chunk);})

            return {
               parser,
               joiner,
               observable
            };
         });

         this._playerDataObs = Observable.zip<string>(
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[0].joiner, 'data'),
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[1].joiner, 'data'),
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[2].joiner, 'data'),
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[3].joiner, 'data'),
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[4].joiner, 'data'),
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[5].joiner, 'data'),
            Observable.fromEvent<[string, any]>(
               this._parsePlayerData[6].joiner, 'data'),
            (
               p1: [string, any],
               p2: [string, any],
               p3: [string, any],
               p4: [string, any],
               p5: [string, any],
               p6: [string, any],
               p7: [string, any]) => {
               console.error('Zipping up ' + util.inspect([p1, p2, p3, p4, p5, p6, p7]));
               return _.fromPairs([p1, p2, p3, p4, p5, p6, p7]);
            }
         );
      }

      return this._playerDataObs;
   }

   /*
.do<any>(
(value: any) => { console.error("post-zip", value); }
)
.take(1);
*/

   accessCrewData(): Observable<ICrew>
   {
      this._verifyFlowInactive();

      if (!this._crewDataObs) {
         this._parseCrewData = JSONStream.parse('player.character.crew.*');
         this._crewDataObs = Observable.fromEvent<ICrew>(this._parseCrewData, 'data')
            .shareReplay(250);

         this._parseCrewData.on('end', (args: any[]) => {
            console.log('end parser for player.character.crew');
         });
         this._parseCrewData.on('finish', (args: any[]) => {
            console.log('finish parser for player.character.crew');
         });
      }

      return this._crewDataObs;
   }

   private _verifyFlowInactive()
   {
      if (!!this._playerSource) {
         throw Error(
            'UnitOfQuery objects may only be used for a single query, and this one has already been used');
      }
   }
}
