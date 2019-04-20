class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  include Polydesk

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_exception
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Polydesk::ApiExceptions::AccountIsDisabled, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::NotVersionableException, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::FolderException::NoThankYou, with: :invalid_exception
  rescue_from Polydesk::ApiExceptions::DocumentException::StorageLimitReached, with: :invalid_exception

  def pundit_user
    Polydesk::AuthContext.new(current_user, params[:identifier])
  end

  # GET /
  def show
    render json: {}, status: :ok
  end

  def current_page
    (params[:page] || PaginationGenerator::DEFAULT_PAGE).to_i
  end

  def per_page
    (params[:limit] || PaginationGenerator::DEFAULT_PER_PAGE).to_i
  end

  private
    def user_not_authorized(exception)
      current_user.errors.add('user', 'is not authorized to perform this action')
      render_exception_for current_user, status_code: :forbidden
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
