class ApplicationController < ActionController::API
  include ActionController::Helpers
  helper_method :verify_slack_token, :set_team

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
end
