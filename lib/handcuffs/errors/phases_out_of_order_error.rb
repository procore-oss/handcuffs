# frozen_string_literal: true

module Handcuffs
  class PhasesOutOfOrderError < StandardError
    include Error

    attr_reader :prerequisite_phase, :attempted_phase

    def initialize(prerequisite_phase:, attempted_phase:)
      @prerequisite_phase = prerequisite_phase
      @attempted_phase = attempted_phase
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        You tried to run #{attempted_phase}, but #{prerequisite_phase} has not been run
      MESSAGE
    end
  end
end
