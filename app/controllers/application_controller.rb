class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def pundit_user
    Polydesk::AuthContext.new(current_user, params[:identifier])
  end

  private
    def user_not_authorized
      render json: ErrorSerializer.new({ user: [ 'is not authorized to perform this action' ] }).serialized_json, status: :forbidden
    end
end
