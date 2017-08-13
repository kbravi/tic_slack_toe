class Slacker::CommandsController < ApplicationController
  ALLOWED_COMMANDS = ['/ttt']

  # Always verify if the request was sent by slack using the verification token
  before_action :verify_slack_token

  # Identify team that triggered this request
  before_action :set_team

  # /slacker/commands/receive
  # This is the commands callback action that is used by the Slack App
  # When a user enters a command (relevant to this app), Slack will post a request to this action
  def receive
    if @team.blank?
      # unidentified team: This App isn't connected to the team that triggered this command
      render not_found_response(build_ephemeral(incomplete_request_message))
    else
      case params[:command]
      when "/ttt"
        # Split the command suffixes and extract first two words
        first_word, second_word = params[:text].to_s.split(' ')
        channel_identifier = params[:channel_id]
        case first_word
        when "new"
          # Start a new game
          challenger_identifier = params[:user_id]
          defendent_identifier = extract_slack_user_identifier_from_text(second_word)
          response_message = @team.new_game(channel_identifier, challenger_identifier, defendent_identifier)
        when "current"
          # Find the current game in the channel
          response_message = @team.current_game(channel_identifier)
        when "leaderboard"
          # Leaderboard
          if second_word == "here"
            # in this channel
            response_message = @team.leaderboard(channel_identifier)
          else
            # across the team
            response_message = @team.leaderboard
          end
        when "help"
          # Help message with possible commands
          response_message = help_message
        else
          # Not a supported command
          response_message = unidentified_command_message
        end
        render success_response(response_message)
      else
        # Bad Request
        render bad_request_response(build_ephemeral(unsupported_command_message))
      end
    end
  end
end
