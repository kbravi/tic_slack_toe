class Slacker::ActionsController < ApplicationController
  ALLOWED_CALLBACKS = ['wopr_game']
  before_action :parse_payload
  before_action :verify_slack_token_for_payload
  before_action :set_team_from_payload

  def receive
    if @team.blank? or params[:payload].blank?
      render :json => {:error => "Incomplete request"}, :status => :not_found and return
    end

    callback_id = params[:payload][:callback_id].to_s
    case callback_id
    when "wopr_game"
      render :json => {:text => "Action Received - #{callback_id}"}, :status => :ok
    else
      render :json => {:error => "Sorry. I don't understand the request"}, :status => :bad_request
    end
  end
end
