# frozen_string_literal: true

source 'https://rubygems.org'

gemspec path: '..'

gem 'activemodel', '~> 7.0.1'

group :development, :test do
  gem 'rake'
  gem 'rspec'
end

group :test do
  gem 'simplecov', require: false
end
