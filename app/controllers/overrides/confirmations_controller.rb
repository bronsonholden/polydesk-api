module Overrides
  class ConfirmationsController < Devise::ConfirmationsController
    def new
      super
    end

    def create
      super
    end

    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    end
  end
end
