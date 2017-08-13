class Team < ApplicationRecord

  # Columns
  # id: Primary Key
  # name: Team's name as captured from oauth2
  # slack_identifier: Team's Slack identifier as captured from oauth2
  # slack_url: Team's slack URL as captured from oauth2
  # email_domain: Team's Email Domain as captured from oauth2
  # slack_access_token: Team's Access Token for the App as captured from oauth2
  # slack_icon_url: Team's Slack Icon URL as captured from oauth2
  # slack_authorized_user_identifier: The User who added the app to this Team

  has_many :games, :dependent => :destroy

  validates_presence_of :slack_identifier, :slack_access_token, :slack_authorized_user_identifier
  validates_uniqueness_of :slack_identifier

  # New Game: Try to create a new game in the channel (channel_identifier)
  # The player challenger_identifier challenges defendent_identifier
  def new_game(channel_identifier, challenger_identifier, defendent_identifier)
    current_game = self.games.where(:channel_identifier => channel_identifier).active.first
    if current_game.present?
      # There is an active game in this channel
      return build_ephemeral("There is an active game going on between <@#{current_game.player1_identifier}> and <@#{current_game.player2_identifier}>. Type */ttt current* to see the board")
    elsif defendent_identifier.blank?
      # The challenger hasn't challenged anybody
      return build_ephemeral("Please tag your opponent. Try */ttt new @somebody*")
    elsif challenger_identifier == defendent_identifier
      # The challenged challenged themselves
      return build_ephemeral("Come on, you can't play yourself and win everytime :wink: Try */ttt new @somebody_else*")
    else
      # Create a new game and randomly assign player1 and player2 from challenger and defender
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

  # Current Game: Find the current active game in the channel (channel_identifier)
  def current_game(channel_identifier)
    current_game = self.games.where(:channel_identifier => channel_identifier).active.first
    if current_game.present?
      # There is an active game
      build_ephemeral(current_game.build_current_board)
    else
      # There isn't any active game
      return build_ephemeral("There is no active game here. Try */ttt new @somebody* to start a new game.")
    end
  end

  # New Move: Try to create a move in the active game of the channel (channel_identifier)
  # The player (player_identifier) had clicked a button that emitted some actions (actions)
  def process_move(channel_identifier, player_identifier, actions)
    button_action = actions.first
    # The game's id is extracted from the action button's name attribute
    game = self.games.where(:channel_identifier => channel_identifier, :id => button_action[:name].to_i).first
    if game.present?
      # There is a game in the channel. Check if the player is playing in their turn
      if (not game.complete) and (game.next_player == player_identifier)
        # The action buttons have values in the 'row,column' format
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

  # Leaderboard: Print all the people who have played atleast one game
  # The list will be sorted based on the number of wins by a player
  # When channel_identifier is passed, the list is limited to the current channel
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
