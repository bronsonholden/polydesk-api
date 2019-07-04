module ConfirmationUrlOptions
  def default_url_options
    { host: host, port: port }
  end

  private

  def host
    if Rails.env.test? || Rails.application.config.polydesk_headless
      Rails.application.routes.default_url_options[:host]
    else
      Rails.application.config.polydesk_www
    end
  end

  def port
    host.partition(':').last
  end
end
