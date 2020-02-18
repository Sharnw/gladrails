class ReportBuilder
  include Singleton
  attr_accessor :title, :messages, :owners, :owned_messages
  
  def initialize
    @common_messages = Array.new
    @owned_messages = Hash.new
    @owners = Hash.new
  end
  
  def log(message)
     @common_messages.push(message)
  end
  
  def log_owned(message, owner_id)
      @owned_messages[owner_id].push(message)
  end
  
  def set_owner(owner_acc)
    @owners[owner_acc.id] = owner_acc
    @owned_messages[owner_acc.id] = Array.new
  end
  
  def title=(title)
    @title = title
  end
  
  def output_common
    html = ''
    
    @common_messages.each do |m|
      html += m.to_s
      html += '<br>'
    end
    
    return html
  end
  
  def output_owned(owner_id)
    html = output_common + '<br>'
    
    @owned_messages[owner_id].each do |m|
      html += m.to_s
      html += '<br>'
    end
    
    return html
  end
  
  def flush
    html = output_common
    clear
    
    return html
  end
  
  def flush_owned(owner_id)
    html = output_owned(owner_id)
    clear
    
    return html
  end
  
  def send_reports
    
  end
  
  def send_owned_report(owner_id, read, hist_hash, char_id, noti_type)
    html = output_owned(owner_id)
    if (read)
      Notification_Manager.log_read(@title, html, owner_id, char_id, noti_type, hist_hash)
    else
      Notification_Manager.log_new(@title, html, owner_id, char_id, noti_type, hist_hash)
    end
    
    return html
  end
  
  def clear
    @common_messages = Array.new
    @owned_messages = Hash.new
    @owners = Hash.new
    @title = ''
  end

end