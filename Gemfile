source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.8.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'concurrent-ruby'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
  gem 'capistrano', '~> 3.14', '>= 3.14.1'
  gem 'capistrano-rails'
  gem 'capistrano-chruby'
  gem 'capistrano3-puma', '5.2.0'
  gem 'capistrano-sidekiq'
end

group :test, :docker_test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'shoulda-matchers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise', '~> 4.6', '>= 4.6.1'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'simple_form'
gem 'bootstrap_form', '4.3.0'
gem 'cocoon'

gem 'unicorn'
gem 'kaminari'
gem 'rack-cors'
gem 'phonelib', '~> 0.6.33'
gem 'rest-client'

# group :production, :preprod, :docker_test, :staging, :recette do
  #gem 'sentry-raven', '~> 2.9'
gem "sentry-ruby"
gem "sentry-rails"
# end

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'ransack', '~> 2.1', '>= 2.1.1'

gem 'active_storage_validations'
gem 'mini_magick'

gem 'activerecord-import'

gem 'savon', '~> 2.12.0'

gem 'wicked'
gem 'roo', '~> 2.8', '>= 2.8.2'
gem 'roo-xls'

gem 'redis', '~> 4.1', '>= 4.1.3'
gem 'redis-namespace', '~> 1.7'

gem 'chartkick'
gem 'groupdate'

gem 'rubocop-rails', require: false

gem 'rails-i18n'

gem 'whenever', require: false

gem 'workflow', '~> 2.0'
gem 'workflow-activerecord', '>= 4.1pre', '< 6.0'

gem 'dotenv-rails' #, groups: [:development, :test]

gem 'numbers_and_words'

group :production, :preprod, :staging, :recette do
  gem 'activerecord-oracle_enhanced-adapter'
  #    git: 'https://github.com/scicasoft/oracle-enhanced.git',
  #    branch: 'identifier_max_lenght_5.2.8'
  #gem 'elastic-apm'
  gem 'ruby-oci8'
end

group :production do
  gem 'dalli'
end

gem 'combine_pdf'

gem 'time_difference'

gem 'ruby-graphviz'

gem 'sidekiq', '6.5.9'

gem 'select_all-rails'

gem 'caxlsx'
gem 'caxlsx_rails'
