namespace :app do

  # each ludus may have 1 char in intense training
  
  # these chars get xp bonus, + chance at well drilled trait
  
  # after level 5 their training will end if they don't have minimum 3 bouts per level

  desc "Adds training xp bonuses to chars."
  task :train_xp_hourly => :environment do
    
    start_time = Time.now

    # (1..50).each do |n2|
      # # generate char
      # char = CharGen.generate_character(Roll.roll_range(1, 7).to_i, 0, 0, 2, 1)
      # char.account_id = 1
      # # save char
      # char.save
    # end

    chars = Character.where("alive = ? AND activity = 'training'", true)
    #chars = Character.find(:all)
    chars.each do |c|
      c.attempt_training
    end
    
    end_time = Time.now
    
    secs_taken = (end_time.to_f - start_time.to_f).round(4)
    
    puts 'chars: ' + chars.size.to_s
    
    puts 'seconds taken: ' + secs_taken.to_s
  end

end