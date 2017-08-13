class Slacker::ActionsController < ApplicationController
  ALLOWED_CALLBACKS = [Game::ACTION_CALLBACK_KEY]

  # Slack sends Payload as a json string: converting to hash
  before_action :parse_payload

  # Always verify if the request was sent by slack using the verification token
  before_action :verify_slack_token_for_payload

  # Identify team that triggered this request
  before_action :set_team_from_payload

  # /slacker/actions/receive
  # This is the Actions (interactive messages) callback action that is used by the Slack App.
  # When a user interacts with a message (with buttons, menu etc.), Slack will POST a request.
  def receive
    if @team.blank? or params[:payload].blank?
      # The team hasn't added this app
      render not_found_response(build_ephemeral(incomplete_request_message))
    else
      payload = params[:payload]
      callback_id = payload[:callback_id].to_s
      # Callbacks uniquely define the scopr of an interaction
      case callback_id
      when Game::ACTION_CALLBACK_KEY
        # The user interacted with a game's board tile
        channel_identifier = payload[:channel][:id]
        player_identifier = payload[:user][:id]
        actions = payload[:actions]
        # Create a new move in the channel's (channel_identifier) current game (game_id set by actions[0][:name])
        response_message = @team.process_move(channel_identifier, player_identifier, actions)
        render success_response(response_message)
      else
        # Bad Request
        render bad_request_response(build_ephemeral(unsupported_action_message))
      end
    end
  end
end
