# frozen_string_literal: true

module Handcuffs
  class UndeclaredPhaseError < StandardError
    attr_reader :found

    def initialize(found:)
      @found = found
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        found declarations for #{found.to_sentence}
        but only #{Handcuffs.configuration.phases} are allowed
      MESSAGE
    end
  end
end
