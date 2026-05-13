# frozen_string_literal: true

module Handcuffs
  # Allows ActiveRecord::Migrator to track the current phase.
  module PhaseTracker
    attr_accessor :handcuffs_phase
  end
end
