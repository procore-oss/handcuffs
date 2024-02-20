namespace :handcuffs do
  task :migrate, [:phase] => :environment do |t,args|
    phase = setup(args, 'handcuffs:migrate')
    patch_migrator!(phase)
    run_task('db:migrate')
  end

  task :rollback, [:phase] => :environment do |t,args|
    phase = setup(args, 'handcuffs:rollback')
    patch_migrator!(phase)
    run_task('db:rollback')
  end

  def setup(args, task)
    phase = args.phase
    raise RequiresPhaseArgumentError.new(task) unless phase.present?
    raise HandcuffsNotConfiguredError.new unless Handcuffs.config
    phase = phase.to_sym
    unless Handcuffs.config.phases.include?(phase) || phase == :all
      raise HandcuffsUnknownPhaseError.new(phase, Handcuffs.config.phases)
    end
    phase
  end

  def patch_migrator!(phase)
    ActiveRecord::Migrator.prepend(PendingFilter)
    ActiveRecord::Migrator.extend(PhaseAccessor)
    ActiveRecord::Migrator.handcuffs_phase = phase
  end

  def run_task(name)
    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks 
    Rake::Task[name].reenable # in case you're going to invoke the same task second time.
    Rake::Task[name].invoke
  end

  module PendingFilter
    def runnable
      attempted_phase = self.class.handcuffs_phase
      if(@direction == :up)
        Handcuffs::PhaseFilter.new(attempted_phase, @direction).filter(super)
      else
        phase_migrations = Handcuffs::PhaseFilter.new(attempted_phase, @direction).filter(migrations)
        runnable = phase_migrations[start..finish]
        runnable.pop if target
        runnable.find_all { |m| ran?(m) }
      end
    end
  end

  module PhaseAccessor
    attr_accessor :handcuffs_phase
  end

end
