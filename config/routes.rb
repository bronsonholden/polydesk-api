Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions:  'overrides/sessions',
    confirmations: 'overrides/confirmations'
  }, skip: [:confirmations]

  devise_scope :user do
    get '/confirmations/new', to: 'overrides/confirmations#new'
    get '/confirmations/:confirmation_token', to: 'overrides/confirmations#show', as: :user_confirmation
    post '/confirmations/:confirmation_token', to: 'overrides/confirmations#confirm', as: :user_confirmation_confirm
  end

  get '/', to: 'application#show'

  jsonapi_resources :users, only: [:create], as: :user_create

  scope '/:identifier' do
    jsonapi_resources :documents
    jsonapi_resources :folders
    jsonapi_resources :permissions
    jsonapi_resources :account_users
    jsonapi_resources :forms
    # TODO: Fix routes. Should be /:identifier/users, not
    # /:identifier/users/:id/users --- :id is a redundant identifying
    # attribute for the same user.
    jsonapi_resources :users, except: [:create]
    resources :reports
    resources :options

    get '/account', to: 'accounts#show'
    patch '/account', to: 'accounts#update'
    put '/account', to: 'accounts#update'
    delete '/account', to: 'accounts#destroy'
    put '/account/restore', to: 'accounts#restore', as: :account_restore

    # get '/users/:id/permissions', to: 'permissions#index'
    # post '/users/:id/permissions', to: 'permissions#create'
    # delete '/users/:id/permissions', to: 'permissions#destroy'

    # get '/documents/:id/folder', to: 'documents#folder', as: :document_folder
    # get '/documents/:id/versions/:version/download', to: 'documents#download_version', as: :document_download_version
    get '/documents/:id/download', to: 'documents#download', as: :document_download
    put '/documents/:id/restore', to: 'documents#restore', as: :document_restore

    # get '/folders/:id/folders', to: 'folders#folders', as: :folder_folders
    # post '/folders/:id/folders', to: 'folders#add_folder'
    # get '/folders/:id/documents', to: 'folders#documents', as: :folder_documents
    # post '/folders/:id/documents', to: 'folders#add_document'
    # put '/folders/:id/restore', to: 'folders#restore', as: :folder_restore
    # get '/folders/:id/content', to: 'folders#content', as: :folder_content
    # get '/content', to: 'folders#content', as: :content
    #
    # get '/:model/:id/versions', to: 'versions#index', as: :versions
    # get '/:model/:id/versions/:version', to: 'versions#show', as: :version
    # put '/:model/:id/versions/:version', to: 'versions#restore', as: :version_restore
  end
end
