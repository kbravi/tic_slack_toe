class Slacker::CommandsController < ApplicationController
  ALLOWED_COMMANDS = ['/ttt']

  before_action :verify_slack_token
  before_action :set_team

  def receive
    if @team.blank?
      render :json => {:text => "Incomplete request"}, :status => :not_found
    else
      case params[:command]
      when "/ttt"
        first_word, second_word = params[:text].to_s.split(' ')
        channel_identifier = params[:channel_id]
        case first_word
        when "new"
          challenger_identifier = params[:user_id]
          defendent_identifier = extract_slack_user_identifier_from_text(second_word)
          message = @team.new_game(channel_identifier, challenger_identifier, defendent_identifier)
        when "current"
          message = @team.current_game(channel_identifier)
        when "leaderboard"
          if second_word == "here"
            message = @team.leaderboard(channel_identifier)
          else
            message = @team.leaderboard
          end
        when "help"
          message = help_message
        else
          message = unidentified_message
        end
        render :json => message, :status => :ok
      else
        render :json => {:text => "That was not a supported command"}, :status => :bad_request
      end
    end
  end

  private

  def extract_slack_user_identifier_from_text(text)
    if text.to_s.include? '|' and text.to_s.include? '<@'
      return text.to_s.split('|').first.to_s.split('<@').last
    else
      return text.to_s
    end
  end

  def help_message
    help_text = "Hey, you! :wave:\n"
    help_text += "Would you like to indulge in some *Tic Tac Toe* fun?:\n"
    help_text += "Here are some commands:\n"
    help_text += "*/ttt new @sombody* will let you start a new game with anybody (not yourself, ofcourse - that would be wrong)\n"
    help_text += "*/ttt current* will let you know about the currently active game in that channel\n"
    help_text += "*/ttt leaderboard here* will display the leaders in that channel\n"
    help_text += "*/ttt leaderboard* will display the leaders across your team\n"
    return {
      :text => help_text,
      :response_type => "ephemeral"
    }
  end

  def unidentified_message
    return {
      :text => "Hmmm. I can't figure out what that meant. Try */ttt help* for available commands.",
      :response_type => "ephemeral"
    }
  end
end
