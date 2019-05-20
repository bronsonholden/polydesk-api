class AccountsController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!, except: [:create]

  permitted_parameters :all, { identifier: Parameters.string, account: {} }
  permitted_parameters :create, { data: {
                                    type: Parameters.enum('account'),
                                    attributes: {
                                      account_name: Parameters.string,
                                      account_identifier: Parameters.string,
                                      user_name: Parameters.string,
                                      user_email: Parameters.string,
                                      password: Parameters.string,
                                      password_confirmation: Parameters.string } } }
  permitted_parameters :update, { data: {
                                    id: Parameters.id,
                                    type: Parameters.enum('account'),
                                    attributes: {
                                      name: Parameters.string } } }
  permitted_parameters :index, {}
  permitted_parameters :show, {}
  permitted_parameters :destroy, {}
  permitted_parameters :restore, {}

  # GET /accounts
  # Returns only accounts the current user has access to
  def index
    validate_params! :read
    accounts = current_user.accounts.page(current_page).per(per_page)
    options = PaginationGenerator.new(request: request, paginated: accounts).generate
    render json: AccountSerializer.new(accounts, options).serialized_json
  end

  # GET /:identifier/account
  def show
    validate_params! :read
    set_account
    render json: AccountSerializer.new(@account).serialized_json
  end

  # POST /accounts
  def create
    validate_params! :create
    account = Account.create!(attribute_params.slice(:account_name, :account_identifier))
    User.create!(attribute_params.slice(:user_name, :user_email, :password, :password_confirmation).merge({ default_account: account }))
    render json: AccountSerializer.new(account).serialized_json, status: :created
  end

  # PATCH/PUT /:identifier/account
  def update
    validate_params! :update
    authorize Account, :update?
    set_account
    @account.update!(attribute_params)
    render json: AccountSerializer.new(@account).serialized_json
  end

  # DELETE /:identifier/account
  def destroy
    validate_params! :read
    authorize Account, :destroy?
    set_account
    @account.discard!
  end

  # PUT /:identifier/account/restore
  def restore
    validate_params! :read
    authorize Account, :restore?
    set_account
    @account.undiscard!
    render json: AccountSerializer.new(@account).serialized_json, status: :ok
  end

  protected
    def permitted_params
      # Account identifier is used for AccountController actions
      params.except(:controller, :action)
    end

    def validate_params
      if action_name == 'create'
        params.require(:data).tap { |data|
          data.require(:type)
          data.require(:attributes)
        }
      else
        super
      end
    end

  private
    def set_account
      @account = Account.find_by!(identifier: permitted_params.fetch(:identifier))
    end
end
