# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

# Specify your gem's dependencies in dry-auto_inject.gemspec
gemspec

gem "dry-core", github: "dry-rb/dry-core", branch: "main"

group :tools do
  gem "byebug", platforms: :mri
  gem "pry"
end
