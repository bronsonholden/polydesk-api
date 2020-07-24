require 'polydesk/auth_context'

# TODO: For all POST requests that contain resource objects, need to check
# type and return 409 if it doesn't match with the collection resource type.
class ApplicationController < ActionController::API
  before_action :forbid_client_generated_id, only: :create
  before_action :set_tenant
  after_action :clear_tenant

  # Thoughts
  # class ShowFoo < ShowResource
  #   def initialize(params, scope)
  #   end
  #
  #   def entify
  #     @scope.find(params.fetch('id', 0))
  #   end
  # end
  #
  # def foo_show
  #   show_foo = ShowFoo.new(request.params)
  #   object = show_foo.entify
  #   authorize object
  #   render object
  # end
  #
  # def foo_update
  #   update_foo = UpdateFoo.new(request.params)
  #   object = update_foo.entify
  #   authorize object
  #   object.save!
  #   render object
  # end
  #
  # def foo_index
  #   index_foos = IndexFoos.new(request.params)
  #   index_foos.filter
  #   index_foos.sort
  #   index_foos.paginate
  #   objects = index_foos.entify
  #   authorize objects
  #   render objects
  # end
  #
  # def foo_bars
  #   foo = ShowFoo.new(request.params).entify
  #   authorize foo
  #   scope = policy_scope(Bar).where(foo: foo)
  #   index_bars = IndexBars.new(request.params, scope)
  #   index_bars.filter
  #   index_bars.sort
  #   index_bars.paginate
  #   objects = index_bars.entify
  #   authorize objects
  #   render objects
  # end

  if Rails.env.test?
    after_action :verify_authorized, unless: :devise_controller?
  end

  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  include Polydesk

  rescue_from StandardError, with: :server_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_exception
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_exception
  rescue_from ActiveRecord::StatementInvalid, with: :statement_invalid_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from JSON::Schema::ValidationError, with: :prefab_schema_violation_exception
  rescue_from Polydesk::Errors::AccountIsDisabled, with: :api_exception
  rescue_from Polydesk::Errors::InvalidConfirmationToken, with: :api_exception
  rescue_from Polydesk::Errors::NotVersionable, with: :api_exception
  rescue_from Polydesk::Errors::StorageLimitReached, with: :api_exception
  rescue_from Polydesk::Errors::FormSchemaViolated, with: :api_exception
  rescue_from Polydesk::Errors::NoAccountAccess, with: :api_exception
  rescue_from Polydesk::Errors::ClientGeneratedIdsForbidden, with: :api_exception
  rescue_from Polydesk::Errors::MalformedRequest, with: :api_exception
  rescue_from Polydesk::Errors::UniqueFieldViolation, with: :api_exception
  rescue_from Polydesk::Errors::InvalidFormSchemaKey, with: :api_exception
  rescue_from Polydesk::Errors::InvalidBlueprintSchema, with: :api_exception
  rescue_from Polydesk::Errors::PrefabCriteriaNotMet, with: :api_exception
  rescue_from Polydesk::Errors::GeneratorFunctionArgumentError, with: :api_exception

  def pundit_user
    Polydesk::AuthContext.new(current_user, current_account)
  end

  # Allow authentication by providing a persistent, manually generated
  # authentication token via the 'auth-token' header.
  def current_user
    auth_token = request.headers["auth-token"]
    if auth_token.nil?
      super
    else
      super
      # TODO: find user by auth token
    end
  end

  def current_account
    Account.find_by_identifier(params[:identifier])
  end

  # GET /
  def show
    render json: {}, status: :ok
  end

  def render_authenticate_error
    account = Account.new
    account.errors.add('user', 'must be logged in')
    render json: ErrorSerializer.new(account.errors).serialized_json, status: :unauthorized
  end

  protected

  def page_offset
    (params.dig(:page, :offset) || 0).to_i
  end

  def page_limit
    (params.dig(:page, :limit) || 25).to_i
  end

  def allowed_attributes(_policy)
    policy_restrictions(:attributes, _policy)
  end

  def allowed_relationships(_policy)
    policy_restrictions(:relationships, _policy)
  end

  def sanitize_payload(payload, record_klass)
    _policy = policy(record_klass)
    forbid_disallowed_attributes(payload, _policy)
    forbid_disallowed_relationships(payload, _policy)
    payload
  end

  def sanitize_request_payload(payload)
    forbid_client_generated_id(payload)
  end

  def policy_restrictions(type, _policy)
    # Only relevant when creating or updating.
    return [] if !['create', 'update'].include?(action_name)
    # Get the policy for this record
    fn = :"allowed_#{type}_for_#{action_name}"
    # No attributes allowed without a Policy allowing them
    return [] if _policy.nil? || !_policy.respond_to?(fn)
    # Retrieve allowed attributes (default to none allowed)
    _policy.send(fn) || []
  end

  def set_tenant
    Apartment::Tenant.switch!(params['identifier'])
  end

  def clear_tenant
    Apartment::Tenant.switch!
  end

  private

  def server_error(exception)
    puts exception.inspect
    render json: { errors: [ { detail: exception.to_s }] }, status: :internal_server_error
  end

  def api_exception(exception)
    errors = [{ title: exception.message }]
    render json: { errors: errors }, status: exception.status
  end

  def user_not_authorized(exception)
    current_user.errors.add('user', 'is not authorized to perform this action')
    render_exception_for current_user, status_code: :forbidden
  end

  def forbidden_exception(exception)
    render_exception_for exception.record, status_code: :forbidden
  end

  def invalid_exception(exception)
    render_exception_for exception.record, status_code: :unprocessable_entity
  end

  def statement_invalid_exception(exception)
    render json: { errors: [] }, status: :unprocessable_entity
  end

  def not_found_exception(exception)
    model = exception.model.underscore
    record = exception.model.singularize.classify.constantize.new
    record.errors.add(model, 'does not exist')
    render_exception_for record, status_code: :not_found
  end

  def prefab_schema_violation_exception(exception)
    errors = [{ title: 'Prefab schema violated' }]
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def render_exception_for(record, status_code:)
    render json: ErrorSerializer.new(record.errors).serialized_json, status: status_code || :unprocessable_entity
  end

  # JSON:API allows clients to specify an ID when creating resources. This
  # is not supported, so return 403 Forbidden per the specification.
  def forbid_client_generated_id
    if !request.params.fetch(:data, {}).fetch(:id, nil).nil?
      raise Polydesk::Errors::ClientGeneratedIdsForbidden.new
    end
  end

  # Return 403 if any restricted attributes are created or modified
  def forbid_disallowed_attributes(payload, record_klass)
    allowed = allowed_attributes(record_klass)
    attributes = payload.dig('data', 'attributes')
    return if !attributes.respond_to?(:keys) || attributes.keys.empty?
    restricted = payload['data']['attributes'].keys - allowed.map { |k| k.to_s }
    raise Polydesk::Errors::ForbiddenAttributes.new if restricted.any?
  end

  # Return 403 if any restricted relationships are created or modified
  def forbid_disallowed_relationships(payload, _policy)
    allowed = allowed_relationships(_policy)
    relationships = payload.dig('data', 'relationships')
    return if !relationships.respond_to?(:keys) || relationships.keys.empty?
    restricted = relationships.keys - allowed.map { |k| k.to_s }
    raise Polydesk::Errors::ForbiddenRelationships.new if restricted.any?
  end
end
