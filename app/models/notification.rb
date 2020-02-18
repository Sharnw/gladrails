class Notification < ActiveRecord::Base
  attr_accessible :account_id, :character_id, :link_hash, :noti_type, :read, :subject, :text
  
  # add timestamp in seconds to json output
  def as_json(options = { })
    h = super(options)
    h[:time_ms] = created_at.to_i * 1000
    h
  end
  
end
