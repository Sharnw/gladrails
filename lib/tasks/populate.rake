namespace :app do

  # Checks and ensures task is not run in production.
  task :ensure_development_environment => :environment do
    if Rails.env.production?
      raise "\nI'm sorry, I can't do that.\n(You're asking me to drop your production database.)"
    end
  end
  
  # Custom install for developement environment
  desc "Install"
  task :install => [:ensure_development_environment, "db:migrate", "db:test:prepare", "db:seed", "app:populate", "spec"]

  # Custom reset for developement environment
  desc "Reset"
  task :reset => [:ensure_development_environment, "db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed", "app:populate"]

  # Populates development data
  desc "Populate the database with development data."
  task :populate => :environment do
    puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n#{'*'*(`tput cols`.to_i)}"
    # Removes content before populating with data to avoid duplication
    Rake::Task['db:reset'].invoke
    
    (1..10).each do |n|
      new_acc = Hash.new
      new_acc[:username] = 'test' + n.to_s
      new_acc[:account_name] = 'Test Ludus ' + n.to_s
      new_acc[:password] = 'test'
      new_acc[:password_confirmation] = 'test'
      new_acc[:email] = 'test'  + n.to_s + '@test.com'
      new_acc[:email_confirmation] = 'test'  + n.to_s + '@test.com'
      account = Account.create(new_acc)
      account.verified = true
      account.save
    end
    
    weap = Weapon.new
    weap.name = 'Simple Sword'
    weap.w_type = Weapon::TYPE_SLASH
    weap.min_dmg = 2
    weap.max_dmg = 8
    weap.crit = 2
    weap.save
    
    weap = Weapon.new
    weap.name = 'Simple Mace'
    weap.w_type = Weapon::TYPE_BLUDGE
    weap.min_dmg = 1
    weap.max_dmg = 10
    weap.crit = 2
    weap.save
    
    weap = Weapon.new
    weap.name = 'Simple Spear'
    weap.w_type = Weapon::TYPE_STAB
    weap.min_dmg = 3
    weap.max_dmg = 7
    weap.crit = 2
    weap.save
    
    arm = Armour.new
    arm.name = 'Leather Armour'
    arm.a_type = Armour::TYPE_LIGHT
    arm.save
    
    arm = Armour.new
    arm.name = 'Mail Armour'
    arm.a_type = Armour::TYPE_HEAVY
    arm.save
    
    arm = Armour.new
    arm.name = 'Leather Armour'
    arm.a_type = Armour::TYPE_LIGHT
    arm.save
    
    (1..3).each do |n|
      (1..3).each do |n2|
        # generate char
        char = CharGen.generate_character(Roll.roll_range(1, 7).to_i, 0, 0, 1, 1)
        char.account_id = n
        if n2 == 1
          char.activity = 'training'
        end
        # save char
        char.save
        # for each active_mod add perma mod for that char
        char.active_conditions.each do |m_key, mod|
          char.apply_perma_mod(m_key)
        end
        
        # for each active_mod add perma mod for that char
        char.active_traits.each do |m_key, mod|
          char.apply_trait(m_key)
        end
      end
    end

    puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
  end

end