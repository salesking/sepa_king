# frozen_string_literal: true

source 'https://rubygems.org'

gemspec path: '..'

gem 'activemodel', '~> 8.1.0'

group :development, :test do
  gem 'rake'
  gem 'rspec'
end

group :test do
  gem 'simplecov', require: false
end
