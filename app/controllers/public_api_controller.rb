require 'digest/md5'

class PublicApiController < ApplicationController
  
  # constants
  STATUS_ERROR = 'alert'
  STATUS_SUCCESS = 'success'
  
  def do_attempt_login
    errors = ''
    status = ''
    token = ''
    username = ''
    
    if session.has_key?(:login_attempts) == false and 1 == 2
      session[:login_attempts] = 0
      session[:last_login_attempt] = Time.now
    else
      data = params[:account]
      auth = Account.authenticate(data[:username], data[:password])
      if (auth.to_i > 0)
        account = Account.where(:id => auth, :verified => true).first
        if account.instance_of? Account
          status = STATUS_SUCCESS
          session[:account_id] = auth
          token = Digest::MD5.hexdigest(account.salt)
          username = account.username
          session[:token] = token
          
          account.last_login = Time.now
          
          # last daily more than 24 hours ago? if so give reward and log message
          if account.last_daily.nil? == false and account.last_daily.to_i < (Time.new - 24.hour).to_i
            win_cur = 50 + (10 * rand(1..3)).floor
            account.increment(:currency, win_cur)
            Notification_Manager.log_new(Notification_Manager::MESSAGE_DAILY_BONUS % win_cur, '', account.id, nil, 'ac', nil)
            account.last_daily = Time.now
          end
          
          account.save
        else
          
          status = STATUS_ERROR
          errors = ['Your account has not been verified. Please check your email for the verification code.']
        end
      else
        session[:login_attempts] += 1
        session[:last_login_attempt] = Time.now
        status = STATUS_ERROR
      end
      
      render :json => {
        :status => status,
        :errors => errors,
        :token => token,
        :username => username
      }
    end
  end
  
  def do_create_account
    errors = ''
    
    account = Account.create(params[:account])
    pass_valid = (params[:password] == params[:password_confirmation])
    if account.valid? and pass_valid
      account.verified = true
      account.save
      status = STATUS_SUCCESS
      session[:account_id] = account.id
      
      token = Digest::MD5.hexdigest(account.salt)
      session[:token] = token
    else
      status = STATUS_ERROR
      errors = account.errors
      if pass_valid == false
        errors.push('Passwords do not match.')
      end
    end

    render :json => {
      :status => status,
      :errors => errors,
      :token => token
    }
  end
  
  def do_verify_code
    @account = Account.find_by_hash_key(params[:code])
    if @account.instance_of? Account
      status = STATUS_SUCCESS
      if @account.verified == false
        @account.password_confirmation = @account.password
        @account.email_confirmation = @account.email
        @account.verified = true
        @account.save
        message = 'Your confirmation code was successfully verified. You may now log in.'
      else
        message = 'Your account has already been verified. Please log in to continue.'
      end
    else
      status = STATUS_ERROR
      message = 'Your confirmation code could not be verified. Please check the link in your email and try again.'
    end
    
    render :json => {
      :status => status,
      :message => message
    }
  end
  
  def do_logout
    reset_session
    
    render :json => {
      :status => STATUS_SUCCESS,
      :errors => ''
    }
  end

end
