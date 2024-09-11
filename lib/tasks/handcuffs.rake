# frozen_string_literal: true

namespace :handcuffs do
  task :migrate, [:phase] => :environment do |task, args|
    phase = args.phase&.to_sym
    validate_phase_for_task!(phase: phase, task: task)

    patch_migrator!(phase)
    run_task('db:migrate')
  end

  task :rollback, [:phase] => :environment do |task, args|
    phase = args.phase&.to_sym
    validate_phase_for_task!(phase: phase, task: task)

    patch_migrator!(phase)
    run_task('db:rollback')
  end

  # Validates the provided phase is valid.
  def validate_phase_for_task!(phase:, task:)
    raise Handcuffs::RequiresPhaseArgumentError.new(task) unless phase.present?

    raise Handcuffs::NotConfiguredError.new unless Handcuffs.configured?
    return if Handcuffs.configuration.phases.include?(phase) || phase == :all

    raise Handcuffs::UnknownPhaseError.new(phase)
  end

  # Patches ActiveRecord::Migrator to account for phases.
  def patch_migrator!(phase)
    ActiveRecord::Migrator.extend(Handcuffs::PhaseAccessor)
    ActiveRecord::Migrator.prepend(Handcuffs::PendingFilter)
    ActiveRecord::Migrator.handcuffs_phase = phase
  end

  # Runs the specified rake task.
  def run_task(name)
    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks
    Rake::Task[name].reenable # in case you're going to invoke the same task second time.
    Rake::Task[name].invoke
  end
end
