class CharGen
  
  @@title = [
    'The Crazed', 'The Mutated', 'The Chaotic', 'The Grotesque', 'Goat Herder', 'Storm', 'Teller', 'Morros', 'The Scarred', 'Scarface', 'Raken', 'Drogon', 'Bareth', 'Dagmaer', 'Lorch', 'Painen',
    'The Peasant', 'Shephard', 'The Shephard', 'Pree', 'Wormen', 'Blobben', 'Fyrestrone', 'Ditch Digger', 'The Priest', 'Raeder', 'Skinner', 'Skinface', 'Wallen', 'Egen', 'Gaius', 'Sextus', 'Brutus',
    'The Brutal', 'Hatchet Hand', 'The Butcher', 'Capua'
    ]
    
  @@name = ['Hurr', 'Durr', 'Hefur', 'Dougla', 'Nandosk', 'Duder', 'Petre', 'Nagaru', 'Murloca', 'Charr', 'Muphasa', 'Simba',
    'Elham', 'Lamperius', 'Lambus', 'Optimus', 'Galvas', 'Megos', 'Tick', 'Hex', 'Decimus', 'Maximus', 'Sparkatus', 'Turk',
    'Eddard', 'Petyr', 'Randal', 'Perry', 'Brandon', 'Kandar', 'Kilvo', 'Nimbu', 'Alrick', 'Osmund', 'Boros', 'Jaxx', 'Clay',
    'Jon', 'Jorae', 'Sandor', 'Gregan', 'Xaros', 'Qothar', 'Gendir', 'Crixen', 'Titus', 'Pieotros', 'Kavir', 'Rasko', 'Crassus'
    ] 

  # generate a random character
  def self.generate_character(level, skill_offset, min_mods, max_mods, trait_rolls)
    char = Character.new
    char.id = 'gen_'+rand(9999..99999).to_s
    char.name = @@name.sample + ' ' + @@title.sample
    char.level = level
    char.base_str = 10
    char.base_agi = 10
    char.base_end = 10
    char.base_int = 10
    char.base_x = 0
    char.alive = 1
    char.wins = 0
    char.losses = 0
    char.kills = 0
    char.exp = 0
    char.account_id = 0
    char.att_points = 0
    
    chaos = rand(-8..5)
    if (chaos > 0)
      char.base_x = chaos
    end
    
    att_points = 2 + (level * 1.5).to_i + skill_offset
    (1..att_points).each do |n|
      case rand(1..4)
        when 1
          char.base_str += 1
        when 2
          char.base_agi += 1
        when 3
          char.base_end += 1
        when 4
          char.base_int += 1
      end
    end
    
    char.weapon_id = rand(1..3)
    char.armour_id = rand(1..2)
    
    char.calculate
    
    # apply conditions
    if (max_mods > 0)
      (min_mods..rand(min_mods..max_mods)).each do |n|
        char.store_mod(CharMod.get_random_mod)
      end
    end
    
    char.apply_mods
    
    # apply traits
    if (trait_rolls > 0)
      (1..trait_rolls).each do |n|
        char.store_trait(CharMod.get_random_trait)
      end
    end
    
    char.generated = 1

    return char
  end
  
  # generate a new recruit
  def self.generate_recruit(account_id)
    recruit = Recruit.new
    
    recruit.name = @@name.sample
    recruit.str = 10
    recruit.agi = 10
    recruit.end = 10
    recruit.int = 10
    recruit.account_id = account_id
    recruit.x = 0
    recruit.price = 20
    
    chaos = rand(-8..5)
    if (chaos > 0)
      recruit.x = chaos
    end
    
    (1..3).each do |n|
      case rand(1..4)
        when 1
          recruit.str += 1
        when 2
          recruit.agi += 1
        when 3
          recruit.end += 1
        when 4
          recruit.int += 1
      end
    end
    
    recruit.trait = CharMod.get_random_trait
    recruit.save
    
    return recruit
  end

end
