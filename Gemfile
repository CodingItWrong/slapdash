source "https://rubygems.org"

ruby(File.read(".ruby-version").chomp)

gem "rails", "~> 7.1.3"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 6.4"
gem "devise"
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
