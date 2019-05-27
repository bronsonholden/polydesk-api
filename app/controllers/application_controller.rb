require 'polydesk/auth_context'

# TODO: For all POST requests that contain resource objects, need to check
# type and return 409 if it doesn't match with the collection resource type.
class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  include Polydesk

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_exception
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Polydesk::ApiExceptions::AccountIsDisabled, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::InvalidConfirmationToken, with: :invalid_confirmation_token_exception
  rescue_from Polydesk::ApiExceptions::NotVersionable, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::FolderException::NoThankYou, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::DocumentException::StorageLimitReached, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::UserException::NoAccountAccess, with: :forbidden_exception
  rescue_from Polydesk::ApiExceptions::ClientGeneratedIdsForbidden, with: :client_generated_ids_forbidden_exception

  def pundit_user
    Polydesk::AuthContext.new(current_account, params[:identifier])
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

  def allowed_attributes(record_klass)
    policy_restrictions(:attributes, record_klass)
  end

  def allowed_relationships(record_klass)
    policy_restrictions(:relationships, record_klass)
  end

  def sanitize_payload(payload, record_klass)
    forbid_client_generated_id(payload)
    forbid_disallowed_attributes(payload, record_klass)
    forbid_disallowed_relationships(payload, record_klass)
    payload
  end

  def policy_restrictions(type, record_klass)
    # Only relevant when creating or updating.
    return [] if !['create', 'update'].include?(action_name)
    # Get the policy for this record
    p = policy(record_klass)
    fn = :"allowed_#{type}_for_#{action_name}"
    # No attributes allowed without a Policy allowing them
    return [] if p.nil? || !p.respond_to?(fn)
    # Retrieve allowed attributes (default to none allowed)
    p.send(fn) || []
  end

  private

  def invalid_confirmation_token_exception(exception)
    render_exception_for exception.record, status_code: :not_found
  end

  def client_generated_ids_forbidden_exception(exception)
    errors = ActiveModel::Errors.new
    errors.add('client generated IDs', 'are forbidden')
    render_exception_for ({ errors: errors }), status_code: :forbidden
  end

  def user_not_authorized(exception)
    current_account.errors.add('user', 'is not authorized to perform this action')
    render_exception_for current_account, status_code: :forbidden
  end

  def forbidden_exception(exception)
    render_exception_for exception.record, status_code: :forbidden
  end

  def invalid_exception(exception)
    render_exception_for exception.record, status_code: :unprocessable_entity
  end

  def not_found_exception(exception)
    model = exception.model.underscore
    record = exception.model.singularize.classify.constantize.new
    record.errors.add(model, 'does not exist')
    render_exception_for record, status_code: :not_found
  end

  def render_exception_for(record, status_code:)
    render json: ErrorSerializer.new(record.errors).serialized_json, status: status_code || :unprocessable_entity
  end

  # JSON:API allows clients to specify an ID when creating resources. This
  # is not supported, so return 403 Forbidden per the specification.
  def forbid_client_generated_id(payload)
    if action_name == 'create' && payload['data'].key?(:id)
      raise Polydesk::ApiExceptions::ClientGeneratedIdsForbidden.new
    end
  end

  # Return 403 Forbidden if any restricted attributes or relationships are
  # created or modified.
  def forbid_disallowed_attributes(payload, record_klass)
    allowed = allowed_attributes(record_klass)
    attributes = payload.dig('data', 'attributes')
    return if !attributes.respond_to?(:keys) || attributes.keys.empty?
    restricted = payload['data']['attributes'].keys - allowed.map { |k| k.to_s }
    if restricted.any?
      raise Polydesk::ApiExceptions::ForbiddenAttributes.new
    end
  end

  def forbid_disallowed_relationships(payload, record_klass)
    allowed = allowed_relationships(record_klass)
    relationships = payload.dig('data', 'relationships')
    return if !relationships.respond_to?(:keys) || relationships.keys.empty?
    restricted = relationships.keys - allowed.map { |k| k.to_s }
    if restricted.any?
      raise Polydesk::ApiExceptions::ForbiddenRelationships.new
    end
  end
end
