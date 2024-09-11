# frozen_string_literal: true

module Handcuffs
  class MigrationMissingPhaseError < StandardError
    include Error

    attr_reader :migrations

    def initialize(migrations)
      @migrations = migrations
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        The following migrations do not have a phase defined
        #{migrations.to_sentence}
      MESSAGE
    end
  end
end
