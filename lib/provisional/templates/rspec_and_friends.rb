rake 'rails:freeze:gems'

gem 'cucumber', :env => :test
gem 'rspec', :lib => false, :env => :test
gem 'rspec-rails', :lib => false, :env => :test
gem 'webrat', :env => :test

rake 'gems:install gems:unpack', :env => :test

generate :rspec
generate :cucumber
run 'cp config/environments/test.rb config/environments/cucumber.rb'

run 'rm -rf log/* test'
inside 'public' do
  run 'rm -f index.html favicon.ico robots.txt images/rails.png'
end

file '.gitignore', 'coverage'
file 'db/.gitignore', '*.sqlite3'
file 'log/.gitignore', '*'
file 'tmp/.gitignore', '*'
