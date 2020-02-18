namespace :app do

  desc "Registers chars for current tourneys and simulates outcome."
  task :tourney_test => :environment do
    
    start_time = Time.now

    ## REGISTER FOR TOURNEY
    chars = Character.where("alive = ?", true) # limit to 1000
    accounts_registered = {}
    chars.each do |c|
      if accounts_registered.has_key?(c.account_id) == false
        accounts_registered[c.account_id] = true
        c.register_tourney(1)
      end
    end
    
    # each account can only enter one char per tourney
    
    rs = TourneyRuleset.create
    
    results = TourneyManager.run_tourneys
    puts results
    
    end_time = Time.now
    
    secs_taken = (end_time.to_f - start_time.to_f).round(4)
    
    #puts TourneyManager.get_status
    
    # puts 'results: ' + results.to_s
    
    puts 'seconds taken: ' + secs_taken.to_s
  end

end