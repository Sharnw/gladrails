namespace :app do

  # Populates development data
  desc "Creates a report of desired xp for each level-up."
  task :exp_report => :environment do
    
    rand_char = CharGen.generate_character(1, 0, 0, 0, 1)  
    
    (1..30).each do |n|
      puts 'Level ' + rand_char.level.to_s + ': ' + rand_char.desired_xp.to_s
      rand_char.level_up
    end
    
    
  end

end