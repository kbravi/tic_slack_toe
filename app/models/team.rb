class Team < ApplicationRecord
  has_many :games, :dependent => :destroy

  validates_presence_of :slack_identifier, :slack_access_token, :slack_authorized_user_identifier
  validates_uniqueness_of :slack_identifier

  def new_game(channel_identifier, challenger_identifier, defendent_identifier)
    current_game = self.games.where(:channel_identifier => channel_identifier).active.first
    if current_game.present?
      return build_ephemeral("There is an active game going on between <@#{current_game.player1_identifier}> and <@#{current_game.player2_identifier}>. Type */ttt current* to see the board")
    elsif defendent_identifier.blank?
      return build_ephemeral("Please tag your opponent. Try */ttt new @somebody*")
    elsif challenger_identifier == defendent_identifier
      return build_ephemeral("Come on, you can't play yourself and win everytime :wink: Try */ttt new @somebody_else*")
    else
      game = self.games.new(:channel_identifier => channel_identifier)
      game.player1_identifier, game.player2_identifier = [challenger_identifier, defendent_identifier].shuffle
      game.challenger_identifier = challenger_identifier
      if game.save
        return build_in_channel(game.build_current_board)
      else
        return build_ephemeral("Sorry, something went wrong on our end")
      end
    end
  end

  def current_game(channel_identifier)
    current_game = self.games.where(:channel_identifier => channel_identifier).active.first
    if current_game.present?
      build_ephemeral(current_game.build_current_board)
    else
      return build_ephemeral("There is no active game here. Try */ttt new @somebody* to start a new game.")
    end
  end

  def process_move(channel_identifier, player_identifier, actions)
    button_action = actions.first
    game = self.games.where(:channel_identifier => channel_identifier, :id => button_action[:name].to_i).first
    if game.present?
      if (not game.complete) and (game.next_player == player_identifier)
        row, column = button_action[:value].split(',').map(&:to_i)
        player1_move = (player_identifier == game.player1_identifier)
        player2_move = (player_identifier == game.player2_identifier)
        move = Move.new(:game => game, :row => row, :column => column, :player1_move => player1_move, :player2_move => player2_move)
        move.save
        game.reload.evaluate_board_for_results
      end
      return build_replace_original(build_in_channel(game.reload.build_current_board))
    else
      return build_ephemeral("Uh ho. That shouldn't have happened. Now, I'm confused :thinking_face:")
    end
  end

  def leaderboard(channel_identifier = nil)
    games = self.games
    games = games.where(:channel_identifier => channel_identifier) if channel_identifier.present?
    players = Hash[array_group_count_sort(games.map{|game| [game.player1_identifier, game.player2_identifier]}.flatten)]
    winners = Hash[array_group_count_sort(games.map{|game| game.winner_identifier})]
    return build_in_channel({
        :text => "*Tic Slack Toe - Leaderboard* #{"(this channel)" if channel_identifier.present?}",
        :attachments => players.map{|player, count| {:text => "<@#{player}> played #{count.to_i} games and won #{winners[player].to_i} times" }}
      })
  end
end
