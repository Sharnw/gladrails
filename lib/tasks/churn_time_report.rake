namespace :app do

  desc "Generate chars for 100 random bouts and determine how long it takes."
  task :churn_time_report => :environment do
    
    start_time = Time.now
    
    rs = PracticeRuleset.create
    (1..400).each do |n|
        c1 = CharGen.generate_character(5, 0, 0, 2, 1)
        c2 = CharGen.generate_character(5, 0, 0, 2, 1)
        BoutManager.start_bout(c1, c2, rs)
        #puts c1.name + ' ----- ' + c2.name
    end
    
    end_time = Time.now
    
    secs_taken = (end_time.to_f - start_time.to_f).round(4)
    
    puts 'seconds taken: ' + secs_taken.to_s
  end

end