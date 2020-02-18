class PitRuleset < Ruleset
  
  def self.create
    obj = PitRuleset.new
    obj.injury_chance = 8
    obj.xp_mod = 1.5
    obj.cur_mod = 2
    obj.glr_mod = 0.5
    return obj
  end
  
  def roll_death
    return true
  end
  
  def match_type
    return 'Pit Match'
  end
  
end