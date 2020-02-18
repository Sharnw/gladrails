namespace :app do

  # Populates development data
  desc "Creates a report of character stats."
  task :char_report => :environment do
    
    # collect characters for each account and put them through a random number of bouts (10-100) each, or until dead
    char_pool = Array.new
    Character.all.each do |char|
      char.calculate
      char_pool.push(char)
    end
    
    char_pool.each do |char|
      puts char.char_report
    end

    puts "#{'*'*(`tput cols`.to_i)}\nSimulation complete!\n#{'*'*(`tput cols`.to_i)}"
  end

end