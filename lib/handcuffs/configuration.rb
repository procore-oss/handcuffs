# frozen_string_literal: true

module Handcuffs
  # Encapsulates configuration for Handcuffs.
  class Configuration
    attr_accessor :default_phase
    attr_reader :phases

    # @param phases [Array<Symbol>] available phases for migrations
    # @param default_phase [Symbol] default phase that is used when a migration does not have specify a phase.
    def initialize(phases: [], default_phase: nil)
      @phases = Handcuffs::Phases.new(phases)
      @default_phase = default_phase
    end

    def phases=(phases)
      @phases = Handcuffs::Phases.new(phases)
    end

    def configured?
      phases.configured?
    end
  end
end
