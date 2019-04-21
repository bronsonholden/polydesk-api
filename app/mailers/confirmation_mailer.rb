class ConfirmationMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  include ConfirmationUrlOptions

  def confirmation_instructions(record, token, opts={})
    opts[:config] = nil
    opts[:redirect_url] = nil
    super
  end
end
