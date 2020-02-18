class Message
  
  attr_accessor :text, :css_class
  
  TYPE_ATTACK = 'msg_attack'
  TYPE_ATTACK_SPECIAL = 'msg_attack_special'
  TYPE_DEFENSE = 'msg_defense'
  TYPE_REWARD = 'msg_reward'
  TYPE_FAINT = 'msg_faint'
  TYPE_INJURY = 'msg_injury'
  TYPE_DEATH = 'msg_death'
  TYPE_MISC = 'msg_misc'
  TYPE_DIE = 'msg_die'
  
  TYPE_LUDUS = 'msg_ludus_action'
  
  MESSAGE_CHALLENGE_ACCEPTED = '<p>%s challenged %s, he had no choice but to accept.</p>'
  MESSAGE_CHALLENGE_MADE = '<p>%s challenged %s, he had no choice but to accept.</p>'
  
  MESSAGE_NEW_RECRUITS = 'Your master of recruitment has scoured the city for fresh recruits. He lines up the latest batch for inspection.'
  MESSAGE_SHOW_RECRUITS = 'Your master of recruitment lines up the latest batch of recruits for inspection.'
  
  MESSAGE_BUY_RECRUIT = 'You have bought this recruit. He has been transported to your ludus.'
  MESSAGE_REJECT_RECRUIT = 'You have rejected this recruit. He will be returned to his owner.'
  MESSAGE_FAIL_BUY_RECRUIT = 'You do not have enough coinage to purchase this recruit.'
  
  def initialize(text, css_class)
    @text = text
    @css_class = css_class
  end
  
  def to_s
    return "<span class=\"#{@css_class}\">#{@text}</span>"
  end
  
  def inspect
    to_s
  end
  
  # OUTPUT AS JSON IN MUSTACHE.JS FRIENDLY FORMAT
  def as_json(options={})
    return to_s
  end
end