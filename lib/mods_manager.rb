module ModsManager
  
  attr_reader :active_conditions, :active_traits
  
  def load_mods
    @active_conditions = {}
    @active_traits = {}
    
    # conditions
    CharMod.where("character_id = ? AND m_type = 'condition' AND (expires IS NULL OR expires >= ?)", id, Time.now.utc.to_s).each do |mod| 
        @active_conditions[mod.m_key] = mod
    end
    
    # traits
    CharMod.where("character_id = ? AND m_type = 'trait' AND (expires IS NULL OR expires >= ?)", id, Time.now.utc.to_s).each {
      |mod| @active_traits[mod.m_key] = mod
    }
  end
  
  def apply_mods
    # initialize mod stat values
    @str = base_str
    @agi = base_agi
    @end = base_end
    @int = base_int
    @x = base_x
    # calc hp
    @hp = @base_hp
    
    # determine total mod attributes
    total_attributes = {:str => 0, :agi => 0, :agi => 0, :end => 0, :int => 0, :x => 0, :intimidate => 0, :discipline => 0, :judgement => 0}
    @active_conditions.each do |key, mod|
      attributes = mod.attributes
      unless attributes.nil? 
        mod.attributes.each do |att, val|
          total_attributes[att] += val
        end
      end
      # unless mod.can_train
      #   @can_train = false
      # end
    end
    
    @active_traits.each do |key, mod|
      attributes = mod.attributes
      unless attributes.nil?
        mod.attributes.each do |att, val|
          total_attributes[att] += val
        end
      end
    end
    
    # apply total mod attributes
    total_attributes.each do |att, val|
      case att
      when :str
          @str += @str * val
      when :agi
          @agi += @agi * val
      when :end
          @end += @end * val
      when :int
          @int += @int * val
      when :x
          @x += val
        when :intimidate
          @intimidate += val
        when :discipline
          @discipline += val
        when :judgement
          @judgement += val
      end
    end

    # round new attributes
    @str = @str.round
    @agi = @agi.round
    @end = @end.round
    @int = @int.round
    
    # re-calc hp
    @hp = 20 + (level * 5) + (((@end - 10) * level) / 2.5).round
    @hp.round
  end

  # SAVE NEW MODS TO CHAR
  
  def self.add_trait(trait_type, char_id)
    if (trait_type.nil? == false and CharMod.where("character_id = ? AND m_key = ?", char_id, trait_type).first.nil?)
        mod = CharMod.create(trait_type, CharMod::MOD_TYPE_TRAIT)
        mod.character_id = char_id
        mod.expires = nil
        mod.save
    end
  end
  
  def apply_trait(trait_type)
    if (trait_type.nil? == false)
      if (@active_traits.has_key?(trait_type) == false)        
        mod = CharMod.create(trait_type, CharMod::MOD_TYPE_TRAIT)
        mod.character_id = id
        mod.expires = nil
        mod.save
        @active_traits[trait_type] = mod
      else
        mod = @active_traits[trait_type]
        mod.character_id = id
        mod.expires = nil
        mod.save
      end    
    end
  end
  
  def apply_perma_mod(mod_type)
    if (mod_type.nil? == false)
      if (@active_conditions.has_key?(mod_type) == false)        
        mod = CharMod.create(mod_type, CharMod::MOD_TYPE_CONDITION)
        mod.character_id = id
        mod.expires = nil
        mod.save
        @active_conditions[mod_type] = mod
      else
        mod = @active_conditions[mod_type]
        mod.character_id = id
        mod.expires = nil
        mod.save
      end    
      
      # remove any cripples on that limb
      case mod_type
        when CharMod::TYPE_PEG_LEG
          CharMod.delete_all(["m_key = ? AND m_type = ? AND character_id = ?", CharMod::TYPE_CRIP_LEG, CharMod::MOD_TYPE_CONDITION, id])
        when CharMod::TYPE_PEG_ARM
          CharMod.delete_all(["m_key = ? AND m_type = ? AND character_id = ?", CharMod::TYPE_CRIP_ARM, CharMod::MOD_TYPE_CONDITION, id])
        # when CharMod::TYPE_HEAD_LESS
          # CharMod.delete_all(["m_key = ? AND m_type = ? AND character_id = ?", CharMod::TYPE_HEAD_CRACKED, CharMod::MOD_TYPE_CONDITION, @base_char.id])
      end

      return true
    end
  end
  
  def apply_timed_mod(mod_type, minutes)
    if (mod_type.nil? == false)

      if (@active_conditions.has_key?(mod_type) == false)    
        mod = CharMod.create(mod_type, CharMod::MOD_TYPE_CONDITION)
        mod.character_id = id
        mod.expires = Time.now.utc + minutes.minutes
        @active_conditions[mod_type] = mod
      else
        mod = CharMod.where(:character_id => id, :m_key => mod_type, :m_type => CharMod::MOD_TYPE_CONDITION).first
        if mod.expires.to_i > Time.now.to_i
          mod.expires += minutes.minutes
        else
          mod.expires = Time.now.utc + minutes.minutes
        end
      end
      
      mod.save  
      return true
    end
  end
  
  def store_mod(mod_key)
    unless mod_key.nil? or @active_conditions[mod_key].nil? == false
      mod = CharMod.create(mod_key, CharMod::MOD_TYPE_CONDITION)
      @active_conditions[mod_key] = mod
    end
  end
  
  def store_trait(trait_key)
    unless trait_key.nil? or @active_traits[trait_key].nil? == false
      mod = CharMod.create(trait_key, CharMod::MOD_TYPE_TRAIT)
      @active_traits[trait_key] = mod
    end
  end  

  def get_conditions
    @condition_messages = []
    @active_conditions.each do |key, mod| 
      desc = mod.description
      if desc.nil? == false
        @condition_messages.push(desc)
      end
    end
    return @condition_messages
  end
  
  def get_traits
    @trait_messages = []
    @active_traits.each{|key, mod| 
      desc = mod.description
      if desc.nil? == false
        @trait_messages.push(desc)
      end
    }
    return @trait_messages
  end
  
  # state checks according to mods
  def is_leg_weak
    if (@active_conditions.has_key?(CharMod::TYPE_CRIP_LEG) or @active_conditions.has_key?(CharMod::TYPE_PEG_LEG))
      return true
    end
    return false
  end
  
  def is_arm_weak
    if (@active_conditions.has_key?(CharMod::TYPE_CRIP_ARM) or @active_conditions.has_key?(CharMod::TYPE_PEG_ARM))
      return true
    end
    return false
  end
  
  # def is_head_weak
    # return @active_conditions.has_key?(CharMod::TYPE_HEAD_CRACKED)
  # end
  
  # def is_head_less
    # return @active_conditions.has_key?(CharMod::TYPE_HEAD_LESS)
  # end
  
  def is_drunk
    return @active_conditions.has_key?(CharMod::TYPE_DRUNK)
  end
  
  # summary info outputs
  
  def condition_summary
    return get_conditions.join(', ')
  end
  
  def trait_summary
    return get_traits.join(', ')
  end
  
  def conditions
    return @active_conditions
  end
  
  def traits
    return @active_traits
  end

end