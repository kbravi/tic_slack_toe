Rails.application.config.middleware.use OmniAuth::Builder do
  provider :slack, ENV['SLACK_CLIENT_ID'], ENV['SLACK_CLIENT_SECRET'], scope: 'team:read,commands'
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndPointRetainParams.new(env).redirect_to_failure
}

module OmniAuth
  class FailureEndPointRetainParams < OmniAuth::FailureEndpoint
    def redirect_to_failure
      message_key = env['omniauth.error.type']
      new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}#{origin_query_param}#{strategy_name_query_param}#{other_name_query_params}"
      Rack::Response.new(['302 Moved'], 302, 'Location' => new_path).finish
    end

    def other_name_query_params
      return '' if env['omniauth.params'].blank?
      return "&#{env['omniauth.params'].to_query}"
    end
  end
end
