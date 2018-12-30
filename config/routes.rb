Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :documents
  resources :accounts, only: [:create, :index]

  if Rails.env.development? || Rails.env.test?
    resources :users, only: [:index]
  end

  scope '/(:identifier)' do
    get '/account', to: 'accounts#show'
    patch '/account', to: 'accounts#update'
    put '/account', to: 'accounts#update'
  end
end
