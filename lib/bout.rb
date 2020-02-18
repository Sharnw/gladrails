class Bout
  
  attr_reader :char_1, :char_2, :actions

  def initialize(char_1, char_2, ruleset)
    @char_1 = char_1
    @char_2 = char_2
    @actions = Array.new
    @action_iterator = rand(2)
    @skip_next_action = false
    @counter_next_action = false
    
    roll_mental # roll for mental advantage (intimidated/prepared)
    
    @rep = ReportBuilder.instance
    @rs = ruleset
  end
  
  def inspect
    return 'Match-up: ' + @char_1.name + ' vs ' + @char_2.name
  end
  
  def roll_mental
    if Roll.roll_percent((@char_1.intimidate + @char_1.chaos_amount) * 2)
      @char_2.intimidated = true
    end
    if Roll.roll_percent((@char_2.intimidate + @char_2.chaos_amount) * 2)
      @char_1.intimidated = true
    end
    
    if Roll.roll_percent((@char_1.judgement + @char_1.chaos_amount) * 6)
      @char_1.prepared = true
    end
    if Roll.roll_percent((@char_2.judgement + @char_2.chaos_amount) * 6)
      @char_2.prepared = true
    end
  end
  
  def get_result
    output = ''
    @actions.each { |action| output += action.to_s + "<br>"}
    return output
  end
  
  def get_xml
    simple_actions = Array.new
    @actions.each { |a| 
     simple_actions.push(a.to_hash)
    }
    
    return simple_actions.to_xml
  end
  
  def get_json
    simple_actions = Array.new
    @actions.each { |a| 
      simple_actions.push(a.to_hash)
    }
    
    return simple_actions.to_json
  end
  
  def log_history
    bout_hist = BoutHistory.new
    bout_hist.winner_id = winner_id
    bout_hist.loser_id = loser_id
    bout_hist.acc_1_id = @char_1.account.id
    bout_hist.acc_2_id = @char_2.account.id
    bout_hist.json_text = get_json
    bout_hist.hash_key = Digest::MD5.hexdigest(Account.random_string(10))
    bout_hist.save
    return bout_hist
  end
  
  # check characters for injuries
  def check_injuries
      if (@char_1.generated < 1)
        if @rs.roll_injury(@char_1.state) # roll for minor injury
            mod = CharMod.get_random_minor_mod
            if (@char_1.active_conditions.has_key?(mod) == false)
              # create / save mod
              m_obj = CharMod.create_timed(mod, CharMod::MOD_TYPE_CONDITION, @char_1.id, 60)
              m_obj.save
              @char_1.active_conditions[mod] = m_obj
              # log message
              message = m_obj.message % @char_1.name
              @rep.log_owned(Message.new(message, Message::TYPE_INJURY), @char_1.account_id)
              Notification_Manager.log_new(Message.new(message, Message::TYPE_INJURY).to_s,'', @char_1.account_id, @char_1.id,Notification_Manager::TYPE_REWARD, nil)
            end
        end
        if @rs.roll_major_injury(@char_1.state) # roll for major injury
            mod = CharMod.get_random_major_mod
            if (@char_1.active_conditions.has_key?(mod) == false)
              # create / save mod
              m_obj = CharMod.create_perma(mod, CharMod::MOD_TYPE_CONDITION, @char_1.id)
              m_obj.save
              @char_1.active_conditions[mod] = m_obj
              # log message
              message = m_obj.message % @char_1.name
              @rep.log_owned(Message.new(message, Message::TYPE_INJURY), @char_1.account_id)
              Notification_Manager.log_new(Message.new(message, Message::TYPE_INJURY).to_s,'', @char_1.account_id, @char_1.id, Notification_Manager::TYPE_INJURY, nil)
            end
        end
      end

      if (@char_2.generated < 1)
          if @rs.roll_injury(@char_2.state) # roll for minor injury
              mod = CharMod.get_random_minor_mod
              if (@char_2.active_conditions.has_key?(mod) == false)
                # create / save mod
                m_obj = CharMod.create_timed(mod, CharMod::MOD_TYPE_CONDITION, @char_2.id, 60)
                m_obj.save
                @char_2.active_conditions[mod] = m_obj
                # log message
                message = m_obj.message % @char_1.name
                @rep.log_owned(Message.new(message, Message::TYPE_INJURY), @char_2.account_id)
                Notification_Manager.log_new(Message.new(message, Message::TYPE_INJURY).to_s,'', @char_2.account_id, @char_2.id,Notification_Manager::TYPE_INJURY, nil)
              end
          end
          if @rs.roll_major_injury(@char_2.state) # roll for major injury
              mod = CharMod.get_random_major_mod
              if (@char_2.active_conditions.has_key?(mod) == false)
                # create / save mod
                m_obj = CharMod.create_timed(mod, CharMod::MOD_TYPE_CONDITION, @char_2.id, 60)
                m_obj.save
                @char_2.active_conditions[mod] = m_obj
                # log message
                message = m_obj.message % @char_1.name
                @rep.log_owned(Message.new(message, Message::TYPE_INJURY), @char_2.account_id)
                Notification_Manager.log_new(Message.new(message, Message::TYPE_INJURY).to_s,'', @char_2.account_id, @char_2.id,Notification_Manager::TYPE_INJURY, nil)
              end
          end
      end
      
      if @@char_lose.is_alive and @rs.roll_death  # roll for death from wounds
        @@char_lose.alive = false
        @@char_win.increment(:kills, 1)
        if @@char_lose.generated == 0
          message = Notification_Manager::MESSAGE_DEATH % @@char_lose.name
          @rep.log_owned(message, @@char_lose.account_id)
          Notification_Manager.log_new(Message.new(message, Message::TYPE_DEATH).to_s,'', @@char_lose.account_id, @@char_lose.id,Notification_Manager::TYPE_INJURY, nil)
        end
      end
  end
  
  def allocate_rewards
    reward_messages = Array.new
    reward_messages.push('<br />')
    
    if @@char_win.generated == 0
      # EXP REWARD
      win_exp = 10 + (7 * @@char_win.level)
      win_exp = (win_exp * @rs.xp_mod).floor
      if win_exp > 0
        message = Message.new(Notification_Manager::MESSAGE_WIN_EXP % [@@char_win.name, win_exp.to_s], Message::TYPE_REWARD)
        if @@char_win.account.id == @char_1.account.id
          reward_messages.push(message)
        end
        @rep.log_owned(message, @@char_win.account_id)
        @@char_win.increment(:exp, win_exp)
      end
      
      # CURRENCY REWARD
      win_cur = (5 * @@char_win.level) + ((@@char_lose.level - @@char_win.level) * 3)
      win_cur = (win_cur * @rs.cur_mod).floor
      if win_cur > 0
        message = Message.new(Notification_Manager::MESSAGE_WIN_PURSE % win_cur.to_s, Message::TYPE_REWARD)
        if @@char_win.account.id == @char_1.account.id
          reward_messages.push(message)
        end
        @rep.log_owned(message, @@char_win.account_id)
        @@char_win.account.increment(:currency, win_cur)
      end
      
      # GLORY REWARD (40% chance + 2% per level)
      if (@rs.glr_mod > 0 and Roll.roll_percent(40 + (2 * @@char_win.level)))
        # 4 glory per level (modified by ruleset etc)
        win_glory = ((4 * @@char_lose.level * @@char_lose.glr_mod) * @rs.glr_mod).floor
        message = Message.new(Notification_Manager::MESSAGE_WIN_GLORY % [@@char_win.name, win_glory.to_s], Message::TYPE_REWARD)
        if @@char_win.account.id == @char_1.account.id
          reward_messages.push(message)
        end
        @rep.log_owned(message, @@char_win.account_id)
        @@char_win.increment(:glory, win_glory)
        @@char_win.account.increment(:glory, win_glory)
      end
      
       @@char_win.account.save
       @@char_win.save
    end
    
    if @@char_lose.generated == 0
      # EXP REWARD
      lose_exp = 5 + (4 * @@char_lose.level)
      lose_exp = (lose_exp * @rs.xp_mod).floor
      if lose_exp > 0
        message = Message.new(Notification_Manager::MESSAGE_WIN_EXP % [@@char_lose.name, lose_exp.to_s], Message::TYPE_REWARD)
        if @@char_lose.account.id == @char_1.account.id
          reward_messages.push(message)
        end
        @rep.log_owned(message, @@char_lose.account_id)
        @@char_lose.increment(:exp, lose_exp)
      end
      
      # DEATH GLORY REWARD (20% chance +3% Per level)
      if (@@char_lose.is_alive == false and Roll.roll_percent(20 + (3 * @@char_lose.level)))
        # 20 glory per level (modified by ruleset)
        death_glory = ((20 * @@char_lose.level * @@char_lose.glr_mod) * @rs.glr_mod).floor
        message = Message.new(Notification_Manager::MESSAGE_DEATH_GLORY % [@@char_lose.name, death_glory.to_s], Message::TYPE_REWARD)
        if @@char_lose.account.id == @char_1.account.id
          reward_messages.push(message)
        end
        @rep.log_owned(message, @@char_lose.account_id)
        @@char_lose.account.increment(:glory, death_glory)
        @@char_lose.account.save
      end
      
       @@char_lose.account.save
       @@char_lose.save
    end

    return reward_messages
  end
  
  def save
    if @@char_win.generated == 0
      @@char_win.set_recovery
      @@char_win.increment(:wins, 1)
      @@char_win.save
    end
    if @@char_lose.generated == 0
      @@char_lose.set_recovery
      @@char_lose.increment(:losses, 1)
      @@char_lose.save
    end
    unless @@char_lose.generated == 1 and @@char_win.generated == 1
      return log_history
    end
    return false
  end
  
  def apply_action(action)
    @actions.push(action)
    
    # update char hp
    if (action.type == Action::TYPE_DMG_OTHER)
      other_char.take_dmg(action.amount)
      if other_char.is_ok == false
        # assign winner / loser
        @@char_win = current_char
        @@char_lose = other_char
        if @rs.roll_death # roll for insta-death
          @@char_lose.alive = false
          @@char_win.increment(:kills, 1)
          # log death action
          @actions.push(Action.new(other_char, Action::TYPE_DIE, 0, Message.new(Action::MESSAGE_DIE, Message::TYPE_DIE)))
        else
          # log fainted action
          @actions.push(Action.new(other_char, Action::TYPE_FAINT, 0, Message.new(Action::MESSAGE_FAINT, Message::TYPE_FAINT)))
        end
       end
    elsif action.type == Action::TYPE_DMG_SELF
       current_char.take_dmg(action.amount)
       if current_char.is_ok == false
         # assign winner / loser
         @@char_win = other_char
         @@char_lose = current_char
         
        if @rs.roll_death # roll for insta-death
          @@char_lose.alive = false
          @@char_win.increment(:kills, 1)
          # log death action
          @actions.push(Action.new(current_char, Action::TYPE_DIE, 0, Message.new(Action::MESSAGE_DIE, Message::TYPE_DIE)))
        else
          # log fainted action
          @actions.push(Action.new(current_char, Action::TYPE_FAINT, 0, Message.new(Action::MESSAGE_FAINT, Message::TYPE_FAINT)))
        end
       end
    end
    
  end
  
  def char_win
    return @@char_win
  end
  
  def char_lose
    return @@char_lose
  end
  
  def next_action
    # iterate current char
    next_char
    if (@skip_next_action) # if char has been interrupted skip action
      @skip_next_action = false
      apply_action(Action.new(current_char, Action::TYPE_SKIP, 0, Message.new(Action::MESSAGE_SKIPPED, Message::TYPE_MISC)))
    else
      attempt_special # attempt special (knockdown/trip)
      apply_action(attack_roll)
    end
  end
  
  def next_char
     @action_iterator += 1
  end
  
  def current_char
     case @action_iterator % 2       
     when 1
       return @char_1
     when 0
       return @char_2
     end
  end
  
  def other_char
     case @action_iterator % 2       
     when 1
       return @char_2
     when 0
       return @char_1
     end
  end
  
  def is_finished
    return (@char_1.is_ok == false or @char_2.is_ok == false)
  end
  
  def winner_id
    return @@char_win.id
  end
  
  def loser_id
    return @@char_lose.id
  end
  
  def dodge_roll
    # roll for dodge
    dodge_roll = Roll.roll_range(1, current_char.weapon.dodge_range)
    return dodge_roll <= other_char.dodge_percent
  end
  
  def deflect_roll
    # roll for deflect
    deflect_roll = Roll.roll_range(1, current_char.weapon.deflect_range)
    return deflect_roll <= other_char.deflect_percent
  end
  
  def attempt_special
    # 1 in 8 chance of attempting special
    if (rand(8) == 5)
      if (current_char.str > current_char.agi)
        # attempt overpower
        my_roll = current_char.str + Roll.roll_range(1, 30)
        target_roll = other_char.str + Roll.roll_range(1, 60) + (other_char.discipline + other_char.chaos_amount)
        # subtract 10 from roll if arm is weakened
        if (other_char.is_arm_weak)
          target_roll += -10
        end
        if (my_roll > target_roll)
          apply_action(Action.new(current_char, Action::TYPE_OVERPOWER, 0, Message.new(Action::MESSAGE_OVERPOWER % other_char.name, Message::TYPE_ATTACK_SPECIAL)))
          @skip_next_action = true
        end
      else
        # attempt trip
        my_roll = current_char.agi + ((current_char.str - 10) / 4) + Roll.roll_range(1, 30)
        target_roll = other_char.agi + Roll.roll_range(1, 60) + other_char.discipline
        # subtract 10 from roll if arm is weakened
        if (other_char.is_leg_weak)
          target_roll += -10
        end
        if (my_roll > target_roll)
          apply_action(Action.new(current_char, Action::TYPE_TRIP, 0, Message.new(Action::MESSAGE_TRIP % other_char.name, Message::TYPE_ATTACK_SPECIAL)))
          @skip_next_action = true
        end
      end
    end
  end
  
  def attack_roll
    dmg_mod = 1
    if @counter_next_action
      # counter cannot be prevented
      apply_action(Action.new(current_char, Action::TYPE_DMG_OTHER, 0, Message.new(Action::MESSAGE_COUNTER % other_char.name, Message::TYPE_ATTACK_SPECIAL)))
      dmg_mod = 1.5
      @counter_next_action = false
    else
      # if intimidated 10% chance of doing nothing
      if current_char.intimidated and Roll.roll_percent(10)
        return Action.new(current_char, Action::TYPE_WAIT, 0, Message.new(Action::MESSAGE_INTIMIDATED, Message::TYPE_ATTACK_SPECIAL))
      end
      
      # roll for counter (current_char countered)
      if current_char.prepared and Roll.roll_percent(10)
        @counter_next_action = true
        return Action.new(current_char, Action::TYPE_MISS_COUNTERED, 0, Message.new(Action::MESSAGE_MISS_COUNTERED, Message::TYPE_DEFENSE))
      end
      
      if dodge_roll
        return Action.new(current_char, Action::TYPE_MISS_DODGE, 0, Message.new(Action::MESSAGE_MISS_DODGE, Message::TYPE_DEFENSE))
      end
  
      if deflect_roll
        return Action.new(current_char, Action::TYPE_MISS_DEFLECT, 0, Message.new(Action::MESSAGE_MISS_DODGE, Message::TYPE_DEFENSE))
      end
    end
    
    dmg = (current_char.roll_weapon_dmg + current_char.chaos_amount * dmg_mod).floor
    
    crit_range = current_char.crit_range

    crit_roll = Roll.roll_range(1, 100)

    if (crit_roll <= current_char.fail_range)
      dmg = dmg * current_char.weapon.crit
      return Action.new(current_char, Action::TYPE_DMG_SELF, dmg, Message.new(Action::MESSAGE_CRIT_FAIL % dmg.to_s, Message::TYPE_ATTACK_SPECIAL))
    elsif (crit_roll >= (99 - current_char.x_mod))
      dmg = dmg *  (current_char.weapon.crit * 2)
      return Action.new(current_char, Action::TYPE_DMG_OTHER, dmg, Message.new(Action::MESSAGE_LUCKY_CRIT % dmg.to_s, Message::TYPE_ATTACK_SPECIAL))
    elsif (crit_roll >= 10 and crit_roll <= crit_range)
      dmg = dmg * current_char.weapon.crit
      return Action.new(current_char, Action::TYPE_DMG_OTHER, dmg, Message.new(Action::MESSAGE_CRIT % dmg.to_s, Message::TYPE_ATTACK_SPECIAL))
    end

    return Action.new(current_char, Action::TYPE_DMG_OTHER, dmg, Message.new(Action::MESSAGE_HIT % dmg.to_s, Message::TYPE_ATTACK))
  end
  
end