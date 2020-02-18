class CharWrapper
  
  include ModsManager
  
  attr_reader :weapon, :armour, :str, :agi, :end, :int, :x, :intimidate, :discipline, :judgement, :hp, :dmg_taken, :state
  
  attr_accessor :generated, :intimidated, :prepared
  
  def initialize(char)
    if ((char.instance_of? Character) == false)
      raise "Invalid base character"
    end
    @base_char = char
    @weapon = Weapon.find(@base_char.weapon_id)
    @armour = Armour.find(@base_char.armour_id)
    
    # hp
    @base_hp = 20 + (@base_char.level * 5) + (((@base_char.base_end - 10) * @base_char.level) / 2.5).round
    @dmg_taken = 0
    
    @intimidate = 0
    @discipline = 0
    @judgement = 0
    
    # load modifiers
    load_mods
    apply_mods
    
    # calculated values used in attack / dodge rolls
    @str_mod = (@str - 10) / 2
    @agi_mod = (@agi / 2).floor
    @int_mod = ((@int - 10) / 2).floor
    @x_mod = (@x / 2).floor

    
    @crit_range = 5 + @agi_mod + (@int_mod / 2)
    @str_dmg = (@str_mod + ((@str_mod * @base_char.level) * 0.05)).ceil

    @dodge_percent = @agi_mod + @x_mod + (@int_mod / 2)
    @armour.is_light ? @dodge_percent += 5 : @dodge_percent -= 3
    @deflect_percent = (@str_mod / 2).floor  + (@int_mod / 2)
    
    if @armour.is_heavy
      # add 7% bonus for heavy armour
      @deflect_percent += 7
    else
      # add 5% bonus for light armour, -2% for heavy armour
      @dodge_percent += 5
      @deflect_percent -= 2
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
  
  def reset_dmg
    @dmg_taken = 0
  end
  
  # factory method
  def self.load_char(char_id)
    return CharWrapper.new(Character.find(char_id))
  end
  
  def self.wrap_char(char)
    return CharWrapper.new(char)
  end
  
  def account
    return Account.find(@base_char.account_id)
  end

  def account_id=(id)
    @base_char.account_id = id
  end
  
  def activity=(activity)
    @base_char.activity = activity
  end
  
  
  # attribute shortcuts
  
  def id
    return @base_char.id
  end
  
  def level
    return @base_char.level
  end
  
  def name
    return @base_char.name
  end
  
  def account_id
    return @base_char.account_id
  end
  
  def set_dead
    @base_char.alive = false
  end
  
  def add_kill
    @base_char.increment(:kills, 1)
  end
  
  def add_glory
    @base_char.increment(:glory, 1)
  end
  
  # glory gain modifier
  def glr_mod
    case level
      when 1..5
        return 0.9
      when 6..10
        return 1.5
      else
        return 2.5
    end
  end
  
  def roll_weapon_dmg
    # base dmg + 5% per lvl + strength modifier
    dmg = (@weapon.roll_dmg * (1 + (@base_char.level * 0.05))) + @str_dmg
    
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
  
  def chaos_mod
    return @x_mod
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
  
  def take_dmg(amount)
    @dmg_taken += amount
    update_state
  end
  
  # STATE CHECKS
  
  def is_ok
    return @dmg_taken < @hp
  end
  
  def is_alive
    return @base_char.alive
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
  
  # XP / REWARDS
  
  def add_exp(amount)
    @base_char.increment(:exp, amount)
    check_level
  end
  
  def add_glory(amount)
    account.increment(amount)
    @base_char.increment(:glory, amount)
    save
  end
  
  def check_level
    if (@base_char.exp >= @base_char.desired_xp)
      message = Message.new(Notification_Manager::MESSAGE_LEVEL_UP % @base_char.name, Message::TYPE_REWARD)
      ReportBuilder.instance.log_owned(message, @base_char.account_id)
      Notification_Manager.log_new(message.to_s,'', @base_char.account_id, @base_char.id, NotificationManager::TYPE_REWARD, nil)
      @base_char.level_up
    end
  end
  
  def add_win
    @base_char.increment(:wins, 1)
  end
  
  def add_loss
    @base_char.increment(:losses, 1)
  end
  
  def reset
    @dmg_taken = 0
    @state = 1
  end
  
  def save
    @base_char.save
  end

  # recovery time methods
  def set_recovery
    # 3 minutes + 30 seconds per level
    secs = 180 + (30 * @base_char.level)
    # overwrite for testing
    secs = 90
    @base_char.recovery_time = Time.now.utc + secs.seconds
  end
  
  def is_ready
    return recovery_sec == 0
  end
  
  def recovery_sec
    if @base_char.recovery_time
      recovery_sec = @base_char.recovery_time - Time.now
      if (recovery_sec > 0)
        return recovery_sec
      end
    end
    return 0
  end
  
  def recovery_time_ms
    return @base_char.recovery_time.to_i * 1000
  end
  
  def recovery_time
    sec = recovery_sec
    if (sec > 0)
      return Time.at(recovery_sec).utc.strftime("%H:%M:%S")
    end
    return 0
  end

  # DESCRIPTION FIELDS
  def status
    return recovery_sec == 0 ? 'Ready' : 'Recovering'
  end
  
  def level_xp
    return "#{@base_char.level} (#{@base_char.exp})"
  end
  
  def history
 
  end
  
  def inspect
    @output = ''
    @output += @base_char.name + " (#{@base_char.level})" + " - "
    @output += @str.to_s + ' str / ' + @agi.to_s + ' agi / ' + @end.to_s + ' end / ' + @hp.to_s + " hp "
    @output += @weapon.w_type + " "
    @output += @armour.a_type + " "
    # show crit chance and dmg
    get_mods.each {|message| @output += message + " : "}
    return @output
  end
  
  def char_summary
    output = "\n" + name + "\n"
    output << 'Stats: ' + @str.to_s + ' / ' + @agi.to_s + ' / ' + @end.to_s + ' (' + @hp.to_s + ") \n"
    output << 'Level: ' + @base_char.level.to_s + " \n"
    output << 'Wins:' + @base_char.wins.to_s + "\n"
    output << 'Losses:' + @base_char.losses.to_s + " \n"
    output << 'Mods: ' + condition_summary + "\n"
    output << 'Traits: ' + trait_summary + "\n"
    output << 'Alive: ' + is_alive.to_s + "\n"
    return output
  end
  
  
  
  # OUTPUT AS JSON IN MUSTACHE.JS FRIENDLY FORMAT
  def as_json(options={})

    response = {
      :id => @base_char.id,
      :name => name,
      :status => status,
      :is_ready => is_ready,
      :recovery_time_ms => recovery_time_ms,
      :test_time => @base_char.recovery_time,
      :level => @base_char.level,
      :exp => @base_char.exp,
      :att_points => @base_char.att_points,
      :base_str => @base_char.base_str,
      :base_agi => @base_char.base_agi,
      :base_end => @base_char.base_end,
      :base_int => @base_char.base_int,
      :base_x => @base_char.base_x,
      :str => @str,
      :agi => @agi,
      :end => @end,
      :int => @int,
      :x => @x,
      :intimidate => @intimidate,
      :discipline => @discipline,
      :judgement => @judgement,
      :wins => @base_char.wins,
      :losses => @base_char.losses,
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
  end
  
end