# frozen_string_literal: true

module Handcuffs
  class UnknownPhaseError < StandardError
    include Error

    attr_reader :phase

    def initialize(phase)
      @phase = phase
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        Unknown phase #{phase}
        Handcuffs is configured to allow #{Handcuffs.configuration.phases.to_sentence}
      MESSAGE
    end
  end
end
