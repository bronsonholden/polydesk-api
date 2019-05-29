module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    def render_create_success
      render json: JSONAPI::Serializer.serialize(@resource), status: :ok
    end
  end
end
