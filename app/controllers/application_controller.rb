class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def pundit_user
    Polydesk::AuthContext.new(current_user, params[:identifier])
  end

  private
    def user_not_authorized
      render json: {errors: ['You are not authorized to perform this action']}, status: :forbidden
    end
end
