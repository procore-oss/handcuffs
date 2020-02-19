# Ruby 2.7 doesn't support BigDecimal.new, which Rails 4 uses
if RUBY_VERSION < "2.7"
  appraise "rails-4" do
    gem "rails", "~> 4.2.8"
    gem 'pg', '~> 0.15'
  end
end

appraise "rails-5" do
  gem "rails", "~> 5.0.0.1"
  gem 'pg', '~> 0.18'
end

appraise "rails-5.1" do
  gem "rails", "~> 5.1.7"
  gem 'pg', '~> 0.18'
end

appraise "rails-5.2" do
  gem "rails", "~> 5.2.3"
end

# Rails >= 6 requires Ruby >= 2.5
if RUBY_VERSION >= "2.5"
  appraise "rails-6" do
    gem "rails", "~> 6.0.0"
  end
end
