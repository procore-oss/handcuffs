class Handcuffs::PhaseFilter
  attr_reader :attempted_phase
  attr_reader :direction

  def initialize(attempted_phase, direction)
    @attempted_phase = attempted_phase
    @direction = direction
  end

  def filter(migration_proxies)
    migration_hashes = proxies_with_migrations(migration_proxies)
    check_for_undefined_phases!(migration_hashes)
    by_phase = migration_hashes.lazy.group_by { |mh| phase(mh[:migration]) }
    defined_phases = Handcuffs.config.phases
    if(attempted_phase == :all)
      all_phases_by_configuration_order(by_phase, defined_phases)
    else
      runnable_for_phase(by_phase, defined_phases)
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
  def runnable_for_phase(by_phase, defined_phases)
    if(direction == :up)
      check_order_up!(by_phase, defined_phases)
    else
      check_order_down!(by_phase, defined_phases)
    end
    Array(by_phase[attempted_phase]).map { |mh| mh[:proxy] }
  end

  def check_order_up!(by_phase, defined_phases)
    defined_phases.take_while { |defined_phase| defined_phase != attempted_phase }
      .detect { |defined_phase| by_phase.key?(defined_phase) }
      .tap do |defined_phase|
        raise HandcuffsPhaseOutOfOrderError.new(defined_phase, attempted_phase) if defined_phase
      end
  end

  def check_order_down!(by_phase, defined_phases)
    #There's no way to do this without some super hackery. If we run rake
    #handcuffs::rollback[:post_deploy] and the top of the list (in desc order)
    #in a pre_deploy, we don't know if that was run before or after the
    #last post_deploy because we can't count on the versions to give us the
    #execution order. Without storing the execution order in another table,
    #there's no way to implement this
  end

  def all_phases_by_configuration_order(by_phase, defined_phases)
    defined_phases.reduce([]) do |acc, phase|
      acc | by_phase[phase]
    end.map { |mh| mh[:proxy] }
  end

  def check_for_undefined_phases!(migration_hashes)
    unless Handcuffs.config.default_phase
      nil_migration_hashes = migration_hashes.select do |mh|
        mh[:migration].handcuffs_phase.nil?
      end
      if nil_migration_hashes.any?
        filenames = nil_migration_hashes.map { |mh| mh[:proxy].filename }
        raise HandcuffsPhaseUndefinedError.new(filenames)
      end
    end
  end

  def phase(migration)
    migration.handcuffs_phase || Handcuffs.config.default_phase
  end

end
