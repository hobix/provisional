# This template installs an environment very similar to Thoughtbot's Suspenders
# http://github.com/thoughtbot/suspenders

# TODO: this is missing some of their shoulda macros

rake 'rails:freeze:gems'

gem 'justinfrench-formtastic', :lib => 'formtastic', :source => 'http://gems.github.com', :version => '~> 0.2.1'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com', :version => '~> 2.3.11'
gem 'rack', :version => '>= 1.0.0'
gem 'RedCloth', :lib => 'redcloth', :version => '>= 4.2.2'
gem 'thoughtbot-clearance', :lib => 'clearance', :source => 'http://gems.github.com', :version => '>= 0.7.0'
gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com', :version => '>= 2.3.0'

gem 'jferris-mocha', :version => '0.9.5.0.1241126838', :source => 'http://gems.github.com', :lib => 'mocha', :env => 'test'
gem 'jtrupiano-timecop', :version => '0.2.1', :source => 'http://gems.github.com', :lib => 'timecop', :env => 'test'
gem 'nokogiri', :version => '1.3.2', :lib => false, :env => 'test'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com', :version => '>= 1.2.2', :env => 'test'
gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => 'http://gems.github.com', :version => '>= 2.10.2', :env => 'test'
gem 'webrat', :version => '0.4.4', :env => 'test'

rake 'gems:install gems:unpack', :env => 'test'

plugin 'hoptoad_notifier', :git => 'git://github.com/thoughtbot/hoptoad_notifier.git'
plugin 'limerick_rake', :git => 'git://github.com/thoughtbot/limerick_rake.git'
plugin 'validation_reflection', :git => 'git://github.com/redinger/validation_reflection.git'

generate :cucumber
generate :clearance
generate :clearance_features
generate :clearance_views

run 'rm -rf public/index.html log/* test/fixtures'

file '.gitignore', %q[
log/*
tmp/**/*
db/schema.rb
db/*.sqlite3
public/system
*.DS_Store
coverage/*
*.swp

!.keep
]

file 'test/test_helper.rb', %q[
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'action_view/test_case'

Mocha::Configuration.warn_when(:stubbing_non_existent_method)
Mocha::Configuration.warn_when(:stubbing_non_public_method)

class ActiveSupport::TestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

end

class ActionView::TestCase
  class TestController < ActionController::Base
    attr_accessor :request, :response, :params

    def initialize
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new

      # TestCase doesn't have context of a current url so cheat a bit
      @params = {}
      send(:initialize_current_url)
    end
  end
end
]

