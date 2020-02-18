class AccountApiController < ApplicationController
  
  before_filter :init
  
  # constants
  GAUNTLET_BOUTS = 4
  RECRUIT_MINUTES = 20
  STATUS_ERROR = 'alert'
  STATUS_SUCCESS = 'success'
  STATUS_INFO = 'info'
  
  def init
    @status = STATUS_SUCCESS
    @message = ''
    @data = {}
    if session[:account_id]
      if params[:token] == session[:token] #check for token
        @account_id = session[:account_id]
        @account = Account.find(@account_id)
      else
        render :json => {
          :status => STATUS_ERROR,
          :message => 'Invalid token provided with request.'
        }
      end
    else 
      render :json => {
        :status => STATUS_ERROR,
        :message => 'Must be logged in to carry out this action.'
      }
    end
  end
  
  def get_char_details
    Rails.cache.fetch 'get_char_details:'+params[:id].to_s, :expires_in => 1.minutes do
      @data[:char] = Character.load(params[:id], true)
      @data[:char_notis] = Notification_Manager.get_recent_by_char(@account_id, params[:id])
      render_response
    end
  end
  
  # UPDATE ACTIONS
  def do_buy_recruit
    recruit = Recruit.find_by_id_and_account_id(params[:id], @account_id)
    if @account.currency < recruit.price
      @status = STATUS_INFO
      @message = Message::MESSAGE_FAIL_BUY_RECRUIT
    else
      if (recruit.instance_of? Recruit)
        @status = STATUS_SUCCESS
        @message = Message::MESSAGE_BUY_RECRUIT
        char = Character.new
        char.level = 1
        char.exp = 0
        char.att_points = 0
        char.wins = 0
        char.losses = 0
        char.alive = 1
        char.kills = 0
        char.weapon_id = 1
        char.armour_id = 1
        char.name = recruit.name
        char.base_str = recruit.str
        char.base_agi = recruit.agi
        char.base_end = recruit.end
        char.base_int = recruit.int
        char.base_x = recruit.x
        char.account_id = @account_id
        char.save
        # save trait if any
        if (recruit.trait)
          ModsManager.add_trait(recruit.trait, char.id)
        end
        
        @account.decrement(:currency, recruit.price)
        recruit.destroy
      else
         @status = STATUS_ERROR
         @message = 'An error occured, recruitment failed.'
      end
    end
    
    render_response
  end
  
  def do_reject_recruit
    recruit = Recruit.find_by_id_and_account_id(params[:id], @account_id)
    if (recruit.instance_of? Recruit)
      @status = STATUS_SUCCESS
      @message = Message::MESSAGE_REJECT_RECRUIT
      
      recruit.destroy
    else
      @status = STATUS_ERROR
      @message = 'An error occured, unable to reject recruit.'
    end
    
    render_response
  end
  
  def do_increase_att
    char = Character.find_by_id_and_account_id(params[:id], @account_id)
    if (char.instance_of? Character)
      if (char.att_points > 0)
        case params[:attribute]
        when 'str'
          char.base_str += 1
        when 'agi'
          char.base_agi += 1
        when 'end'
          char.base_end += 1
        else
          @status = STATUS_ERROR
          @message = 'Failed: invalid attribute type.'
        end
        
        if status == STATUS_SUCCESS
          char.att_points -= 1
          char.save
          @data[:att_points] = char.att_points
        end
      else
        @status = STATUS_ERROR
        @message = 'Character has no free attribute points.'
      end
    else
      @status = STATUS_ERROR
      @message = 'An error occured, failed to increase attribute points.'
    end
    
    render_response
  end
  
  def do_update_character
    char = Character.find_by_id_and_account_id(params[:char_id], @account_id)
    if (char.instance_of? Character)
      
      char.name = params[:name]
      char.weapon_id = params[:weapon_id]
      char.armour_id = params[:armour_id]
      if char.valid?
        char.save
      else
        @status = STATUS_ERROR
        @message = char.errors.first
      end
    else
      @status = STATUS_ERROR
      @message = 'An error occured, failed to customize character.'
    end
    
    render_response
  end
  
  # BOUT ACTIONS
  
  def do_random_bout
    @char_1 = Character.load(params[:char_id], true)
    if @char_1.account.id != @account_id
      @data[:error] = 'Character must belong to your account'
    elsif @char_1.is_alive == false
      @data[:error] = 'Character must be alive'
    elsif @char_1.is_ready == false
      @data[:error] = 'Character must be ready'
    else
      @char_2 = CharGen.generate_character(@char_1.level, -2, 1, 2, 0)
      rs = Ruleset.create
      @data[:output] = BoutManager.start_bout(@char_1, @char_2, rs)
    end

    render_response
  end
  
  def get_valid_spars
    Rails.cache.fetch 'get_valid_spars:'+params[:id].to_s, :expires_in => 1.minutes do # minute cache
      @data[:my_char] = Character.find(params[:char_id]).short
      chars = Character.where("account_id > 0 AND account_id <> ? AND level between ? AND ? AND alive = ?", @account_id, @data[:my_char][:level] - 1, @data[:my_char][:level] + 3, true)
      
      @data[:chars] = Array.new
      chars.each do |char|
        char.calculate
        @data[:chars].push(char.spy(@account.spy_accuracy, @data[:my_char][:level]))
      end
      render_response
    end
  end
  
  def do_spar_bout
    @status = STATUS_ERROR
    @char_1 = Character.load(params[:char_1_id], true)
    if (@char_1.account.id != @account_id)
      @message = 'Character must belong to your account'
    elsif (@char_1.is_alive == false)
      @message = 'Character 1 must be alive'
    elsif @char_1.is_ready == false
      @message = 'Character must be ready'
    else
      @char_2 = Character.load(params[:char_2_id], true) # opponent open to challenges?
      if (@char_2.is_alive == false)
        @message = 'Character 2 must be alive'
      elsif @char_2.is_ready == false
        @message = 'Character 2 must be ready'
      else
        @status = STATUS_SUCCESS
        rs = ShowRuleset.create
        @data[:output] = BoutManager.start_bout(@char_1, @char_2, rs)
      end
    end
    
    render_response
  end
  
  def do_pit_bout
    @char_1 = Character.load(params[:id], true)
    if (@char_1.account.id != @account_id)
      @data[:error] = 'Character must belong to your account'
    elsif (@char_1.is_alive == false)
      @data[:error] = 'Character must be alive'
    elsif @char_1.is_ready == false
      @data[:error] = 'Character must be ready'
    else
      @data[:output] = BoutManager.start_bout_gauntlet(@char_1, GAUNTLET_BOUTS, 1)
    end
    
    render_response
  end
  
  # LUDUS TEMPLATE DATA
  def get_summary
    Rails.cache.fetch 'get_summary:'+@account_id.to_s, :expires_in => 1.minutes do
      @data[:account_name] = @account.account_name
      @data[:currency] = @account.currency
      @data[:glory] = @account.glory
      @data[:ga_count] = Character.where("account_id = ? AND alive = ?", @account_id, true).count
      @data[:gd_count] = Character.where("account_id = ? AND alive = ?", @account_id, false).count
      render_response
    end
  end
  
  def get_ludus_summary
    Rails.cache.fetch 'get_ludus_summary'+@account_id.to_s, :expires_in => 1.minutes do # minute cache
      @data[:g_count] = Character.where("account_id = ? AND alive = ?", @account_id, true).count
      @data[:r_count] = Recruit.where(:account_id => @account_id).count
      
      if (@account.last_recruited.nil?)
        recruit_ms = 0
      else
        recruit_ms = (@account.last_recruited + RECRUIT_MINUTES.minutes).to_i * 1000
      end
      @data[:ms_until_recruit] = {:time_until_recruit => recruit_ms}
      render_response
    end
  end
  
  def get_ludus_recruits
    Rails.cache.fetch 'get_ludus_recruits'+@account_id :expires_in => 1.minutes do # minute cache
      data = {}
  
      current_recruits = Recruit.where(:account_id => @account_id)
      
      recruits = Array.new
      sec_to_recruit = sec_until_recruit
      if sec_to_recruit == 0 and current_recruits.count < 4
        current_recruits.each do |r|
          recruits.push(r)
        end
        (1..(4 - current_recruits.count)).each do |n|
          recruit = CharGen.generate_recruit(@account_id)
          recruits.push(recruit)
        end
        @account.last_recruited = Time.now
        @account.save
        @data[:recruits] = recruits
        # @data[:last_recruited] = @account.last_recruited.strftime('%d/%m/%Y %T')
        # @data[:time_until_recruit] = (@account.last_recruited + RECRUIT_MINUTES.minutes).to_i * 1000
        @message = Message::MESSAGE_NEW_RECRUITS
      else
        @data[:recruits] = current_recruits
        # @data[:last_recruited] = @account.last_recruited.nil? ? '' : @account.last_recruited.strftime('%d/%m/%Y %T')
        # @data[:time_until_recruit] = (Time.now + sec_to_recruit.seconds).to_i * 1000
        @message = Message::MESSAGE_SHOW_RECRUITS
      end
       render_response
    end
  end
  
  def get_ludus_roster
    Rails.cache.fetch 'get_ludus_roster'+@account_id.to_s, :expires_in => 1.minutes do # minute cache
      @data[:chars] = Character.where("account_id = ? AND alive = ?", @account_id, true)
      
      render_response
    end
  end
  
  def get_ludus_history
    Rails.cache.fetch 'get_ludus_history'+@account_id.to_s, :expires_in => 1.minutes do # minute cache
      @data[:chars] = Character.where("account_id = ? AND alive = ?", @account_id, false)
      render_response
    end
  end
  
  def get_ludus_char
    @data[:char] = Character.load(params[:id], true)
    @data[:char_notifications] = Notification_Manager.get_recent_by_char(@account_id, params[:id])
    
    render_response
  end
  
  # ARENA TEMPLATE DATA
  def get_arena_summary
    @data[:recent_bouts] = Notification_Manager.get_my_recent_bouts_cached(@account_id, 10)
    
    @data[:chars_registered] = Array.new
    Character.where("account_id = ? AND tourney_id > 0", @account_id).each do |c|
      tourney = TourneyManager.get_tourney_name(c.tourney_id)
      @data[:chars_registered].push({:name => c.name, :tourney => tourney})
    end
    
    render_response
  end
  
  def get_arena_watch
      @data[:recent_bouts] = Notification_Manager.get_all_recent_bouts_cached(10)
      render_response
  end
  
  def get_arena_games
      #TODO: get chars that are alive and have recovery_time < now
      
      render_response
  end
  
  def get_arena_tourney
      @data[:tourneys] = TourneyManager.get_status
      render_response
  end

  def get_tourney_eligible
    @data[:tourney_id] = params[:tourney_id]

    @data[:entered_chars] = [];
    Character.where("tourney_id = ? AND alive = ?", params[:tourney_id], true).each do |c|
      @data[:entered_chars].push({:name => c.name, :ludus_name => c.ludus_name, :id => c.id, :is_mine => c.account_id == @account_id})
    end
    @data[:eligible_chars] = [];
    Character.where("tourney_id IS NULL AND alive = ? AND account_id = ?", true, @account_id).each do |c|
      @data[:eligible_chars].push({:name => c.name, :id => c.id})
    end

    render_response
  end

  def do_enter_tourney
    c = Character.load(params[:char_id], false)
    c.register_tourney(params[:tourney_id])

    @message = 'Gladiator was entered into tourney'

    render_response
  end

  def do_attempt_spy

    c = Character.load(params[:char_id], true)

    @data[:char] = c.spy(50, false)

    render_response
  end
  
  def get_bout_actions
    bouts = Array.new
    bout_hashes = params[:hash].split(',')
    if (bout_hashes.length > 1)
      bout_hashes.each do |hash|
        bouts.push(BoutHistory.where("hash_key = ?", hash).first.to_json)
      end
    else
      bouts.push(BoutHistory.where("hash_key = ?", params[:hash]).first.to_json)
    end
    
    @data[:bouts] = bouts

    render_response
  end
  
  # NOTIFICATIONS DATA
  def get_notifications
    @data[:notifications] = Notification_Manager.get_recent(@account_id)
    
    render_response
  end
  
  def get_notification
    @data[:notifications] = Notification.where("account_id = ? AND id = ?", @account_id, params[:id]).first
    
    render_response
  end
  
  def get_unread_notifications
    done = false
    while (done == false)
      sleep 10
      notis = Notification_Manager.get_unread(@account_id)
      done = notis.empty? == false
    end
    
    render :json => {
      :status => STATUS_SUCCESS,
      :message => '',
      :data => {:notifications => notis}
    }
  end
  
  def get_equipment_data
    @data[:weap_store] = Weapon.find(:all)
    @data[:arm_store] = Armour.find(:all)
    
    render_response
  end
  
  # PRIVATE HELPER METHODS
  private
  def sec_until_recruit
    unless @account.last_recruited.nil?
      # and not more than a day ago
      sec_until_recruit = (@account.last_recruited + 10.minutes) - Time.now
      if (sec_until_recruit > 0)
        return sec_until_recruit
      else
        return 0
      end
    end
    
    return 0
  end
  
  def render_response
    render :json => {
      :status => @status,
      :message => @message,
      :data => @data
    }
  end

end
