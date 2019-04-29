module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = User.find_by_email!('rspec@polydesk.io')
      sign_in user
    end
  end
end
