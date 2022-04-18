# Cookbook Name:: woodenbits
# Recipe:: dev-salesforce

if node[:hostname].start_with?('opoplavsky-')
  # required for generating jwt tokens for admin-api
  package 'libcrypt-jwt-perl'

  # for listing all files in a project
  package 'tree'

  package 'nodejs'
  package 'jq' # json pretty print

  package 'insomnia'

  package 'docker-ce'

  package 'redis-tools'
  package 'postgresql-client'

  #package 'virtualbox'

  # has to be installed by hand, go to https://slack.com/downloads/linux
  #package 'slack-desktop'

  # has to be installed by hand with 'curl https://cli-assets.heroku.com/install-ubuntu.sh | sh'
  #package 'heroku'
end
