if RUBY_VERSION =~ /1.9/
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
end

source 'http://ruby.taobao.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
gem 'mysql2'

# Use bcrypt to encrypt passcode
gem 'bcrypt-ruby'

# generates fake data
gem 'faker', '1.2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Bootstrap to beautify web
gem 'bootstrap-sass'

# use for page-split
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'


# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'cancancan'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :debugging do
  gem 'debugger', '1.6.8', :platforms => :ruby_19
  gem 'pry', :platforms => :ruby_19
  gem 'byebug' if RUBY_VERSION =~ /^2/ #, :platforms => :ruby_20
  gem 'pry-byebug' if RUBY_VERSION =~ /^2/ #, :platforms => :ruby_20
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development
 
