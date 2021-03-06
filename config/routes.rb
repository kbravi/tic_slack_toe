Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :slacker do
    post 'actions/receive' => 'actions#receive'
    post 'commands/receive' => 'commands#receive'
  end

  get '/auth/:provider/callback' => 'teams#connect'
  get '/auth/failure' => 'teams#connect_failure'
end
