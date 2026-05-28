# frozen_string_literal: true

module Handcuffs
  module Dsl
    attr_accessor :handcuffs_phase

    # Sets the desired phase for the migration.
    # @param phase [Symbol, String] the phase to set for the migration
    def phase(phase)
      @handcuffs_phase = phase.to_sym
    end
  end
end
