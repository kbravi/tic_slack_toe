class ApplicationController < ActionController::API
  include Slacker::ResponsePackager
  include Slacker::RequestParser
  include Slacker::CommonResponses

  def verify_slack_token
    if params[:token] == ENV["SLACK_VERIFICATION_TOKEN"]
      return true
    else
      render bad_request_response(build_ephemeral(verification_failed_message))
      return false
    end
  end

  def set_team
    @team = Team.find_by_slack_identifier(params[:team_id])
  end

  def verify_slack_token_for_payload
    if params[:payload][:token] == ENV["SLACK_VERIFICATION_TOKEN"]
      return true
    else
      render bad_request_response(build_ephemeral(verification_failed_message))
      return false
    end
  end

  def set_team_from_payload
    @team = Team.find_by_slack_identifier(params[:payload][:team][:id])
  end

  def parse_payload
    params[:payload] = parse_json_string_to_hash(params[:payload])
  end
end
