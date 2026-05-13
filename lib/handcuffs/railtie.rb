# frozen_string_literal: true

module Handcuffs
  # Railtie for Handcuffs.
  class Railtie < Rails::Railtie
    rake_tasks { load 'tasks/handcuffs.rake' }
  end
end
