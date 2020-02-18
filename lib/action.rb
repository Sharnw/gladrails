class Action
  
  # action type constants
  TYPE_DMG_OTHER = 'dmg_other'
  TYPE_DMG_SELF = 'dmg_self'
  TYPE_MISS_DODGE = 'dodge'
  TYPE_MISS_DEFLECT = 'block'
  TYPE_FAINT = 'faint'
  TYPE_DIE = 'die'
  TYPE_SKIP = 'skip'
  TYPE_OVERPOWER = 'kick'
  TYPE_TRIP = 'trip'
  TYPE_INTIMIDATED = 'intimidated'
  TYPE_WAIT = 'wait'
  TYPE_MISS_COUNTERED = 'countered'
  TYPE_COUNTER = 'counter'
  
  # action message constants
  MESSAGE_MISS_DODGE = 'Missed (dodge)'
  MESSAGE_MISS_DEFLECT = 'Missed (deflect)'
  MESSAGE_MISS_COUNTERED = 'Missed (countered)'
  MESSAGE_HIT = 'Hit for %d dmg'
  MESSAGE_CRIT = 'Landed a crushing blow for %d dmg'
  MESSAGE_CRIT_FAIL = 'Landed a crushing blow.. on himself for %d dmg'
  MESSAGE_LUCKY_CRIT = 'Landed a lucky blow for %d dmg'
  MESSAGE_FAINT = 'lost consciousness from his wounds.'
  MESSAGE_DIE = 'died from his wounds.'
  MESSAGE_OVERPOWER = 'overpowered %s, causing him to lose his footing.'
  MESSAGE_TRIP = 'tripped %s, causing him to lose his balance.'
  MESSAGE_SKIPPED = 'struggles back to his feet.'
  MESSAGE_INTIMIDATED = 'trembles where he stands, unwilling to press the attack.'
  MESSAGE_COUNTER = 'anticipated %s\'s attack, and counters with deadly precision.'
  
  attr_reader :char_self, :type, :amount, :message
  
  def initialize(char_self, action_type, amount, message)
    @char_self = char_self
    @type = action_type
    @amount = amount
    @message = message
  end
  
  def inspect
    return @char_self.name + ': ' + @message.to_s
  end
  
  def to_s
    return @char_self.name + ': ' + @message.to_s
  end
  
  def to_xml(options={})
    return to_hash.to_xml
  end
  
  def to_hash
    h = Hash.new
    h[:type] = @type
    h[:name] = @char_self.name
    h[:message] = @message.to_s
    if @char_self.id.nil?
      h[:owner] = 0
    else
      h[:owner] = @char_self.id.to_s
    end
    
    return h
  end
  
end