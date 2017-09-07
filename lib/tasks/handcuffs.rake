require 'fileutils'

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

  namespace :migrate_log do
    task :up, [:filename] => :environment do |t,args|
      raise HandcuffsLogFilenameRequired.new unless args.filename
      Handcuffs::LogMigrator.new(args.filename, :up).migrate
    end

    task :down, [:filename] => :environment do |t,args|
      raise HandcuffsLogFilenameRequired.new unless args.filename
      Handcuffs::LogMigrator.new(args.filename, :down).migrate
    end
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
    if(ENV['HANDCUFFS_LOG'])
      ActiveRecord::Migration.prepend(Handcuffs::Logger)
    end
  end

  def run_task(name)
    if ENV['HANDCUFFS_LOG']
      FileUtils.touch(ENV['HANDCUFFS_LOG']) #ensure we can write so we're not surprised my permission errors
    end
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
