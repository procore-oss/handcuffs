# frozen_string_literal: true

require_relative 'phase_filter'

module Handcuffs
  module PendingFilter
    # Returns an array of runnable migrations based on the current phase and direction.
    #
    # @return [Array<ActiveRecord::Migration>]
    def runnable
      attempted_phase = self.class.handcuffs_phase

      if up?
        Handcuffs::PhaseFilter.new(
          attempted_phase: attempted_phase,
          direction: @direction
        ).filter(super)
      else
        phase_migrations = Handcuffs::PhaseFilter.new(
          attempted_phase: attempted_phase,
          direction: @direction
        ).filter(migrations)

        runnable = phase_migrations[start..finish]
        runnable.pop if target
        runnable.find_all { |migration| ran?(migration) }
      end
    end
  end
end
