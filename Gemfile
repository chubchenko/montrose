# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "coveralls"
  gem "yard"

  unless ENV["CI"]
    gem "guard"
    gem "guard-minitest"
    gem "guard-rubocop"
    gem "pry-byebug"
  end
end
