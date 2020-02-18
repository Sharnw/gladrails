class Armour < ActiveRecord::Base
  attr_accessible :a_type, :name, :description
  
  TYPE_HEAVY = 'Heavy'
  TYPE_LIGHT = 'Light'
  DESC_HEAVY = 'Heavy Armour'
  DESC_LIGHT = 'Light Armour'
  
  @@types = [TYPE_HEAVY, TYPE_LIGHT]
  @@descs = [DESC_HEAVY, DESC_LIGHT]
  
  @@type_descs = {TYPE_HEAVY => {'type' => TYPE_HEAVY, 'desc' => DESC_HEAVY}, TYPE_LIGHT => {'type' => TYPE_LIGHT, 'desc' => DESC_LIGHT}}
  
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
    return @@type_descs[a_type]['desc']
  end
  
  def type_desc
    return @@type_descs[a_type]
  end
  
  def description
    return name + ' (' + a_type + ')' 
  end
  
  def to_s
    return name + ' (' + a_type + ')'
  end
  
  def is_heavy
    return a_type == TYPE_HEAVY
  end
  
  def is_light
    return a_type == TYPE_LIGHT
  end
  
  def as_json options=nil
    options ||= {}
    options[:methods] = ((options[:methods] || []) + [:description])
    super options
  end
  
    
end
