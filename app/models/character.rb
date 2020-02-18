require 'obscenity/active_model'

class Character < ActiveRecord::Base
  
  include CharManager
  include ModsManager
    
  attr_accessible :account_id, :alive, :armour_id, :att_points, :base_agi, :base_end, :base_str, :base_int, :base_x, :exp, :glory, :kills, :activity, :activity_val, :last_daily, :level, :wins, :losses, :name, :recovery_time, :weapon_id, :tourney_id

  validates_presence_of :account_id
  validates :name, obscenity: true
  
  # FACTORY METHODS
  def self.load(char_id, calculate = false)
    char = Character.find(char_id)
    if calculate
      char.calculate
    end
    
    return char
  end
  
  def self.create(options)
    char = Character.new
    options.each do |key, val|
      char[key] = val
    end
    
    return char
  end

end
