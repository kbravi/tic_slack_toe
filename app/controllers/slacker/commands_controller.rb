class Slacker::CommandsController < ApplicationController
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
      else
        render :json => {:text => params[:text]}, :status => :ok
      end
    else
      render :json => {:text => "I'm confused"}, :status => :ok
    end
  end
end
