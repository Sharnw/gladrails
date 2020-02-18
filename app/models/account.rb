require 'digest/sha1'
require 'obscenity/active_model'

class Account < ActiveRecord::Base
  attr_protected :salt, :password
  
  attr_accessible :currency, :email, :glory, :hash_key, :last_login, :last_recruited, :last_daily, :account_name, :password, :salt, :username, :verified
  
  validates :account_name, :uniqueness => true
  validates :username, :uniqueness => true, :obscenity => true
  validates :email, :uniqueness => true
  
  validates_length_of :username, :within => 3..40
  validates_presence_of :account_name, :username, :email, :salt, :password
  
  validates :password, :confirmation => { :on => :create }
  validates :password_confirmation, :presence => { :on => :create }
  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validates :email, :confirmation => { :on => :create }
  validates :email_confirmation, :presence => { :on => :create }
  
  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.get_hashed_password(pass)
    hash_pass = Hash.new
    hash_pass[:salt] = Account.random_string(10)
    hash_pass[:password] = Account.encrypt(pass, hash_pass[:salt])
    return hash_pass
  end
  
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end
  
  def self.create(data)
    account = Account.new
    account.account_name = data[:account_name]
    account.username = data[:username]
    hash_pass = get_hashed_password(data[:password])
    account.salt = hash_pass[:salt]
    account.password = hash_pass[:password]
    account.password_confirmation = Account.encrypt(data[:password_confirmation], hash_pass[:salt])
    account.email = data[:email]
    account.email_confirmation = data[:email_confirmation]
    account.currency = 100
    account.glory = 0
    account.verified = false
    account.last_daily = Time.now
    account.hash_key = Account.encrypt(Account.random_string(30), hash_pass[:salt])
    return account
  end
  
  def self.authenticate(login, pass)
    u=find(:first, :conditions=>["username = ?", login])
    return nil if u.nil?
    return u.id if Account.encrypt(pass, u.salt)==u.password
    nil
  end
  
  def spy_accuracy
    # TODO: for each spy add 5%
    return 50
  end

end