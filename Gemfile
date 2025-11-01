source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 8.1.1"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 7.1"
gem "devise", git: "https://github.com/heartcombo/devise.git", branch: "main" # https://github.com/heartcombo/devise/issues/5705#issuecomment-2496064620
gem "friendly_id"
gem "pundit"
gem "kramdown"
gem "nokogiri"

# frontend
gem "sprockets-rails"
gem "importmap-rails"
gem "cssbundling-rails", "~> 1.4"
gem "turbo-rails"
gem "stimulus-rails"

group :development do
  gem "dotenv-rails"
  gem "listen", "~> 3.9"
end

group :development, :test do
  gem "coderay"
  gem "debug", ">= 1.0.0"
  gem "rspec-rails"
  gem "standard"
end

group :test do
  gem "capybara"
  gem "factory_bot_rails"
  gem "rspec_junit_formatter"
end

group :production do
  gem "rack-attack"
end
