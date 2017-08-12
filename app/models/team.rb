class Team < ApplicationRecord
  has_many :games, :dependent => :destroy

  validates_presence_of :slack_identifier, :slack_access_token, :slack_authorized_user_identifier
  validates_uniqueness_of :slack_identifier

  def new_game(channel_identifier, challenger_identifier, defendent_identifier)
    current_game = self.games.where(:channel_identifier => channel_identifier).active.first
    if current_game.present?
      return {:text => "There is an active game going on between <@#{current_game.player1_identifier}> and <@#{current_game.player2_identifier}>. Type */ttt current* to see the board", :response_type => "ephemeral"}
    elsif defendent_identifier.blank?
      return {:text => "Please tag your opponent. Try */ttt new @somebody*", :response_type => "ephemeral"}
    elsif challenger_identifier == defendent_identifier
      return {:text => "Come on, you can't play yourself and win everytime :wink: Try */ttt new @somebody_else*", :response_type => "ephemeral"}
    else
      game = self.games.new(:channel_identifier => channel_identifier)
      game.player1_identifier, game.player2_identifier = [challenger_identifier, defendent_identifier].shuffle
      game.challenger_identifier = challenger_identifier
      if game.save
        return game.build_current_board.deep_merge!({:response_type => "in_channel"})
      else
        return {:text => "Sorry, something went wrong on our end", :response_type => "ephemeral"}
      end
    end
  end

  def current_game(channel_identifier)
    current_game = self.games.where(:channel_identifier => channel_identifier).active.first
    if current_game.present?
      current_game.build_current_board.deep_merge!({:response_type => "ephemeral"})
    else
      return {:text => "There is no active game here. Try */ttt new @somebody* to start a new game.", :response_type => "ephemeral"}
    end
  end

  def process_move(channel_identifier, player_identifier, actions)
    button_action = actions.first
    game = self.games.where(:channel_identifier => channel_identifier, :id => button_action[:name].to_i).first
    if game.present?
      if game.next_player == player_identifier
        row, column = button_action[:value].split(',').map(&:to_i)
        player1_move = (player_identifier == game.player1_identifier)
        player2_move = (player_identifier == game.player2_identifier)
        move = Move.new(:game => game, :row => row, :column => column, :player1_move => player1_move, :player2_move => player2_move)
        move.save
        game.reload.evaluate_board_for_results
      end
      return game.reload.build_current_board.deep_merge!({:response_type => "in_channel"})
    else
      return {:text => "Uh ho. That shouldn't have happened. Now, I'm confused :thinking_face:"}
    end
  end

  def leaderboard(channel_identifier = nil)
    games = self.games
    games = games.where(:channel_identifier => channel_identifier) if channel_identifier.present?
    players = Hash[array_group_count_sort(games.map{|game| [game.player1_identifier, game.player2_identifier]}.flatten)]
    winners = Hash[array_group_count_sort(games.map{|game| game.winner_identifier})]
    return {
      :response_type => "in_channel",
      :text => "*Tic Slack Toe - Leaderboard* #{"(this channel)" if channel_identifier.present?}",
      :attachments => players.map{|player, count| {:text => "<@#{player}> played #{count.to_i} times and won #{winners[player].to_i} times" }}
    }
  end

  def array_group_count_sort(array)
    h = Hash.new(0)
    array.each{|x| h[x] = h[x].to_i + 1}
    return h.sort_by{|k,v| -v}
  end
end
