Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :documents
  resources :accounts, only: [:create, :index]

  scope '/(:identifier)' do
    get '/account', to: 'accounts#show'
    patch '/account', to: 'accounts#update'
    put '/account', to: 'accounts#update'
  end
end
