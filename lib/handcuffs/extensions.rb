# frozen_string_literal: true

module Handcuffs
  # Extended by ActiveRecord::Migrator in order to track the current phase
  module Extensions
    attr_accessor :handcuffs_phase

    def phase(phase)
      @handcuffs_phase = phase
    end
  end
end
