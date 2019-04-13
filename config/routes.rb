Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions:  'overrides/sessions'
  }

  resources :accounts, only: [:create, :index]

  get '/', to: 'application#show'

  scope '/:identifier' do
    resources :documents
    resources :folders
    resources :users
    resources :reports
    resources :forms
    resources :options

    get '/account', to: 'accounts#show'
    patch '/account', to: 'accounts#update'
    put '/account', to: 'accounts#update'

    get '/users/:id/permissions', to: 'permissions#index'
    post '/users/:id/permissions', to: 'permissions#create'

    get '/documents/:id/folder', to: 'documents#folder', as: :document_folder
    put '/documents/:id/restore', to: 'documents#restore', as: :document_restore

    get '/folders/:id/folders', to: 'folders#children', as: :folder_folders
    post '/folders/:id/folders', to: 'folders#add_folder'
    get '/folders/:id/documents', to: 'folders#documents', as: :folder_documents
    post '/folders/:id/documents', to: 'folders#add_document'

    get '/:model/:id/versions', to: 'versions#index', as: :versions
    get '/:model/:id/versions/:version', to: 'versions#show', as: :version
    put '/:model/:id/versions/:version', to: 'versions#reify', as: :version_reify
  end
end
