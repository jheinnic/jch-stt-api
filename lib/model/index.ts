export interface IAbility {
   condition: number
   type: number
   amount: number
}

export interface IAcceptedMission {
   id: number
   symbol: string
   description: string
   episode: number
   episode_title: string
   episode_portrait: IIcon
   marker: number[]
   marker_icon: IIcon
   exclude_from_timeline: string
   stars_earned: number
   total_stars: number
   accepted: boolean
   state: number
   main_story: boolean
}

export interface IAction {
   bonus_amount: number
   name: string
   symbol: string
   cooldown: number
   initial_cooldown: number
   duration: number
   bonus_type: number
   crew: string
   icon: IIcon
   ability: IAbility
   penalty: IPenalty
}

export interface IBattleStation {
   skill: string
}

export interface IBonus {
   value: number
   probability: number
}

export interface IBoostWindow {
   window: number[]
   reward: IReward
}

export interface ICadetSchedule {
   day: number
   schedule: ISchedule[]
   missions: IMission[]
   current: number
   ends_in: number
   next: number
   next_starts_in: number
}

export interface ICapAchiever {
   name: string
   date: number
}

export interface ICharacter {
   id: number
   display_name: string
   using_default_name: boolean
   level: number
   max_level: number
   xp: number
   xp_for_current_level: number
   xp_for_next_level: number
   location: ILocation
   destination: IDestination
   navmap: INavmap
   accepted_missions: IAcceptedMission[]
   active_conflict: string
   shuttle_bays: number
   next_shuttle_bay_cost: string
   can_purchase_shuttle_bay: boolean
   crew_avatar: ICrewAvatar
   stored_immortals: IStoredImmortal[]
   seconds_to_scan_cooldown: number
   scan_speedups_today: number
   replay_energy_max: number
   replay_energy_rate: number
   seconds_from_replay_energy_basis: number
   replay_energy_overflow: number
   boost_windows: IBoostWindow[]
   seconds_from_last_boost_claim: number
   video_ad_chroniton_boost_reward: IVideoAdChronitonBoostReward
   cadet_tickets: ITicketCounter
   pvp_tickets: IPvpTicket
   event_tickets: ITicketCounter
   cadet_schedule: ICadetSchedule
   pvp_divisions: IPvpDivision[]
   pvp_timer: IPvpTimer
   crew: ICrew[]
   items: IItem[]
   crew_borrows: string[]
   crew_shares: string[]
   crew_limit: number
   crew_limit_increase_per_purchase: number
   next_crew_limit_increase_cost: ICost
   can_purchase_crew_limit_increase: boolean
   item_limit: number
   ships: IShip[]
   current_ship_id: number
   shuttle_adventures: IShuttleAdventure[]
   factions: IFaction[]
   disputes: IDispute[]
   tng_the_game_level: number
   open_packs: string[]
   daily_activities: IDailyActivity[]
   next_daily_activity_reset: number
   next_starbase_donation_reset: number
   fleet_activities: IFleetActivities[]
   next_fleet_activity_reset: number
   freestanding_quests: string[]
   daily_rewards_state: IDailyRewardsState
   events: IEvent[]
   dispute_histories: IDisputeHistory[]
   stimpack: string
   tutorials: ITutorial[]
   location_channel_prefix: string
   honor_reward_by_rarity: number[]
   voyage_descriptions: IVoyageDescription[]
   voyage: string[]
   voyage_summaries: IVoyageSummary
   reroll_descriptions: IRerollDescription[]
}

//interface Chat {
   //}

export interface IClaimed {
   uuid: string
   gamer_tag: number
   symbol: string
   state: string
   updated: number
   history: IHistory[]
   specialized: string
   cwin: ICwin
   cwin_secs_till_open: number
   cwin_secs_till_close: number
}

export interface IClientAsset {
   system: string
   place: string
}

export interface ICommerce {
   layaways: string[]
}

export interface ICommunityLink {
   symbol: string
   image: IImage
   title: string
   date: string
   url: string
}

export interface IContent {
   content_type: string
   shuttles: IShuttle[]
}

export interface ICost {
   currency: number
   amount: number
}

export interface ICrew {
   id: number
   symbol: string
   name: string
   short_name: string
   flavor: string
   archetype_id: number
   xp: number
   xp_for_current_level: number
   xp_for_next_level: number
   max_xp: number
   favorite: boolean
   level: number
   in_buy_back_state: boolean
   max_level: number
   rarity: number
   max_rarity: number
   equipment_rank: number
   max_equipment_rank: number
   equipment_slots: IEquipmentSlot[]
   equipment: string[]
   icon: IIcon
   portrait: IIcon
   full_body: IFullBody
   voice_over: string
   expires_in: string
   active_status: number
   active_id: string
   active_index: number
   passive_status: number
   passive_id: string
   passive_index: number
   traits: string[]
   traits_hidden: string[]
   skills: ISkills
   ship_battle: IShipBattle
   action: IAction
   default_avatar: boolean
   cross_fuse_targets: string[]
   cap_achiever: ICapAchiever
}

export interface ICrewAvatar {
   id: number
   symbol: string
   name: string
   short_name: string
   max_rarity: number
   icon: IIcon
   portrait: IIcon
   full_body: IFullBody
   default_avatar: boolean
   hide_from_cryo: boolean
}

export interface ICrewBonus {
   crew_tag: string
   value: number
}

export interface ICrewSlot {
   symbol: string
   name: string
   skill: string
   trait: string
}

export interface ICurrencyExchange {
   id: number
   amount: number
   output: number
   input: number
   schedule: number[]
   exchanges_today: number
   bonus: number
   limit: number
}

export interface ICwin {
   open: number
   close: number
}

export interface IDailyActivity {
   id: number
   name: string
   description: string
   icon: IIcon
   area: string
   weight: number
   category: number
   lifetime: number
   rewards: string[]
   goal: number
   min_level: number
   rarity: number
   progress: number
   status: string
}

export interface IDailyRewardsState {
   seconds_until_next_reward: number
   today_reward_day_index: number
   reward_days: IRewardDay[]
}

export interface IDestination {
   system: string
   place: string
   setup: string
   x: number
   y: number
}

export interface IPlayer {
   id: number
   dbid: number
   lang: string
   timezone: string
   locale: string
   display_name: string
   money: number
   premium_purchasable: number
   premium_earnable: number
   honor: number
   vip_points: number
   vip_level: number
   currency_exchanges: ICurrencyExchange[]
   replicator_uses_today: number
   replicator_limit: number
   character: ICharacter
   fleet: IFleet
   squad: ISquad
   mailbox: IMailbox
   fleet_invite: IFleetInvite
   entitlements: IEntitlements
   //  chats: IChat
   commerce: ICommerce
   environment: IEnvironment
   featured_offers: IFeaturedOffer[]
   npe_complete: boolean
   community_links: ICommunityLink[]
}

export interface IDispute {
   id: number
   symbol: string
   desc_id: number
   name: string
   description: string
   episode: number
   systems: string[]
   marker: number[]
   marker_icon: IIcon
   points_icon: IIcon
   brand_icon: IIcon
   min_points: number
   expires_in: string
   first_mission: number
   intro: number
   factions: IFaction[]
   milestones: IMilestone[]
   rewards: IReward[]
   started: boolean
   milestone_text: string
}

export interface IDisputeHistory {
   id: number
   symbol: string
   name: string
   episode: number
   marker: number[]
   completed: boolean
   mission_ids: number[]
   stars_earned: number
   total_stars: number
   exclude_from_timeline: boolean
   faction_id: number
}

export interface IEntitlements {
   granted: IGranted[]
   claimed: IClaimed[]
}

export interface IEnvironment {
   tutorials: string[]
   restrictions: string
   flags: string[]
   background_idle_period: number
   hud_special_offer_poll_frequency: number
   pvp_enabled: boolean
   stasis_vault_enabled: boolean
   fleet_request_purge_threshold: number
   fleet_request_purge_expiration_days: number
   event_refresh_min_seconds: number
   event_refresh_max_seconds: number
   squadrons_enabled: boolean
   honor_enabled: boolean
   force_offer_popup_at_login: boolean
   adaptive_offers_enabled: boolean
   buy_back_enabled: boolean
   display_server_environment: boolean
   video_ad_campaign_limit: IVideoAdCampaignLimit
   gauntlet_enabled: boolean
   location_updates_enabled: boolean
   location_chat_enabled: boolean
   faction_event_order_randomized: boolean
   fleet_activities_enabled: boolean
   fleet_activities_restriction_enabled: boolean
   enable_server_toasts: boolean
   minimum_toast_delay_in_seconds: number
   starbase_enabled: boolean
   voyages_enabled: boolean
   starbase_refresh: number
   detect_conflict_mastery_errors: boolean
   reroll_enabled: boolean
   reroll_rarity_limit: number
   dilithium_purchase_popup_enabled: boolean
   dilithium_purchase_popup_threshold: number
   lazy_load_ui: boolean
   one_tap_craft_enabled: boolean
}

export interface IEquipmentSlot {
   level: number
   archetype: number
}

// TODO: IHow to use 'type' as a property name?
export interface IEvent {
   type: string
   quest_id: number
   id: number
   name: string
   description: string
   rules: string
   bonus_text: string
   rewards_teaser: string
   shop_layout: string
   featured_crew: IFeaturedCrew[]
   threshold_rewards: IThresholdReward[]
   ranked_brackets: IRankedBracket[]
   squadron_ranked_brackets: ISquadronRankedBracket[]
   content: IContent
   instance_id: number
   status: number
   seconds_to_start: number
   seconds_to_end: number
   phases: IPhase[]
   opened: boolean
   opened_phase: number
   victory_points: number
   bonus_victory_points: number
   claimed_threshold_reward_points: number
   unclaimed_threshold_rewards: IUnclaimedThresholdReward[]
   last_threshold_points: number
   next_threshold_points: number
   next_threshold_rewards: INextThresholdReward[]
}

export interface IFaction {
   id: number
   name: string
   reputation: number
   discovered: number
   completed_shuttle_adventures: number
   icon: IIcon
   representative_icon: IIcon
   representative_full_body: IIcon
   reputation_icon: IIcon
   reputation_item_icon: IIcon
   home_system: string
   shop_layout: string
   shuttle_token_id: number
   shuttle_token_preview_item: IShuttleTokenPreviewItem
   event_winner_rewards: string[]
   symbol: string
   points: number
   portrait: IIcon
   shuttle_token: number
   resolution_mission_id: number
   reward: IReward
}

export interface IFeaturedCrew {
   type: number
   id: number
   symbol: string
   name: string
   full_name: string
   flavor: string
   icon: IIcon
   portrait: IIcon
   rarity: number
   full_body: IFullBody
   skills: ISkills
   traits: string[]
   action: IAction
   quantity: number
}

export interface IFeaturedOffer {
   offer: IOffer
   status: IStatus
}

export interface IFleet {
   id: number
   nicon_index: number
   nleader_player_dbid: number
   nmin_level: number
   nstarbase_level: number
   slabel: string
   rank: string
   epoch_time: number
}

export interface IFleetActivities {
   id: number
   name: string
   description: string
   icon: IIcon
   area: string
   category: string
   total_points: number
   current_points: number
   milestones: IMilestone[]
   claims_available_count: number
}

export interface IFleetInvite {
   status: string
   sendable: number
   sent: number
   received: number
   accepted: number
   stores: IStore
}

export interface IFullBody {
   file: string
}

export interface IGoal {
   id: number
   faction_id: number
   flavor: string
   rewards: string[]
   winner_rewards: IWinnerReward
   victory_points: number
   claimed_reward_points: number
}

export interface IGranted {
   uuid: string
   gamer_tag: number
   symbol: string
   specialized: string
   state: string
   updated: number
   history: IHistory[]
}

export interface IHistory {
   what: string
   reason: string
   when: string
}

export interface IIcon {
   file: string
   atlas_info: string
}

export interface IImage {
   file: string
   url: string
   version: string
}

export interface Inumberro {
   text: string
   portrait: IIcon
   speaker_name: string
   response: string
}

export interface IItem {
   id: number
   type: number
   symbol: string
   name: string
   flavor: string
   archetype_id: number
   quantity: number
   icon: IIcon
   rarity: number
   expires_in: string
   short_name: string
   bonuses: IBonus
   time_modifier: number
   cr_modifier: number
   reward_modifier: number
   crafting_bonuses: IBonus[]
}

export interface ILocation {
   system: string
   place: string
   setup: string
   x: number
   y: number
}

export interface IMailbox {
   status: string
   sendable: number
   sent: number
   received: number
   accepted: number
   stores: IStore
}

export interface IMasterLimit {
   chance: number
   period_minutes: number
}

export interface IMilestone {
   text: string
   speaker_name: string
   portrait: IIcon
   event: IEvent
   goal: number
   rewards: IReward[]
   claimed: boolean
   claimable: boolean
}

export interface IMission {
   id: number
   title: string
   speaker: string
   description: string
   portrait: IIcon
   image: IImage
   image_small: IIcon
   requirement: string
}

export interface INavmap {
   places: IPlace[]
   systems: ISystem[]
}

export interface INextThresholdReward {
   type: number
   id: number
   symbol: string
   item_type: number
   name: string
   full_name: string
   flavor: string
   icon: IIcon
   quantity: number
   rarity: number
}

export interface IObtain {
   ent: string
   spec: string
   count: number
}

export interface IOffer {
   symbol: string
   image: IImage
   image_two: IImage
   title: string
   info: string
   bundle: string
   featured: boolean
   obtain: IObtain[]
   resettable: boolean
   daily_activity_applicable: boolean
   bonus_text: string
   bonus_text_two: string
   bonus_text_three: string
   purchase_limit: number
   active_stat_reqs: string[]
   subtitle: string
   subtitle_two: string
}

export interface IPenalty {
   type: number
   amount: number
}

export interface IPhase {
   splash_image: ISplashImage
   goals: IGoal[]
   id: number
   seconds_to_end: number
}

export interface IPlace {
   id: number
   symbol: string
   system: string
   client_asset: IClientAsset
   display_name: string
   visited: boolean
}

export interface IPotentialReward {
   type: number
   icon: IIcon
   rarity: number
   id: number
   symbol: string
   item_type: number
   name: string
   full_name: string
   flavor: string
   bonuses: IBonus
   potential_rewards: IPotentialReward[]
   quantity: number
}

export interface IPvpDivision {
   id: number
   tier: number
   name: string
   description: string
   min_ship_rarity: number
   max_ship_rarity: number
   max_crew_rarity: number
   setup: ISetup
}

export interface IPvpTicket {
   current: number
   max: number
   spend_in: number
   reset_in: number
}

export interface IPvpTimer {
   supports_rewarding: boolean
   pvp_allowed: boolean
   changes_in: number
}

export interface IRankedBracket {
   first: number
   last: number
   rewards: IReward[]
   quantity: number
}

export interface IRerollDescription {
   id: number
   jackpot: number
   crew_required: number
}

export interface IReward {
   type: number
   id: number
   symbol: string
   name: string
   full_name: string
   flavor: string
   icon: IIcon
   quantity: number
   rarity: number
   potential_rewards: IPotentialReward[]
   portrait: IIcon
   full_body: IFullBody
   skills: ISkills
   traits: string[]
   action: IAction
   item_type: number
}

export interface IRewardDay
{
   id: number
   symbol: string
   rewards: IReward[]
   double_at_vip: number
}

export interface ISchedule {
   day: number
   mission: number
}

export interface ISetup {
   ship_id: number
   slots: number[]
}

export interface IShip {
   archetype_id: number
   symbol: string
   name: string
   rarity: number
   icon: IIcon
   flavor: string
   max_level: number
   actions: IAction[]
   shields: number
   hull: number
   attack: number
   evasion: number
   accuracy: number
   crit_chance: number
   crit_bonus: number
   attacks_per_second: number
   shield_regen: number
   traits: string[]
   traits_hidden: string[]
   antimatter: number
   id: number
   level: number
   model: string
   schematic_gain_cost_next_level: number
   schematic_id: number
   schematic_icon: IIcon
   battle_stations: IBattleStation[]
}

export interface IShipBattle {
   accuracy: number
   evasion: number
   crit_chance: number
   crit_bonus: number
}

export interface IShuttle {
   id: number
   name: string
   description: string
   state: number
   expires_in: string
   faction_id: number
   slots: ISlot[]
   rewards: IReward[]
   token: number
   allow_borrow: boolean
   crew_bonuses: ICrewBonus
   shuttle_mission_rewards: IShuttleMissionReward[]
}

export interface IShuttleAdventure {
   id: number
   symbol: string
   name: string
   faction_id: number
   token_archetype_id: string
   challenge_rating: number
   shuttles: IShuttle[]
   completes_in_seconds: number
   x: number
   y: number
}

export interface IShuttleMissionReward {
   type: number
   icon: IIcon
   rarity: number
   potential_rewards: IPotentialReward[]
   quantity: number
   symbol: string
   name: string
   flavor: string
   faction_id: number
   id: number
}

export interface IShuttleTokenPreviewItem {
   type: number
   id: number
   symbol: string
   item_type: number
   name: string
   full_name: string
   flavor: string
   icon: IIcon
   quantity: number
   rarity: number
}

export interface ISkills {
   science_skill: IValueRange
   engineering_skill: IValueRange
   command_skill: IValueRange
   security_skill: IValueRange
   diplomacy_skill: IValueRange
   medical_skill: IValueRange
   primary_skill: string
   secondary_skill: string
}

export interface ISlot {
   level: string
   required_trait: string
   skills: string[]
   //  trait_bonuses: ITraitBonus
}

export interface ISplashImage {
   file: string
}

export interface ISquad {
   id: number
   slabel: string
   rank: string
}

export interface ISquadronRankedBracket {
   first: number
   last: number
   rewards: IReward[]
   quantity: number
}

export interface IStatus {
   purchase_avail: number
}

export interface IStore {
   social_friend: number
   game_reward: number
   social_gift: number
   system: number
   social_guild_info: number
   pvp_reward: number
   social_guild_invite: number
}

export interface IStoredImmortal {
   id: number
   quantity: number
}

export interface ISttRewardedChronitonBoost {
   chance: number
   period_minutes: number
}

export interface ISttRewardedCredit {
   chance: number
   period_minutes: number
}

export interface ISttRewardedDabo {
   chance: number
   period_minutes: number
}

export interface ISttRewardedScan {
   chance: number
   period_minutes: number
}

export interface ISttRewardedShuttle {
   chance: number
   period_minutes: number
}

export interface ISttRewardedWarp {
   chance: number
   period_minutes: number
}

export interface ISummary {
   name: string
   min: number
   max: number
}

export interface ISystem {
   id: number
   symbol: string
   x: number
   y: number
   default_place: string
   display_name: string
   star: number
   decorator: number
   faction: string
   scale: number
   active: boolean
}

export interface IThresholdReward {
   points: number
   rewards: IReward[]
}

export interface ITicketCounter {
   current: number
   max: number
   spend_in: string
   reset_in: number
}

//interface TraitBonus {
//}

export interface ITutorial {
   id: number
   symbol: string
   state: string
}

export interface IUnclaimedThresholdReward {
   type: number
   id: number
   symbol: string
   item_type: number
   name: string
   full_name: string
   flavor: string
   icon: IIcon
   quantity: number
   rarity: number
   bonuses: IBonus[]
}

export interface IValueRange {
   core: number
   range_min: number
   range_max: number
}

export interface IVideoAdCampaignLimit {
   master_limit: IMasterLimit
   stt_rewarded_scan: ISttRewardedScan
   stt_rewarded_warp: ISttRewardedWarp
   stt_rewarded_shuttle: ISttRewardedShuttle
   stt_rewarded_credits: ISttRewardedCredit
   stt_rewarded_dabo: ISttRewardedDabo
   stt_rewarded_chroniton_boost: ISttRewardedChronitonBoost
}

export interface IVideoAdChronitonBoostReward {
   type: number
   id: number
   symbol: string
   name: string
   full_name: string
   flavor: string
   icon: IIcon
   quantity: number
}

export interface IVoyageDescription {
   id: number
   symbol: string
   name: string
   description: string
   icon: string
   skills: ISkills
   ship_trait: string
   crew_slots: ICrewSlot[]
}

export interface IVoyageSummary {
   summaries: ISummary[]
   flavor_amount: number
}

export interface IWinnerReward {
   bonuses: IBonus
   time_modifier: number
   cr_modifier: number
   reward_modifier: number
   rewards: IReward[]
}

