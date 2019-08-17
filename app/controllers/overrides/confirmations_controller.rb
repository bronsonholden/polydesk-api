module Overrides
  class ConfirmationsController < Devise::ConfirmationsController
    def new
      super
    end

    def create
      super
    end

    # GET /confirmations/:id
    def show
      p = confirmation_params
      @user = User.find_by_confirmation_token(p[:confirmation_token])
      raise Polydesk::Errors::InvalidConfirmationToken.new(User.new) if @user.nil?
      render json: ConfirmationSerializer.new(@user).serialized_json, status: :ok
    end

    # POST /confirmations/:id
    def confirm
      p = confirmation_params

      ActiveRecord::Base.transaction do
        token = p[:confirmation_token]
        @user = User.find_by_confirmation_token(token)
        @user.update!(p) if !@user.has_password?
        if !@user.confirm
          render json: ErrorSerializer.new(@user.errors).serialized_json, status: :unprocessable_entity
        end
      end
    end

    private

    def confirmation_params
      params.permit(:confirmation_token, :password, :password_confirmation)
    end
  end
end
