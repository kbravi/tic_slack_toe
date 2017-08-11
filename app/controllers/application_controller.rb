class ApplicationController < ActionController::API
  include ActionController::Helpers
  helper_method :verify_slack_token, :set_team, :parse_payload, :verify_slack_token_for_payload, :set_team_from_payload

  def verify_slack_token
    if params[:token] == ENV["SLACK_VERIFICATION_TOKEN"]
      return true
    else
      render :json => {:error => "Verification Failed"}, :status => :bad_request
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
      render :json => {:error => "Verification Failed"}, :status => :bad_request
      return false
    end
  end

  def set_team_from_payload
    @team = Team.find_by_slack_identifier(params[:payload][:team][:id])
  end

  def parse_payload
    if params[:payload].present? and params[:payload].is_a? String
      params[:payload] = JSON.parse(params[:payload], :symbolize_names => true)
    end
  end
end
