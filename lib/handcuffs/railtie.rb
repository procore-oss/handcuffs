# frozen_string_literal: true

module Handcuffs
  class Railtie < Rails::Railtie
    rake_tasks { load 'tasks/handcuffs.rake' }
  end
end
