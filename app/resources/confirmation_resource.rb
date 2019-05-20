class ConfirmationSerializer
  def initialize(user)
    @hash = {
      data: {
        id: user.confirmation_token,
        attributes: {
          user_id: user.id,
          email: user.email,
          confirmation_sent_at: user.confirmation_sent_at,
          password_required: !user.has_password?
        }
      }
    }
  end

  def serialized_json
    @hash.to_json
  end
end
