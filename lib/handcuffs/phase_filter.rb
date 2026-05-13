# frozen_string_literal: true

module Handcuffs
  # Filters migrations by phase.
  class PhaseFilter
    attr_reader :attempted_phase, :direction

    def initialize(attempted_phase:, direction:)
      @attempted_phase = attempted_phase
      @direction = direction
    end

    # Returns migrations that should be run based on the current phase and direction.
    #
    # @param migration_proxies [Array<ActiveRecord::MigrationProxy>]
    def filter(migration_proxies)
      migration_hashes = proxies_with_migrations(migration_proxies)
      check_for_undefined_phases!(migration_hashes)
      check_for_undeclared_phases!(migration_hashes)
      migrations_by_phase = migration_hashes.lazy.group_by { |mh| phase(mh[:migration]) }

      if attempting_to_run_all?
        all_phases_by_configuration_order(migrations_by_phase, defined_phases)
      else
        runnable_for_phase(migrations_by_phase, defined_phases)
      end
    end

    def proxies_with_migrations(migration_proxies)
      migration_proxies.map do |proxy|
        require(proxy.filename)
        {
          proxy: proxy,
          migration: Kernel.const_get("::#{proxy.name}")
        }
      end
    end

    private

    def defined_phases
      @_defined_phases ||= Handcuffs.configuration.phases
    end

    def attempting_to_run_all?
      attempted_phase == :all
    end

    def runnable_for_phase(by_phase, defined_phases)
      if direction == :up
        check_order_up!(by_phase, defined_phases)
      else
        check_order_down!(by_phase, defined_phases)
      end
      Array(by_phase[attempted_phase]).map { |mh| mh[:proxy] }
    end

    def check_order_up!(by_phase, defined_phases)
      defined_phases.prereqs(attempted_phase).
        detect { |defined_phase| by_phase.key?(defined_phase) }.
        tap do |defined_phase|
          if defined_phase
            raise Handcuffs::PhasesOutOfOrderError.new(
              not_run_phase: defined_phase,
              attempted_phase: attempted_phase
            )
          end
        end
    end

    def check_order_down!(by_phase, defined_phases)
      # There's no way to do this without some super hackery. If we run rake
      # handcuffs::rollback[:post_restart] and the top of the list (in desc order)
      # in a pre_restart, we don't know if that was run before or after the
      # last post_restart because we can't count on the versions to give us the
      # execution order. Without storing the execution order in another table,
      # there's no way to implement this
    end

    def all_phases_by_configuration_order(by_phase, defined_phases)
      defined_phases.in_order.reduce([]) do |acc, phase|
        acc | Array(by_phase[phase])
      end.map { |mh| mh[:proxy] }
    end

    def check_for_undefined_phases!(migration_hashes)
      return if Handcuffs.configuration.default_phase

      nil_migration_hashes = migration_hashes.select do |mh|
        mh[:migration].handcuffs_phase.nil?
      end
      return unless nil_migration_hashes.any?

      filenames = nil_migration_hashes.map { |mh| mh[:proxy].filename }
      raise Handcuffs::PhaseUndefinedError.new(filenames)
    end

    def check_for_undeclared_phases!(migration_hashes)
      unknown_phases = migration_hashes.
                         lazy.
                         map { |mh| mh[:migration].handcuffs_phase }.
                         reject(&:nil?).
                         select { |phase| !phase.in?(Handcuffs.configuration.phases) }.to_a
      return unless unknown_phases.any?

      raise Handcuffs::UndeclaredPhaseError.new(unknown_phases, Handcuffs.configuration.phases)
    end

    def phase(migration)
      migration.handcuffs_phase || Handcuffs.configuration.default_phase
    end
  end
end
