#!/bin/sh

RAILS_ENV=development
apache-activemq-5.8.0/bin/activemq start
rake jetty:start a13g:start_pollers
rake jetty:start
#bash rails_puma.sh
rails s

