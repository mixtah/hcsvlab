# Your HTTP server, Apache/etc
role :web, 'alveo-qa.alveo.edu.au'
# This may be the same as your Web server
role :app, 'alveo-qa.alveo.edu.au'
# This is where Rails migrations will run
role :db,  'alveo-qa.alveo.edu.au', :primary => true

set :server_url, "http://alveo-qa.alveo.edu.au"