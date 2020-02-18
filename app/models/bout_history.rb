class BoutHistory < ActiveRecord::Base
  attr_accessible :acc_1_id, :acc_2_id, :loser_id, :winner_id, :hash_key, :json_text
end
