# frozen_string_literal: true

require 'handcuffs'
require 'logger'
require 'combustion'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Combustion.initialize!(
  :active_record,
  load_schema: false,
  database_migrate: false,
  database_reset: false
) do
  config.active_record.dump_schema_after_migration = false
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  # config.order = :random
  config.filter_run_when_matching :focus

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
end
