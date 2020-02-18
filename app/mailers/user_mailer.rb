class UserMailer < ActionMailer::Base
  default :from => 'GladRails'
 
  def welcome_email(account)
    @account = account

    mail(:to => account.email, :subject => 'Please confirm your registration.') do |format|
      format.text do
        render :text => "<!DOCTYPE html>
                          <html>
                            <head>
                              <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" />
                            </head>
                            <body>
                              <h1>Welcome to GladRails, #{@account.username}!</h1>
                              <p>
                                You have successfully signed up to gladrailsv2.heroku.com, and your username is: #{@account.username}.<br/>
                                To login to the site, just follow this link: http://<link-removed>/verify/#{@account.hash_key}.
                              </p>
                              <p>Thanks for joining and have a great day!</p>
                            </body>
                          </html>"
      end
    end
  end
  
  
end
