module Overrides
  class ConfirmationsController < Devise::ConfirmationsController
    def new
      super
    end

    def create
      super
    end

    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if !@resource.errors.empty?
        render json: ErrorSerializer.new(@resource.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end
end
