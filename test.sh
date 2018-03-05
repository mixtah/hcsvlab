#!/bin/sh

RAILS_ENV=test
rake jetty:start a13g:start_pollers
apache-activemq-5.8.0/bin/activemq start
#rake jetty:start
bash rails_webrick.sh

