# frozen_string_literal: true

module Handcuffs
  class RequiresPhaseArgumentError < StandardError
    include Error

    attr_reader :task

    def initialize(task)
      @task = task
      super(build_message)
    end

    private

    def build_message
      @_build_message ||= <<-MESSAGE
        rake #{task} requires a phase argument.
        For example: #{task}[pre_restart]
      MESSAGE
    end
  end
end
