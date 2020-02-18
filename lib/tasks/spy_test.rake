namespace :app do

  # Populates development data
  desc "Test results of spy ability."
  task :spy_test => :environment do
    
    rand_char = CharGen.generate_character(1, 0, 0, 0, 1)  

    puts 'char stats'
    puts rand_char.mid

    (1..10).each do |n|
      puts 'spy attempt ' + n.to_s
      puts rand_char.spy(50, 1)
    end
    
    
  end

end