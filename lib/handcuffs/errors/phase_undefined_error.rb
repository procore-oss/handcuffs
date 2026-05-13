# frozen_string_literal: true

require_relative '../error'

module Handcuffs
  class PhaseUndefinedError < StandardError
    include Error

    attr_reader :undefined_phases

    def initialize(undefined_phases)
      @undefined_phases = undefined_phases

      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        The following migrations do not have a phase defined
        #{undefined_phases.to_sentence}
      MESSAGE
    end
  end
end
