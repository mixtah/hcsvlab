# https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-(and-RSpec)

# require_relative 'support/controller_macros'
# or require_relative '../controller_macros' if write in `spec/support/devise.rb`

require_relative 'controller_macros'

RSpec.configure do |config|
  # For Devise >= 4.1.1
  # config.include Devise::Test::ControllerHelpers, :type => :controller

  # Use the following instead if you are on Devise <= 4.1.0
  config.include Devise::TestHelpers, :type => :controller

  config.extend ControllerMacros, :type => :controller
end