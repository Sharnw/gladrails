class ShowRuleset < Ruleset
  
  def self.create
    obj = self.new
    obj.injury_chance = 2
    obj.death_chance = 2
    obj.xp_mod = 0.8
    obj.cur_mod = 1
    obj.glr_mod = 0.5
    return obj
  end
  
  def roll_death
    return Roll.roll_percent(self.death_chance)
  end
  
  def match_type
    return 'Show Match'
  end
  
end