class Slacker::CommandsController < ApplicationController
  ALLOWED_COMMANDS = ['/ttt']

  before_action :verify_slack_token
  before_action :set_team

  def receive
    if @team.blank?
      render not_found_response(build_ephemeral(incomplete_request_message))
    else
      case params[:command]
      when "/ttt"
        first_word, second_word = params[:text].to_s.split(' ')
        channel_identifier = params[:channel_id]
        case first_word
        when "new"
          challenger_identifier = params[:user_id]
          defendent_identifier = extract_slack_user_identifier_from_text(second_word)
          response_message = @team.new_game(channel_identifier, challenger_identifier, defendent_identifier)
        when "current"
          response_message = @team.current_game(channel_identifier)
        when "leaderboard"
          if second_word == "here"
            response_message = @team.leaderboard(channel_identifier)
          else
            response_message = @team.leaderboard
          end
        when "help"
          response_message = help_message
        else
          response_message = unidentified_command_message
        end
        render success_response(response_message)
      else
        render bad_request_response(build_ephemeral(unsupported_command_message))
      end
    end
  end
end
