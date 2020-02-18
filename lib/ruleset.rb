class Ruleset
  
  attr_accessor :death_chance, :injury_chance, :xp_mod, :cur_mod, :glr_mod
  
  def self.create
    obj = self.new
    obj.death_chance = 3.5
    obj.injury_chance = 3
    obj.xp_mod = 1
    obj.cur_mod = 1
    obj.glr_mod = 1
    return obj
  end
  
  def roll_death
    return Roll.roll_percent(self.death_chance)
  end
  
  def roll_injury(state)
    roll = self.injury_chance * state
    if (state > 1)
      return Roll.roll_percent(roll)
    end
    return false
  end
  
  def roll_major_injury(state)
    if (state > 3)
      return Roll.roll_percent(self.injury_chance * (state / 2))
    end
    return false
  end
  
  def record_wins
    return true
  end
  
  def match_type
    return 'Exhibition Match'
  end
  
end