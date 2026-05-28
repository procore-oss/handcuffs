# frozen_string_literal: true

module Handcuffs
  # Railtie for Handcuffs.
  class Railtie < Rails::Railtie
    initializer 'handcuffs.extend_migration_dsl' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Migration.extend Handcuffs::Dsl
      end
    end

    rake_tasks { load 'tasks/handcuffs.rake' }
  end
end
