# frozen_string_literal: true

module Handcuffs
  class NotConfiguredError < StandardError
    include Error

    def initialize
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        You must configure Handcuffs in your Rails initializer.
        See README.md for details
      MESSAGE
    end
  end
end
