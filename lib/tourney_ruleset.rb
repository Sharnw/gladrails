class TourneyRuleset < Ruleset
  
  def self.create
    obj = self.new
    obj.injury_chance = 1
    obj.death_chance = 0.5
    obj.xp_mod = 0.5
    obj.cur_mod = 1.5
    obj.glr_mod = 1
    return obj
  end
  
  def roll_death
    return Roll.roll_percent(self.death_chance)
  end
  
  def match_type
    return 'Tourney Match'
  end
  
end