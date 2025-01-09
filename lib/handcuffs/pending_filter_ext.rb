# frozen_string_literal: true

module Handcuffs
  # PendingFilter is prepended to ActiveRecord::Migrator in the rake tasks
  # in order to check the current phase before it is run
  module PendingFilterExt
    def runnable
      attempted_phase = self.class.handcuffs_phase
      if @direction == :up
        Handcuffs::PhaseFilter.new(attempted_phase, @direction).filter(super)
      else
        phase_migrations = Handcuffs::PhaseFilter.new(attempted_phase, @direction).filter(migrations)
        runnable = phase_migrations[start..finish]
        runnable.pop if target
        runnable.find_all { |m| ran?(m) }
      end
    end
  end
end
