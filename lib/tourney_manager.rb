class TourneyManager
  
  TYPE_ROBIN_SCORE = 'robin_score'
  TYPE_ROYALE = 'royale'
  TYPE_GAUNTLET = 'gauntlet'
  
  @@tourney_types = {
    TYPE_ROBIN_SCORE => 'Round Robin',
    TYPE_ROYALE => 'Battle Royale',
    TYPE_GAUNTLET => 'Gauntlet'
  }
    
  @@tourney_list = { # hard-coded list of permanent tourneys
    1 => {:name => 'Test Tourney 1', :type => TYPE_ROBIN_SCORE, :lvl_min => 1, :lvl_max => 5, :min => 10, :max => 100, :group => 10, :repeat => 1, :gen_chars => 1, :pay => 1.5},
    2 => {:name => 'Test Tourney 2', :type => TYPE_ROBIN_SCORE, :lvl_min => 8, :lvl_max => 20, :min => 10, :max => 100, :group => 10, :repeat => 2, :gen_chars => 0, :pay => 2}
  }

  # if not enough entrants generate the rest

  # Elite (PC houses only), Open (PC & NPC houses)
  
  def self.get_tourney(tourney_id)
    return @@tourney_list[tourney_id.to_i]
  end
  
  def self.get_tourney_name(tourney_id)
    return @@tourney_list[tourney_id.to_i][:name]
  end
  
  def self.get_tourneys
    return @@tourney_list
  end
  
  def self.get_status
    output = []
    @@tourney_list.each do |k, v|
      time = Time.now.round(1.hour)
      time = time - (time.min).minutes - (time.sec).seconds
      time = time + 1.hour
      while time.hour % v[:repeat] != 0
        time = time + 1.hour
      end
      
      num_entries = Character.where(:tourney_id => k).count
      
      output.push({ :id => k, :name => v[:name], :type => @@tourney_types[v[:type]], :next => time, :num_entries => num_entries })
    end
    
    return output
  end
  
  def self.run_tourneys
    results = {}
    rs = TourneyRuleset.create
    @@tourney_list.each do |k, v|
      if Time.now.hour % v[:repeat] == 0
        results[v[:name]] = {}
        groups = {}
        
        # collect chars entered in this tourney, order by? date_entered?
        chars = Character.where("alive = ? AND tourney_id = ?", true, k) # limit to 1000
        n = 1
        g = 1
        # start off by preparing groups etc
        if chars.length >= v[:min]
          results[v[:name]][g] = {}
          groups[g] = []
          chars.each do |c|
            c.calculate
            if n > v[:group]
              n = 1
              g += 1
              results[v[:name]][g] = {}
              groups[g] = []
            else
              n += 1
            end
            results[v[:name]][g][c.id] = {:name => c.name, :wins => 0}
            groups[g].push(c)
          end
        elsif chars.length > 0 and v[:gen_chars]
          # run with generated characters, only need one group

          groups[1] = []
          results[v[:name]][1] = {}

          chars.each do |c|
            c.calculate
            results[v[:name]][g][c.id] = {:name => c.name, :wins => 0, :gen => 0}
            groups[1].push(c)
          end

          to_gen = v[:min] - chars.length
          i = 1
          while i < to_gen do
            gc = CharGen.generate_character(rand(v[:lvl_min]..v[:lvl_max]), 0, 1, 2, 1)
            results[v[:name]][g][gc.id] = {:name => gc.name, :wins => 0, :gen => 1}
            groups[1].push(gc)
            i = i + 1
          end
        end
          
        total_bouts = 0
        
        groups.each do |g, g_array| # iterate groups
          g_array_backup = g_array # keep a backup
          g_array.each do |c|
            # each char loops through rest of group
            g_array.each do |c2|
              if c.id == c2.id or c.account_id == c2.account_id # do not vs same char or account
                next
              end
              
              output = BoutManager.start_bout(c, c2, rs)
              results[v[:name]][g][output[:winner_id]][:wins] += 1
              
              c.reset
              c2.reset
            end
            c.remove_tourney
            g_array.delete(c)
          end
          
          # send notification to all chars in this group
          bouts = g_array.length - 1
          g_array_backup.each do |c|
            # NOTE: this isn't a proper round robin.. need to make sure they only fight each other once.. so you remove that char from array each time
            
            wins = results[v[:name]][g][c.id][:wins]
            
            win_cur = c.level * 5
            win_glory = 0
            if wins > 0
              win_cur += (c.level * wins) * 10
              win_glory += ((6 * c.level ) * c.glr_mod).floor
              c.increment(:glory, win_glory)
              c.account.increment(:glory, win_glory)
            end
            
            c.account.increment(:currency, win_cur)
            c.account.save

            c.remove_tourney
            
            html = c.name + ' won ' + wins.to_s + '/' + bouts.to_s + ' bouts.<br />'
            html += 'He receives a tournament prize of ' + win_cur.to_s + ' and brings ' + win_glory.to_s + ' glory to your ludus!'
            
            Notification_Manager.log_new('Tourney Report - ' + v[:name] + ' -  Group ' + g.to_s, html, c.account_id, c.id, Notification_Manager::TYPE_REPORT, nil)
          end
        end


      end
      

    end
    
    return results
  end
  
end