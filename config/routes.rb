GrDev::Application.routes.draw do

  # dev commands / testing
  match 'commands/rebuild_db' => 'commands#rebuild_db'
  
  # auth requests
  match 'request/do_create_account' => 'public_api#do_create_account'
  match 'request/do_attempt_login' => 'public_api#do_attempt_login'
  match 'request/do_logout' => 'public_api#do_logout'
  match 'request/do_verify_code/:code' => 'public_api#do_verify_code'
  
  # account requests
  match 'request/do_buy_recruit' => 'account_api#do_buy_recruit'
  match 'request/do_reject_recruit' => 'account_api#do_reject_recruit'
  match 'request/do_increase_att' => 'account_api#do_increase_att'
  match 'request/do_update_character' => 'account_api#do_update_character'
  match 'request/get_summary' => 'account_api#get_summary'
  
  # ludus requests
  match 'request/get_ludus_summary' => 'account_api#get_ludus_summary'
  match 'request/get_ludus_roster' => 'account_api#get_ludus_roster'
  match 'request/get_ludus_recruits' => 'account_api#get_ludus_recruits'
  match 'request/get_ludus_history' => 'account_api#get_ludus_history'
  
  # arena requests
  match 'request/get_arena_summary' => 'account_api#get_arena_summary'
  match 'request/get_arena_watch' => 'account_api#get_arena_watch'
  match 'request/get_arena_games' => 'account_api#get_arena_games'
  match 'request/get_arena_tourney' => 'account_api#get_arena_tourney'

  # arena actions
  match 'request/get_tourney_eligible' => 'account_api#get_tourney_eligible'
  match 'request/do_enter_tourney' => 'account_api#do_enter_tourney'
  match 'request/do_attempt_spy' => 'account_api#do_attempt_spy'
  
  # char / bout requests
  match 'request/get_char_details' => 'account_api#get_char_details'
  match 'request/get_char_details/:id' => 'account_api#get_char_details'
  match 'request/get_bout_actions/:hash' => 'account_api#get_bout_actions'
  match 'request/do_random_bout' => 'account_api#do_random_bout'
  match 'request/do_random_bout/:char_id' => 'account_api#do_random_bout'
  match 'request/get_valid_spars' => 'account_api#get_valid_spars'
  match 'request/get_valid_spars/:char_id' => 'account_api#get_valid_spars'
  match 'request/do_spar_bout' => 'account_api#do_spar_bout'
  match 'request/do_spar_bout/:char_id_1/:char_id_2' => 'account_api#do_spar_bout'
  match 'request/do_pit_bout/:char_id' => 'account_api#do_pit_bout'
  
  # data requests
  match 'request/get_equipment_data' => 'account_api#get_equipment_data'
  
  # notification requests
  match 'request/get_notifications' => 'account_api#get_notifications'
  match 'request/get_notification/:id' => 'account_api#get_notification'
  match 'request/get_unread_notifications' => 'account_api#get_unread_notifications'
  
end
