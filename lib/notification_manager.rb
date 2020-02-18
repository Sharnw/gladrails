class Notification_Manager
  
  MESSAGE_DAILY_BONUS = 'You gained a daily bonus of %s coinage.'
  
  MESSAGE_WIN_PURSE = 'You won a purse of %s!'
  MESSAGE_WIN_EXP = '%s gained %s XP!'
  MESSAGE_LEVEL_UP = '%s leveled up!'
  MESSAGE_WIN_GLORY = '%s fought well. Your ludus gains %s glory from his performance.'
  
  MESSAGE_DEATH_GLORY = '%s died a glorious death. You ludus gains %s glory from his sacrifice.'
  MESSAGE_DEATH = '%s wounds were to severe for him to recover. Your stewards did all they could, but he died a slow and painful death all the same.'
  
  MESSAGE_GAUNTLET_WIN = 'Despite the brutal odds %s has made it through alive. Your ludus cheers his name on his return.'
  MESSAGE_GAUNTLET_LOSS = '%s fought tooth and nail but it was not enough. His mangled corpse is dragged from the ring and fed to the dogs.'
  
  TYPE_REPORT = 'report'
  TYPE_BOUT = 'bout'
  TYPE_INJURY = 'injury'
  TYPE_REWARD = 'reward'
  
  def self.log_new(subject, text, account_id, char_id, type, link_hash)
    notification = Notification.new
    notification.subject = subject
    notification.text = text
    notification.account_id = account_id
    notification.character_id = char_id
    notification.noti_type = type
    notification.link_hash = link_hash
    notification.read = false
    notification.save
  end
  
  def self.log_read(subject, text, account_id, char_id, type, link_hash)
    notification = Notification.new
    notification.subject = subject
    notification.text = text
    notification.account_id = account_id
    notification.character_id = char_id
    notification.noti_type = type
    notification.link_hash = link_hash
    notification.read = true
    notification.save
  end
  
  def self.get_recent(account_id)
    notis = Notification.where(:account_id => account_id).order('created_at DESC').limit(20)
    notis.each do |n|
      if n.read != true
        n.read = true
        n.save
      end
    end
    
    return notis
  end
  
  # GET RECENT FOR ACCOUNT
  def self.get_recent_by_type(account_id, type, hide_text, num_records)
    
    if hide_text
      notis = Notification.find(:all, :conditions => [ "account_id = ? AND noti_type = ?", account_id, type], :select => 'id, link_hash, subject, noti_type, created_at', :order => 'created_at DESC', :limit => num_records)
    else
      notis = Notification.where(:account_id => account_id, :noti_type => type).order('created_at DESC').limit(num_records)
    end
    
    return notis
  end
  
  def self.get_recent_by_char(account_id, char_id)
    return Notification.where(:account_id => account_id, :character_id => char_id).order('created_at DESC').limit(5)
  end
  
  def self.get_recent_unread(account_id)
    return Notification.where(:account_id => account_id).order('created_at DESC').limit(10)
  end
  
  # GET RECENT BOUTS
  def self.get_all_recent_bouts(num_bouts)
     return Notification.find(:all, :conditions => [ "noti_type = ?", TYPE_BOUT], :select => 'id, link_hash, subject, created_at', :order => 'created_at DESC', :limit => num_bouts)
  end
  
  def self.get_all_recent_bouts_cached(num_bouts)
    #Rails.cache.fetch 'get_all_recent_bouts', :expires_in => 30.minutes do
      get_all_recent_bouts(num_bouts)
    #end
  end
  
  def self.get_my_recent_bouts(account_id, num_bouts)
     return Notification.find(:all, :conditions => [ "account_id = ? AND noti_type = ?", account_id, TYPE_BOUT], :select => 'id, link_hash, subject, created_at', :order => 'created_at DESC', :limit => num_bouts)
  end
  
  def self.get_my_recent_bouts_cached(account_id, num_bouts)
    #Rails.cache.fetch 'get_my_recent_bouts', :expires_in => 30.minutes do
      get_my_recent_bouts(account_id, num_bouts)
    #end
  end
  
  def self.count_unread(account_id)
    return Notification.where(:account_id => account_id, :read => false).count
  end
  
  def self.mark_read(noti_id)
    notification = Notification.new(noti_id)
    notification.read = true
    notification.save
  end
  
  def self.get_unread(account_id)
    unread_notes = Notification.where(:account_id => account_id, :read => nil).order('created_at DESC').limit(10)
    unread_notes.each do |n|
      if n.read != true
        n.read = true
        n.save
      end
    end
    return unread_notes
  end

end