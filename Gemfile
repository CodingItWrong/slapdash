source 'https://rubygems.org'

ruby '3.1.0'

gem 'rails', '~> 7.0.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.6'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'devise'
gem 'friendly_id'
gem 'pundit'
gem 'bootstrap', '~> 4.6.0', '< 5'
gem 'kramdown'
gem 'nokogiri', '>= 1.11.0.rc4'

group :development do
  gem 'dotenv-rails'
  gem 'listen', '~> 3.7'
end

group :development, :test do
  gem 'coderay'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
end

group :production do
  gem 'rack-attack'
end
