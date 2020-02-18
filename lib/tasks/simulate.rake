namespace :app do

  desc "Simulate bout activity for populated characters."
  task :simulate => :environment do
    
    # collect characters for each account and put them through a random number of bouts (10-100) each, or until dead
    char_pool = Array.new
    Character.all.each do |char|
      char.calculate
      char_pool.push(char)
    end
    
    rs = PracticeRuleset.create
    char_pool.each do |char|
      (1..5).each do |n|
        if (char.is_alive == false)
          next
        end
        puts char.name + ' bout ' + n.to_s
        rand_char = CharGen.generate_character(char.level, 0, 0, 2, 1)
        output = BoutManager.start_bout(char, rand_char, rs)
        char.reset
      end
    end

    puts "#{'*'*(`tput cols`.to_i)}\nSimulation complete!\n#{'*'*(`tput cols`.to_i)}"
  end

end