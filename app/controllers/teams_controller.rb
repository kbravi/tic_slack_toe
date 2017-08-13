class TeamsController < ApplicationController
  # /auth/:provider/callback
  # /auth/slack/callback is the oauth redirect URL when somebody adds this app to their team
  # This action will create or update a team record uniquely defined by 'slack_identifier'
  # redirects_to the team's slack on success
  def connect
    if request.env["omniauth.auth"].present?
      auth = request.env["omniauth.auth"]
      auth_provider = auth.provider
      access_token = auth[:credentials][:token]
      raw = auth[:extra][:raw_info]
      team_identifier = raw[:team_id]
      team = auth[:extra][:team_info][:team]
      if auth_provider == 'slack' and team_identifier.present?
        connected_team = {:name => team[:name], :slack_identifier => team_identifier, :slack_url => raw[:url],
                          :email_domain => team[:email_domain], :slack_access_token => access_token,
                          :slack_icon_url => team[:icon][:image_230],
                          :slack_authorized_user_identifier => raw[:user_id]}
        team = Team.find_by_slack_identifier(connected_team[:slack_identifier])
        if team.blank?
          team = Team.create(connected_team)
        else
          team.update(connected_team)
        end
        redirect_to "#{team.slack_url}messages" and return
      end
    end
    redirect_to :action => :connect_failure and return
  end

  # /auth/:provider/failure
  # Redirects to the public sorry.html page
  # This is triggered
  #   a. by the omniauth gem when the user declines permissions when adding app to slack
  #   b. by the connect action when something goes wrong
  def connect_failure
    redirect_to '/sorry'
  end
end
