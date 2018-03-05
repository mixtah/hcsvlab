# Your HTTP server, Apache/etc
role :web, 'staging.alveo.edu.au'
# This may be the same as your Web server
role :app, 'staging.alveo.edu.au'
# This is where Rails migrations will run
role :db,  'staging.alveo.edu.au', :primary => true

set :server_url, "https://staging.alveo.edu.au"
