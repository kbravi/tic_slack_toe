class Slacker::ActionsController < ApplicationController
  ALLOWED_CALLBACKS = [Game::ACTION_CALLBACK_KEY]

  before_action :parse_payload
  before_action :verify_slack_token_for_payload
  before_action :set_team_from_payload

  def receive
    if @team.blank? or params[:payload].blank?
      render :json => {:text => "Incomplete request"}, :status => :not_found and return
    end
    payload = params[:payload]
    callback_id = payload[:callback_id].to_s
    case callback_id
    when Game::ACTION_CALLBACK_KEY
      channel_identifier = payload[:channel][:id]
      player_identifier = payload[:user][:id]
      actions = payload[:actions]
      message = @team.process_move(channel_identifier, player_identifier, actions)
      render :json => message, :status => :ok
    else
      render :json => {:text => "Sorry. I don't understand the request"}, :status => :bad_request
    end
  end
end
