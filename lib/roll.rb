class Roll
  
  def self.roll_range(min, max)
    return min + rand((max - min) + 1)
  end
  
  def self.roll_percent(percent)
    percent = percent * 100
    if (self.roll_range(1, 10000) <= percent)
      return true
    end
    return false
  end
  
  def self.roll_chaos(amount)
    case rand(0..1)
      when 0
        return -amount
      when 1
        return amount
    end
      
  end
  
end