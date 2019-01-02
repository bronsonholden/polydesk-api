Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :accounts, only: [:create, :index]

  if Rails.env.development? || Rails.env.test?
    get '/users', to: 'accounts#show_all'
  end

  scope '/:identifier' do
    resources :documents
    resources :users

    get '/account', to: 'accounts#show'
    patch '/account', to: 'accounts#update'
    put '/account', to: 'accounts#update'
  end
end
