Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions:  'overrides/sessions'
  }

  resources :accounts, only: [:create, :index]

  scope '/:identifier' do
    resources :documents
    resources :folders
    resources :users
    resources :reports

    get '/account', to: 'accounts#show'
    patch '/account', to: 'accounts#update'
    put '/account', to: 'accounts#update'

    get '/users/:id/permissions', to: 'permissions#index'
    post '/users/:id/permissions', to: 'permissions#create'

    get '/folders/:id/folders', to: 'folders#children'
    post '/folders/:id/folders', to: 'folders#add_folder'
    get '/folders/:id/documents', to: 'folders#documents'
    post '/folders/:id/documents', to: 'folders#add_document'
  end
end
