module SessionHelper
  def set_request_headers(resp)
    { 'ACCEPT' => "application/json",
      'Content-Type' => "application/json",
      'access-token' => resp['access-token'],
      'token-type' => resp['token-type'],
      'client' => resp['client'],
      'expiry' => resp['expiry'],
      'uid' => resp['uid'] }
  end

  def account_login(identifier, email, password)
    post '/auth/sign_in', params: { email: email, password: password }
    return set_request_headers(response.headers)
  end

  def rspec_session(account_user=nil)
    if account_user
      account_login('rspec', account_user.user.email, 'password')
    else
      account_login('rspec', 'rspec@polydesk.io', 'password')
    end
  end
end
