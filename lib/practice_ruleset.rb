class PracticeRuleset < Ruleset
  
  attr_accessor :death_chance, :injury_chance, :xp_mod, :cur_mod
  
  def self.create
    obj = PracticeRuleset.new
    obj.injury_chance = 0.5
    obj.xp_mod = 0.6
    obj.cur_mod = 0.0
    obj.glr_mod = 0.0
    return obj
  end
  
  def roll_death
    return false
  end
  
  def roll_injury(state)
    if (state > 0)
      return Roll.roll_percent(self.injury_chance * state)
    end
    return false
  end
  
  def roll_major_injury(state)
    return false
  end
  
  def record_wins
    return false
  end
  
  def match_type
    return 'Practice Match'
  end
  
end