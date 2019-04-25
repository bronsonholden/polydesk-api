module Overrides
  class ConfirmationsController < Devise::ConfirmationsController
    def new
      super
    end

    def create
      super
    end

    def select_password
      p = confirmation_params

      ActiveRecord::Base.transaction do
        token = p[:confirmation_token]
        @user = User.find_by_confirmation_token(token)
        @user.update!(p) if !@user.has_password?
        if !@user.confirm
          render json: ErrorSerializer.new(@user.errors).serialized_json, status: :unprocessable_entity
        else
          @user.link_account(p)
        end
      end
    end

    private
      def confirmation_params
        params.permit(:confirmation_token, :password, :password_confirmation)
      end
  end
end
