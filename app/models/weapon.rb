class Weapon < ActiveRecord::Base

  attr_accessible :crit, :max_dmg, :min_dmg, :name, :w_type
  
  TYPE_SLASH = 'Blade'
  TYPE_BLUDGE = 'Bludge'
  TYPE_STAB = 'Stab'
  
  DESC_SLASH = 'Slashing Weapon'
  DESC_BLUDGE = 'Bludgeoning Weapon'
  DESC_STAB = 'Stabbing Weapon'
  
  @@types = [TYPE_SLASH, TYPE_BLUDGE, TYPE_STAB]
  @@descs = [DESC_SLASH, DESC_BLUDGE, TYPE_STAB]
  
  @@type_descs = {TYPE_SLASH => {'type' => TYPE_SLASH, 'desc' => DESC_SLASH}, TYPE_BLUDGE => {'type' => TYPE_BLUDGE, 'desc' => DESC_BLUDGE}, TYPE_STAB => {'type' => TYPE_STAB, 'desc' => DESC_STAB}}
  
  def self.types
    return @@types
  end
  
  def self.descs
    return @@descs
  end
  
  def self.type_descs
    return @@type_descs
  end
  
  def desc
    return @@type_descs[w_type]['desc']
  end
  
  def type_desc
    return @@type_descs[w_type]
  end
  
  def roll_dmg
    return Roll.roll_range(min_dmg.to_i, max_dmg.to_i)
  end
  
  def description
    return to_s
    #return name + ', ' + min_dmg.to_s + '-' + max_dmg.to_s + ' (x' + crit.to_s + ')' 
  end
  
  def to_s
    return name + ' (' + w_type + ')'
  end
   
  def is_slash
    return w_type == TYPE_SLASH
  end
  
  def is_bludge
    return w_type == TYPE_BLUDGE
  end
  
  def is_stab
    return w_type == TYPE_STAB
  end
  
  def dodge_range
    case w_type
    when TYPE_SLASH
      return 100
    when TYPE_BLUDGE
      return 90
    when TYPE_STAB
      return 115
    end
  end
  
  def deflect_range
    case w_type
    when TYPE_SLASH
      return 100
    when TYPE_BLUDGE
      return 115
    when TYPE_STAB
      return 90
    end
  end
  
  def fail_range
    if (is_bludge)
      return 3
    elsif (is_stab)
      return 2
    else
      return 1
    end
  end
  
  def as_json options=nil
    options ||= {}
    options[:methods] = ((options[:methods] || []) + [:description])
    super options
  end
  
end
