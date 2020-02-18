module CharManager
  
  attr_reader :weapon, :armour, :str, :agi, :end, :int, :x, :intimidate, :discipline, :judgement, :hp, :dmg_taken, :state, :can_train
  
  attr_accessor :generated, :intimidated, :prepared
  
  # calculates modified attributes given equipment, traits, and conditions
  def calculate
    @calculated = true
    
    @weapon = Weapon.find(weapon_id)
    @armour = Armour.find(armour_id)
    
    # hp
    @base_hp = 20 + (level * 5) + (((base_end - 10) * level) / 2.5).round
    @dmg_taken = 0
    
    @intimidate = 0
    @discipline = 0
    @judgement = 0

    @can_train = true
    
    # load modifiers
    load_mods
    apply_mods
    
    # calculated values used in attack / dodge rolls
    @str_mod = (@str - 10) / 2
    @agi_mod = (@agi / 2).floor
    @int_mod = ((@int - 10) / 2).floor
    @x_mod = (@x / 2).floor

    
    @crit_range = 5 + @agi_mod + (@int_mod / 2)
    @str_dmg = (@str_mod + ((@str_mod * level) * 0.05)).ceil

    @dodge_percent = @agi_mod + @x_mod + (@int_mod / 2)
    @armour.is_light ? @dodge_percent += 5 : @dodge_percent -= 3
    @deflect_percent = (@str_mod / 2).floor  + (@int_mod / 2)
    
    if @armour.is_heavy
      @deflect_percent += 7 # add 7% bonus for heavy armour
    else
      @dodge_percent += 5  # add 5% bonus for light armour
      @judgement += 1
    end
    
    # skill mods
    @intimidate += @str_mod + @int_mod
    @discipline += @str_mod + @int_mod
    @judgement += @int_mod
    
    @generated = 0
    @state = 1
    @intimidated = false
    @prepared = false
  end
  
  # DYNAMIC ATTRIBUTES
  
  def account
    unless generated == 1
      return Account.find(account_id)
    else
      return DummyAccount.new
    end
  end
  
  def ludus_name
    unless generated == 1
      return account.account_name
    else
      return 'Ludus Magnus'
    end
  end
  
  def glr_mod # glory modifier
    case level
      when 1..5
        return 0.9
      when 6..10
        return 1.5
      else
        return 2.5
    end
  end
  
  def x_mod #chaos modifier
    return @x_mod
  end
  
  # RECOVERY ATTRIBUTES
  def set_recovery
    secs = 180 + (30 * level)
    # NOTE: overwritten for testing
    secs = 90
    recovery_time = Time.now.utc + secs.seconds
  end
  
  def is_ready
    return recovery_sec == 0
  end
  
  def recovery_sec
    if recovery_time
      recovery_sec = recovery_time - Time.now
      if (recovery_sec > 0)
        return recovery_sec
      end
    end
    return 0
  end
  
  def recovery_time_ms
    return recovery_time.to_i * 1000
  end
  
  # COMBAT ROLLS & ATTRIBUTES 
  
  def reset_dmg
    @dmg_taken = 0
  end
  
  def roll_weapon_dmg
    # base dmg + 5% per lvl + strength modifier
    dmg = (@weapon.roll_dmg * (1 + (level * 0.05))) + @str_dmg
    
    # dmg buff/debuff depending on char state
    case @state
      when 2
        dmg += (dmg * 0.1)
      when 3
        dmg += (dmg * -0.1)
      when 4
        dmg += (dmg * 0.15)
    end

    return dmg > 0 ? dmg.ceil : 0
  end

  def crit_range
    crit_range = @crit_range
    if (@state == 4)
      # 5% bonus for desperate
      crit_range += 5
    end
    return crit_range + @x_mod
  end
  
  def chaos_amount
    return @x_mod == 0 ? 0 : Roll.roll_chaos(@x_mod)
  end
  
  def fail_range
    return @weapon.fail_range + @x_mod
  end

  def dodge_percent
    # add 3% bonus if desperate
    return @state == 4 ? @dodge_percent + 3: @dodge_percent
  end
  
  def deflect_percent
    # add 3% bonus if desperate
    return @state == 4 ? @deflect_percent + 3 : @deflect_percent
  end
  
  
  # CHARACTER STATE
  
  def is_ok
    return @dmg_taken < @hp
  end
  
  def is_alive
    return alive
  end
  
  def update_state
    if (@dmg_taken > 0)
      case
        when @dmg_taken/@hp.to_f <= 0.20
          # hp > 80% = fresh
          @state =  1
        when @dmg_taken/@hp.to_f <= 0.50
          # hp > 25% = warmed up (dmg bonus)
          @state = 2
        when @dmg_taken/@hp.to_f <= 0.80
          # hp > 25% = injured dmg debuff, lessened by end)
          @state =  3
        else
          # hp < 25% = desperate (crit bonus, dodge/def bonus)
          @state =  4
      end
    end
  end

  
  # XP / LEVEL METHODS
  def desired_xp
     return (200 * level * (level + 1)).to_i
  end
  
  def check_level
    if (exp >= desired_xp)
      message = Message.new(Notification_Manager::MESSAGE_LEVEL_UP % name, Message::TYPE_REWARD)
      Notification_Manager.log_new(message.to_s,'', account_id, id, NotificationManager::TYPE_REWARD, nil)
      level_up
    end
  end
  
  def level_up
    increment(:level, 1)
    case rand(1..3)
      when 1
        increment(:base_str, 1)
      when 2
        increment(:base_agi, 1)
      when 3
        increment(:base_end, 1)
    end
    # free att point every 2nd level
    if (level % 2 == 0)
      increment(:att_points, 1)
    end
  end

  
  # ACTIONS
  
  def attempt_training
    if @can_train and tourney_id.nil?
    #add_training_xp
      case level
      when 1..4
        add_training_xp
      else
        if (wins + losses) < (3 * level)
          #training = false
        else
          add_training_xp
        end
      end
      save
    end
  end
  
  def add_training_xp
    if Roll.roll_percent(2)
      ModsManager.add_trait(CharMod::TYPE_WELL_DRILLED, id)
    end
    
    increment(:exp, level * 4)
    check_level
    save
  end
  
  def register_tourney(t_id)
    update_attribute(:tourney_id, t_id) 
    save
  end
  
  def remove_tourney
    update_attribute(:tourney_id, nil) 
    save
  end
  
  def take_dmg(amount)
    @dmg_taken += amount
    update_state
  end
  
  def reset
    @dmg_taken = 0
    @state = 1
  end


  # DESCRIPTION FIELDS
  def status
    return recovery_sec == 0 ? 'Ready' : 'Recovering'
  end
  
  def level_xp
    return level.to_s + ' (' + exp.to_s + ')'
  end
  
  # OUTPUT
  
  def char_report # for use in tasks & testing
    output = "\n" + name + "\n"
    output << 'Stats: ' + str.to_s + ' / ' + agi.to_s + ' / ' + @end.to_s + ' (' + @hp.to_s + ") \n"
    output << 'Chaos ' + x.to_s + " \n"
    output << 'Level: ' + level.to_s + " \n"
    output << 'Wins: ' + wins.to_s + "\n"
    output << 'Losses: ' + losses.to_s + " \n"
    output << 'Weapon: ' + @weapon.to_s + " \n"
    output << 'Armour: ' + @armour.to_s + " \n"
    output << 'Mods: ' + condition_summary + "\n"
    output << 'Traits: ' + trait_summary + "\n"
    output << 'Alive: ' + is_alive.to_s + "\n"
    return output
  end
  
  # CUSTOM JSON OUTPUT
  def as_json(options={})
    #super(:only => [:weapon], :methods =>[:status, :name])
    if @calculated
      response = {
        :id => id,
        :name => name,
        :status => status,
        :is_ready => is_ready,
        :recovery_time_ms => recovery_time_ms,
        :level => level,
        :exp => exp,
        :att_points => att_points,
        :base_str => base_str,
        :base_agi => base_agi,
        :base_end => base_end,
        :base_int => base_int,
        :base_x => base_x,
        :str => @str,
        :agi => @agi,
        :end => @end,
        :int => @int,
        :x => @x,
        :intimidate => @intimidate,
        :discipline => @discipline,
        :judgement => @judgement,
        :wins => wins,
        :losses => losses,
        :weapon => @weapon.to_s,
        :weapon_id => @weapon.id,
        :armour => @armour.to_s,
        :armour_id => @armour.id,
        :conditions => conditions,
        :traits => traits,
        :username => account.username
        # history
      }
      
      return response
    else 
      super
    end
  end
  
  def spy(spy_accuracy, my_lvl)

    # TODO: report on injury status
    
    stats = {} # guess stats
    stats[:Strength] = @str + (Roll.roll_percent(spy_accuracy) ? Roll.roll_chaos(1+@x_mod) : 0).to_i
    stats[:Agility] = @agi +( Roll.roll_percent(spy_accuracy) ? Roll.roll_chaos(1+@x_mod) : 0).to_i
    stats[:Endurance] = @end + (Roll.roll_percent(spy_accuracy) ? Roll.roll_chaos(1+@x_mod) : 0).to_i
    stats[:Intelligence] = @int + (Roll.roll_percent(spy_accuracy) ? Roll.roll_chaos(1+@x_mod) : 0).to_i
    
    arm_guess = Roll.roll_percent(spy_accuracy) ? @armour.type_desc : Armour.type_descs[Armour.type_descs.keys.sample]
    wep_guess = Roll.roll_percent(spy_accuracy) ? @weapon.type_desc : Weapon.type_descs[Weapon.type_descs.keys.sample]
    
    diff = 0
    unless my_lvl == false
      diff_guess = Roll.roll_percent(spy_accuracy) ? level - my_lvl + Roll.roll_chaos(1) : level - my_lvl
      case diff_guess
        when -10..-1
          diff = 1
        when 0..1
          diff = 2
        when 2
          diff = 3
        else
          diff = 4
      end
    end
    
    return {
        :id => id,
        :name => name,
        :level => level,
        :best_stat => stats.max_by{|k,v| v}.first,
        :wins => wins,
        :losses => losses,
        :armour => arm_guess,
        :weapon => wep_guess,
        :diff => diff,
        :account_name => account.account_name
    }
  end
  
  def short()
    return {
        :id => id,
        :name => name,
        :level => level
    }
  end

  def mid
    stats = {}
    stats[:Strength] = @str;
    stats[:Agility] = @agi;
    stats[:Endurance] = @end;
    stats[:Intelligence] = @int;
    
    return {
        :id => id,
        :name => name,
        :level => level,
        :best_stat => stats.max_by{|k,v| v}.first,
        :wins => wins,
        :losses => losses,
        :armour => @armour.type_desc,
        :weapon => @weapon.type_desc,
        :account_name => account.account_name,
        :can_train => @can_train,
    }
  end
  
end