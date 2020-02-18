class CharMod < ActiveRecord::Base
  attr_accessible :character_id, :expires, :m_key, :m_type
  
  # UNIQUE MOD KEYS AND MESSAGES
  
  MOD_TYPE_CONDITION = 'condition'
  MOD_TYPE_TRAIT = 'trait'
  
  # CONDITIONS
  
  # leg
  TYPE_CRIP_LEG = 'crip_leg'
  DESCRIPTION_CRIP_LEG = 'Leg Crippled: -10% agi'
  MESSAGE_CRIP_LEG = '%s took an injury to leg in the fight. It will take some time for this injury to recover, your stewards suggest you keep him from the arena while his wounds recover.'
  
  TYPE_PEG_LEG = 'peg_leg'
  DESCRIPTION_PEG_LEG = 'Peg Leg: -5% agi'
  MESSAGE_PEG_LEG = '%s lost a leg in the fight. Your stewards cauterize the wound and place a peg upon his leg.'
  
  # arm
  TYPE_CRIP_ARM = 'crip_arm'
  DESCRIPTION_CRIP_ARM = 'Arm Crippled: -10% str'
  MESSAGE_CRIP_ARM = '%s took an injury to his arm in the fight. It will take some time for this injury to recover, your stewards suggest you keep him from the arena while his wounds recover.'
  
  TYPE_PEG_ARM = 'peg_arm'
  DESCRIPTION_PEG_ARM = 'Peg Arm: -5% str'
  MESSAGE_PEG_ARM = '%s lost an arm in the fight. Your stewards cauterize the wound and replace the arm with an iron gauntlet.'
  
  # torso
  TYPE_CRACKED_RIB = 'cracked_rib'
  DESCRIPTION_CRACKED_RIB = 'Cracked Rib: -5% end'
  MESSAGE_CRACKED_RIB = '%s took a broken rib in the fight. It will take some time for this injury to recover, your stewards suggest you keep him from the arena while his wounds recover.'
  
  # head
  TYPE_HEAD_CRACKED = 'head_cracked'
  DESCRIPTION_HEAD_CRACKED = 'Concussion: -10% agi, -10% end, -20% int'
  MESSAGE_HEAD_CRACKED = '%s took a blow to the head that left him dazed and concussed. It will take some time for this injury to recover, your stewards suggest you keep him from the arena while his wounds recover.'
  
  TYPE_HEAD_LESS = 'head_less'
  DESCRIPTION_HEAD_LESS = 'Peg Head: -50% str, -50% agi, +50% end'
  MESSAGE_HEAD_LESS = '%s head was lost in the fight. Your stewards cauterize the wound and replace the head with an iron helm.'
  
  # drunk, gives better str etc but more chance of injury
  TYPE_DRUNK = 'drunk'
  DESCRIPTION_DRUNK = 'Drunk: +10% str, -20% agi, +5% end'
  MESSAGE_DRUNK = 'Whether from reverly or sorrow, the fight has driven %s into a drunken haze. Your stewards suggest you remove him for the arena while they sober him up.'
  
  TYPE_PARANOID = 'paranoid'
  DESCRIPTION_PARANOID = 'Paranoid: +5% str, +5% agi, +4 chaos'
  MESSAGE_PARANOID = 'The pressure has finally gotten to %s, and his eyes tell of dark thoughts. Your stewards suggest you treat him with caution, or throw him into the arena to work out his aggression..'

  
  # TRAITS
  TYPE_CRAZED = 'crazed'
  DESCRIPTION_CRAZED = 'Crazed from birth: +2 chaos +5% str'
  MESSAGE_CRAZED = 'This man has been raving mad since he burst from the womb. Best to point him at his enemy and hope he gives you a glorious death.'
  
  TYPE_DECREPID = 'decrepid'
  DESCRIPTION_DECREPID = 'Decrepid: -5% str, -5% agi, -5% end'
  MESSAGE_DECREPID = 'This one is weak and decrepid. Good for little else but blood.'
  
  TYPE_FRAGILE = 'fragile'
  DESCRIPTION_FRAGILE = 'Fragile: -5% str, +15% agi, -10% end'
  MESSAGE_FRAGILE = 'This one is weak and fragile.. but not entirely without use.'
  
  TYPE_BRAVE = 'brave'
  DESCRIPTION_BRAVE = 'Brave: +10% str, +15% end'
  MESSAGE_BRAVE = ''
  
  TYPE_FATED = 'fated'
  DESCRIPTION_FATED = 'Fated: +10% str, +10% agi, +10% end'
  MESSAGE_FATED = ''
  
  TYPE_SLIPPERY = 'slippery'
  DESCRIPTION_SLIPPERY = 'Slippery: +20% agi'
  MESSAGE_SLIPPERY = ''
  
  TYPE_REDEEMED = 'redeemed'
  DESCRIPTION_REDEEMED = 'Redeemed: +10% str, +10% agi, +20% end'
  MESSAGE_REDEEMED = ''
  
  TYPE_WELL_DRILLED = 'well_drilled'
  DESCRIPTION_WELL_DRILLED = 'Well Drilled: +4 discipline, +4 judgement'
  MESSAGE_WELL_DRILLED = 'This one has been well instructed. He is ready for the arena.'

  # list of mods and their effects
  @@mod_atts = { 
    # CONDITIONS
    TYPE_CRIP_LEG => {:agi => -0.1, :intimidate => -1},
    TYPE_PEG_LEG => {:agi => -0.05, :intimidate => 1, :discipline => -1},
    TYPE_CRIP_ARM => {:str => -0.1, :intimidate => -1},
    TYPE_PEG_ARM => {:str => -0.05, :intimidate => 1, :discipline => -1},
    TYPE_CRACKED_RIB => {:end => -0.05},
    TYPE_HEAD_CRACKED => {:agi => -0.1, :end => -0.1, :int => -0.2, :judgement => -2},
    #TYPE_HEAD_LESS => {:str => -0.5, :agi => -0.5, :end => 0.5, :judgement => -10},
    TYPE_DRUNK => {:str => 0.1, :agi => -0.2, :end => -0.05, :x => 1, :intimidate => 2, :discipline => -2, :judgement => -2},
    TYPE_PARANOID => {:str => 0.05, :agi => 0.05, :x => 4, :judgement => -2},
    # TRAITS
    TYPE_BRAVE => {:str => 0.1, :end => 0.15, :discipline => 3},
    TYPE_SLIPPERY => {:agi => 0.2, :judgement => 3},
    TYPE_FATED => {:str => 0.1, :agi => 0.1, :end => 0.1},
    TYPE_CRAZED => {:str => 0.05, :x => 2, :intimidate => 3, :judgement => -2, :discipline => -2},
    TYPE_DECREPID => {:str => -0.05, :agi => -0.05, :end => -0.05, :intimidate => -3, :discipline => -3},
    TYPE_FRAGILE => {:str => -0.05, :agi => 0.1, :end => -0.1, :intimidate => -3, :discipline => -2, :judgement => 5},
    TYPE_REDEEMED => {:str => 0.1, :agi => 0.1, :end => 0.2, :intimidate => 3},
    TYPE_WELL_DRILLED => {:discipline => 4, :judgement => 4}
  }
  
  @@mod_desc = {
    # DESCRIPTION
    TYPE_CRIP_LEG => DESCRIPTION_CRIP_LEG,
    TYPE_PEG_LEG => DESCRIPTION_PEG_LEG,
    TYPE_CRIP_ARM => DESCRIPTION_CRIP_ARM,
    TYPE_PEG_ARM => DESCRIPTION_PEG_ARM,
    TYPE_CRACKED_RIB => DESCRIPTION_CRACKED_RIB,
    TYPE_HEAD_CRACKED => DESCRIPTION_HEAD_CRACKED,
    TYPE_HEAD_LESS => DESCRIPTION_HEAD_LESS,
    TYPE_DRUNK => DESCRIPTION_DRUNK,
    TYPE_PARANOID => DESCRIPTION_PARANOID,
    # TRAITS
    TYPE_BRAVE => DESCRIPTION_BRAVE,
    TYPE_SLIPPERY => DESCRIPTION_SLIPPERY,
    TYPE_FATED => DESCRIPTION_FATED,
    TYPE_CRAZED => DESCRIPTION_CRAZED,
    TYPE_DECREPID => DESCRIPTION_DECREPID,
    TYPE_FRAGILE => DESCRIPTION_FRAGILE,
    TYPE_REDEEMED => DESCRIPTION_REDEEMED
  }
  
  @@mod_msg = {
    # CONDITIONS
    TYPE_CRIP_LEG => MESSAGE_CRIP_LEG,
    TYPE_PEG_LEG => MESSAGE_PEG_LEG,
    TYPE_CRIP_ARM => MESSAGE_CRIP_ARM,
    TYPE_PEG_ARM => MESSAGE_PEG_ARM,
    TYPE_CRACKED_RIB => MESSAGE_CRACKED_RIB,
    TYPE_HEAD_CRACKED => MESSAGE_HEAD_CRACKED,
    TYPE_HEAD_LESS => MESSAGE_HEAD_LESS,
    TYPE_DRUNK => MESSAGE_DRUNK,
    TYPE_PARANOID => MESSAGE_PARANOID,
    # TRAITS
    TYPE_BRAVE => MESSAGE_BRAVE,
    TYPE_SLIPPERY => MESSAGE_SLIPPERY,
    TYPE_FATED => MESSAGE_FATED,
    TYPE_CRAZED => MESSAGE_CRAZED,
    TYPE_DECREPID => MESSAGE_DECREPID,
    TYPE_FRAGILE => MESSAGE_FRAGILE,
    TYPE_REDEEMED => MESSAGE_REDEEMED
  }
  
  @@minor_mods = [TYPE_CRIP_LEG, TYPE_CRIP_ARM, TYPE_CRACKED_RIB, TYPE_HEAD_CRACKED, TYPE_DRUNK, TYPE_PARANOID]
  
  @@major_mods = [TYPE_PEG_LEG, TYPE_PEG_ARM]

  @@train_block = [TYPE_CRIP_LEG, TYPE_CRIP_ARM, TYPE_HEAD_CRACKED, TYPE_DRUNK, TYPE_PARANOID]
  
  def description
    return @@mod_desc[m_key]
  end
  
  def message
    return @@mod_msg[m_key]
  end
  
  def attributes
    return @@mod_atts[m_key]
  end
  
  def expires_ms
    return expires.to_i * 1000
  end
  
  # OUTPUT
  
  def as_json(options={})
    response = {
      :description => description,
      :expires_ms => expires_ms
    }
    
    return response
  end
  
  
  # STATIC
  
  def self.create(mod_key, mod_type)
    mod = self.new
    mod.m_key = mod_key
    mod.m_type = mod_type
    return mod
  end
  
  def self.create_perma(mod_key, mod_type, character_id)
    mod = self.new
    mod.m_key = mod_key
    mod.m_type = mod_type
    mod.character_id = character_id
    mod.expires = nil
    return mod
  end
  
  def self.create_timed(mod_key, mod_type, character_id, minutes)
    mod = self.new
    mod.m_key = mod_key
    mod.m_type = mod_type
    mod.character_id = character_id
    mod.expires = nil
    return mod
  end
  
  def self.get_random_mod
    case rand(1..60)
      when 1..10
        return TYPE_CRIP_LEG
      when 11..15
        return TYPE_PEG_LEG
      when 16..25
        return TYPE_CRIP_ARM
      when 26..30
        return TYPE_PEG_ARM
      when 31..45
        return TYPE_CRACKED_RIB
      when 46..52
        return TYPE_HEAD_CRACKED
      # when 52
        # return TYPE_HEAD_LESS
      when 53..60
        return TYPE_DRUNK
    end
  end
  
  def self.get_random_minor_mod
    return @@minor_mods.sample
  end
  
  def self.get_random_major_mod
return @@major_mods.sample
  end
  
  def self.get_random_trait
    case rand(1..100)
      when 1..7
          return TYPE_DECREPID
      when 8..14
          return TYPE_FRAGILE
      when 15..25
          return TYPE_CRAZED
      when 94..96
          return TYPE_BRAVE
      when 97..99
          return TYPE_SLIPPERY
      when 100
        return TYPE_FATED
    else
      return nil
    end
  end
  
  def self.get_message(m_key)
    return @@mod_msg[m_key]
  end

  # def self.can_train(m_key)
  #     return @@train_block.include? m_key == false
  # end
  
end
