# frozen_string_literal: true

namespace :handcuffs do
  task :migrate, [:phase] => :environment do |task, args|
    phase = args.phase&.to_sym
    validate_phase_for_task!(phase:, task:)

    patch_migrator!(phase)
    run_task('db:migrate')
  end

  task :rollback, [:phase] => :environment do |_t, args|
    phase = args.phase&.to_sym
    validate_phase_for_task!(phase:, task:)

    patch_migrator!(phase)
    run_task('db:rollback')
  end

  task phase_order: :environment do
    raise Handcuffs::NotConfiguredError unless Handcuffs.configured?

    puts 'Configured Handcuffs phases, in order, are:'
    phases = Handcuffs.configuration.phases || return

    phases.in_order.each_with_index do |phase, idx|
      puts (idx + 1).to_s.rjust(3) + ". #{phase}, requires: #{phases.prereqs(phase).join(', ').presence || '(nothing)'}"
    end
  end

  # Validates the provided phase is valid.
  def validate_phase_for_task!(phase:, task:)
    raise Handcuffs::RequiresPhaseArgumentError.new(task) unless phase.present?

    raise Handcuffs::NotConfiguredError.new unless Handcuffs.configured?
    return if Handcuffs.configuration.phases.include?(phase) || phase == :all

    raise Handcuffs::UnknownPhaseError.new(phase)
  end

  def patch_migrator!(phase)
    ActiveRecord::Migrator.extend(Handcuffs::PhaseTracker)
    ActiveRecord::Migrator.prepend(Handcuffs::PendingFilter)

    ActiveRecord::Migrator.handcuffs_phase = phase
  end

  def run_task(name)
    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks
    Rake::Task[name].reenable # in case you're going to invoke the same task second time.
    Rake::Task[name].invoke
  end
end
