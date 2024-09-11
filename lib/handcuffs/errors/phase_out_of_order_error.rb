# frozen_string_literal: true

module Handcuffs
  class PhaseOutOfOrderError < StandardError
    include Error

    attr_reader :not_run_phase, :attempted_phase

    def initialize(not_run_phase:, attempted_phase:)
      @not_run_phase = not_run_phase
      @attempted_phase = attempted_phase
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        You tried to run #{attempted_phase}, but #{not_run_phase} has not been run
      MESSAGE
    end
  end
end
