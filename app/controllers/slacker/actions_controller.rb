class Slacker::ActionsController < ApplicationController
  ALLOWED_CALLBACKS = [Game::ACTION_CALLBACK_KEY]

  before_action :parse_payload
  before_action :verify_slack_token_for_payload
  before_action :set_team_from_payload

  def receive
    if @team.blank? or params[:payload].blank?
      render not_found_response(build_ephemeral(incomplete_request_message))
    else
      payload = params[:payload]
      callback_id = payload[:callback_id].to_s
      case callback_id
      when Game::ACTION_CALLBACK_KEY
        channel_identifier = payload[:channel][:id]
        player_identifier = payload[:user][:id]
        actions = payload[:actions]
        response_message = @team.process_move(channel_identifier, player_identifier, actions)
        render success_response(response_message)
      else
        render bad_request_response(build_ephemeral(unsupported_action_message))
      end
    end
  end
end
