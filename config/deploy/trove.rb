# Your HTTP server, Apache/etc
role :web, 'alveo.sol1.net'
# This may be the same as your Web server
role :app, 'alveo.sol1.net'
# This is where Rails migrations will run
role :db,  'alveo.sol1.net', :primary => true

set :server_url, "https://alveo.sol1.net/"