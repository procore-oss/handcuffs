module Handcuffs
  # Encapsulates the logic for filtering migrations by phase.
  class PhaseFilter
    attr_reader :attempted_phase, :direction

    # @param attempted_phase [Symbol] The phase to filter by
    # @param direction [Symbol] The migration direction
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
      migrations_by_phase = migration_hashes.lazy.group_by { |mh| phase_for_migration(mh[:migration]) }

      if attempting_to_run_all?
        all_phases_by_configuration_order(migrations_by_phase, defined_phases)
      else
        runnable_for_phase(migrations_by_phase, defined_phases)
      end
    end

    private

    def up?
      direction == :up
    end

    def attempting_to_run_all?
      attempted_phase == :all
    end

    def defined_phases
      Handcuffs.configuration.phases
    end

    def proxies_with_migrations(migration_proxies)
      migration_proxies.map do |proxy|
        {
          proxy: proxy,
          migration: proxy.name.constantize
        }
      end
    end

    def runnable_for_phase(migrations_by_phase, defined_phases)
      if up?
        check_order_up!(migrations_by_phase, defined_phases)
      else
        check_order_down!(migrations_by_phase, defined_phases)
      end

      Array(migrations_by_phase[attempted_phase]).map { |mh| mh[:proxy] }
    end

    def check_order_up!(migrations_by_phase, defined_phases)
      defined_phases.take_while { |defined_phase| defined_phase != attempted_phase }.
        detect { |defined_phase| migrations_by_phase.key?(defined_phase) }.
        tap do |defined_phase|
          if defined_phase
            raise Handcuffs::PhaseOutOfOrderError.new(
              not_run_phase: defined_phase,
              attempted_phase: attempted_phase
            )
          end
        end
    end

    # There's no way to do this without some super hackery. If we run rake
    # handcuffs::rollback[:post_restart] and the top of the list (in desc order)
    # in a pre_restart, we don't know if that was run before or after the
    # last post_restart because we can't count on the versions to give us the
    # execution order. Without storing the execution order in another table,
    # there's no way to implement this
    def check_order_down!(by_phase, defined_phases)
      # no-op
    end

    def all_phases_by_configuration_order(by_phase, defined_phases)
      defined_phases.reduce([]) { |ordered_phases, phase| ordered_phases.concat(Array(by_phase[phase])) }.
        map { |migration| migration[:proxy] }
    end

    # Raises an error if any migrations do not have a phase defined, and a default phase is not configured.
    def check_for_undefined_phases!(migration_hashes)
      return if Handcuffs.configuration.default_phase

      migrations_without_phases = migration_hashes.filter_map do |migration_hash|
        next unless migration_hash[:migration].handcuffs_phase.nil?

        migration_hash[:proxy].filename
      end

      return unless migrations_without_phases.any?

      raise Handcuffs::MigrationMissingPhaseError.new(migrations_without_phases)
    end

    def check_for_undeclared_phases!(migration_hashes)
      unknown_phases =
        migration_hashes.
          lazy.
          map { |mh| mh[:migration].handcuffs_phase }.
          reject { |phase| phase.in?(Handcuffs.configuration.phases) }.
          compact.
          to_a

      return unless unknown_phases.any?

      raise Handcuffs::PhaseUndeclaredError.new(found: unknown_phases)
    end

    def phase_for_migration(migration)
      migration.handcuffs_phase || Handcuffs.configuration.default_phase
    end
  end
end
