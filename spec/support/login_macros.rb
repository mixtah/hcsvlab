module LoginMacros
  def set_user_session(user)
    session[:user_id] = user.id
  end

  # sign in users in request specs
  # https://makandracards.com/makandra/37161-rspec-devise-how-to-sign-in-users-in-request-specs

  include Warden::Test::Helpers

  def request_sign_in(resource_or_scope, resource = nil)
    resource ||= resource_or_scope
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    login_as(resource, scope: scope)
  end

  def request_sign_out(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    logout(scope)
  end
end
