class Slacker::CommandsController < ApplicationController
  ALLOWED_COMMANDS = ['/ttt']

  before_action :verify_slack_token
  before_action :set_team

  def receive
    if @team.blank?
      render :json => {:error => "Incomplete request"}, :status => :not_found and return
    end
    case params[:command]
    when "/ttt"
      case params[:text]
      when "help"
        render :json => {:text => "I am helping"}, :status => :ok
      when "test"
        render :json => button_test.as_json, :status => :ok
      else
        render :json => {:text => params[:text]}, :status => :ok
      end
    else
      render :json => {:error => "Sorry. I don't understand the command"}, :status => :bad_request
    end
  end

  private

  def button_test
    {
      "text" => "Would you like to play a game?",
      "attachments" => [
        {
          "text" => "Choose a game to play",
          "fallback" => "You are unable to choose a game",
          "callback_id" => "wopr_game",
          "color" => "#3AA3E3",
          "attachment_type" => "default",
          "actions" => [
            {
              "name" => "game",
              "text" => "Chess",
              "type" => "button",
              "value" => "chess"
            },
            {
              "name" => "game",
              "text" => "Falken's Maze",
              "type" => "button",
              "value" => "maze"
            },
            {
              "name" => "game",
              "text" => "Thermonuclear War",
              "style" => "danger",
              "type" => "button",
              "value" => "war",
              "confirm" => {
                  "title" => "Are you sure?",
                  "text" => "Wouldn't you prefer a good game of chess?",
                  "ok_text" => "Yes",
                  "dismiss_text" => "No"
              }
            }
          ]
        }
      ]
    }
  end

end
