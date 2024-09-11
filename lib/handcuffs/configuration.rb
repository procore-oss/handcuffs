# frozen_string_literal: true

module Handcuffs
  # Encapsulates configurated options for Handcuffs.
  class Configuration
    attr_accessor :phases, :default_phase

    # @param phases [Array<Symbol>] available phases for migrations
    # @param default_phase [Symbol] default phase that is used when a migration does not have specify a phase.
    def initialize(phases: [], default_phase: nil)
      @phases = phases.map(&:to_sym)
      @default_phase = default_phase
    end

    # Returns true if phases have been configured.
    def configured?
      phases.any?
    end
  end
end
