class BoutManager
  
  # start a bout between two characters, given a specific ruleset
  def self.start_bout(char_1, char_2, rs)
    rep = ReportBuilder.instance

    # set header
    rep.title = rs.match_type + ': ' + char_1.name + ' of ' + char_1.ludus_name + ' vs ' + char_2.name + ' of ' + char_2.ludus_name
    rep.set_owner(char_1.account)
    rep.set_owner(char_2.account)
    
    # start bout
    bout = Bout.new(char_1, char_2, rs)
    
    # iterate through actions until bout is complete
    while (bout.is_finished == false)
      bout.next_action
    end
    
    rep.log(bout.get_result)
    output = Hash.new

    bout.check_injuries # check for injuries sustained during bout
    
    output[:rewards] = bout.allocate_rewards

    output[:text] = rep.output_owned(char_1.account.id)
    
    # save characters and log history
    bout_hist = bout.save
    if bout_hist
      output[:hist_hash] = bout_hist.hash_key
      output[:winner_id] = bout_hist.winner_id
    end
    
    if char_1.generated == 0  # send report to owner_1
      rep.send_owned_report(char_1.account.id, true, output[:hist_hash], char_1.id, Notification_Manager::TYPE_BOUT)
      char_1.account.save
    end
    
    if char_2.generated == 0  # send report to owner_2
      rep.send_owned_report(char_2.account.id, false, output[:hist_hash], char_2.id, Notification_Manager::TYPE_BOUT)
      char_2.account.save
    end
    
    rep.clear
    
    return output
  end
  
  # enter a character in a death gauntlets style battle
  def self.start_bout_gauntlet(char_1, num_bouts, reset_hp)
    rs = PitRuleset.create
    rep = ReportBuilder.instance
    
    output = Hash.new
    output[:hist_hash] = Array.new
    
    round_reached = 0
    (1..num_bouts).each do |n|
      if reset_hp # reset hp for each bout?
        char_1.reset_dmg
      end
      
      if char_1.is_alive == false # continue gauntlet so long as character is alive
        next
      end
      
      round_reached = n
      
      char_2 = CharGen.generate_character(char_1.level, -2, 1, 3, 0) # generate opponent
      
      # set header
      rep.title = rs.match_type + ': ' + char_1.name  + ' of ' + char_2.ludus_name
      rep.set_owner(char_1.account)
    
      # start bout
      bout = Bout.new(char_1, char_2, rs)
      
      # iterate through actions until bout is complete
      while (bout.is_finished == false)
        bout.next_action
      end
      
      bout.check_injuries # check for injuries sustainted
      
      # log actions in bout history (for future viewing)
      hist_hash = bout.save
      output[:hist_hash].push(hist_hash.hash_key)

      # send bout report to owners account
      rep.log(bout.get_result)
      rep.send_owned_report(char_1.account.id, true, hist_hash, char_1.id, Notification_Manager::TYPE_BOUT)
      rep.clear
    end
    
    # reward_messages
    output[:rewards] = Array.new
    
    # if char survives give special reward
    rep.set_owner(char_1.account)
    if char_1.is_alive
      # apply special trait
      char_1.apply_trait(ModsManager::TYPE_REDEEMED)
      message = Message.new(Notification_Manager::MESSAGE_GAUNTLET_WIN % char_1.name, Message::TYPE_REWARD)
      rep.log_owned(message, char_1.account_id)
      
      # xp bonus
      win_exp = char_1.level * 100
      char_1.increment(:exp, win_exp)
      message = Message.new(Notification_Manager::MESSAGE_WIN_EXP % [char_1.name, win_exp.to_s], Message::TYPE_REWARD)
      rep.log_owned(message, char_1.account_id)
      output[:rewards].push(message);
      
      # currency bonus
      win_cur = char_1.level * 75
      char_1.account.increment(:currency, win_cur)
      message = Message.new(Notification_Manager::MESSAGE_WIN_PURSE % win_cur.to_s, Message::TYPE_REWARD)
      rep.log_owned(message, char_1.account_id)
      output[:rewards].push(message);
    else
      message = Message.new(Notification_Manager::MESSAGE_GAUNTLET_LOSS % char_1.name, Message::TYPE_DEATH)
      rep.log_owned(message, char_1.account_id)
      
      # currency bonus
      win_cur = char_1.level * 10 * round_reached
      char_1.account.increment(:currency, win_cur)
      message = Message.new(Notification_Manager::MESSAGE_WIN_PURSE % win_cur.to_s, Message::TYPE_REWARD)
      rep.log_owned(message, char_1.account_id)
      output[:rewards].push(message);
    end

    char_1.account.save
    return output
  end
  
  # simulate x number of bouts between two characters, for balance & performance testing
  def self.simulate_bouts(char_1_id, char_2_id, num_bouts)
    rs = PracticeRuleset.create
     # load chars by id
    char_1 = CharWrapper.load_char(char_1_id)
    char_2 = CharWrapper.load_char(char_2_id)

    @results = Hash.new
    (1..num_bouts).each do |n|
      if (@results.has_key?(char_1.name) == false)
        @results[char_1.name] = 0
      end
      if (@results.has_key?(char_2.name) == false)
        @results[char_2.name] = 0
      end
      
      # start bout
      bout = Bout.new(char_1, char_2, rs)
      
      # iterate through actions until bout is complete
      while (bout.is_finished == false)
        bout.next_action
      end

      @results[bout.char_win.name] += 1
    end

    return @results
  end
  
  # simulate x number of bouts between generated characters, for balance & performance testing
  def self.generate_bout_simulation(level, num_bouts)
    rs = PracticeRuleset.create
    @results = Array.new
    (1..num_bouts).each do |n|
       # load chars by id
      char_1 = CharGen.generate_character(level, 0, 0, 2, 0)
      char_2 = CharGen.generate_character(level, 0, 0, 2, 0)
      
      # start bout
      bout = Bout.new(char_1, char_2, rs)
      
      # iterate through actions until bout is complete
      while (bout.is_finished == false)
        bout.next_action
      end
      
      @results.push(char_1.inspect)
      @results.push(char_2.inspect)
      
      @results.push(bout.get_result)
    end

    return @results
  end
  
end