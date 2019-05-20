require 'polydesk/auth_context'

class ApplicationController < ActionController::API
  include JSONAPI::ActsAsResourceController
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

  def context
    { user: pundit_user }
  end

  def pundit_user
    Polydesk::AuthContext.new(current_user, params[:identifier])
  end

  # GET /
  def show
    render json: {}, status: :ok
  end

  def render_authenticate_error
    user = User.new
    user.errors.add('user', 'must be logged in')
    render json: ErrorSerializer.new(user.errors).serialized_json, status: :unauthorized
  end

  protected
    def current_page
      (params[:page] || PaginationGenerator::DEFAULT_PAGE).to_i
    end

    def per_page
      (params[:limit] || PaginationGenerator::DEFAULT_PER_PAGE).to_i
    end

    # TODO: Better implementation of this. Some controllers need identifier
    # to retrieve an Account.
    def permitted_params
      params.except(:controller, :action, :identifier)
    end

  private
    def invalid_confirmation_token_exception(exception)
      render_exception_for exception.record, status_code: :not_found
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

    def not_found_exception(exception)
      model = exception.model.underscore
      record = exception.model.singularize.classify.constantize.new
      record.errors.add(model, 'does not exist')
      render_exception_for record, status_code: :not_found
    end

    def render_exception_for(record, status_code:)
      render json: ErrorSerializer.new(record.errors).serialized_json, status: status_code || :unprocessable_entity
    end
end
