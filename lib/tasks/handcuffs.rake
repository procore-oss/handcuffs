# frozen_string_literal: true

namespace :handcuffs do
  task :migrate, [:phase] => :environment do |_t, args|
    phase = setup(args, 'handcuffs:migrate')
    patch_migrator!(phase)
    run_task('db:migrate')
  end

  task :rollback, [:phase] => :environment do |_t, args|
    phase = setup(args, 'handcuffs:rollback')
    patch_migrator!(phase)
    run_task('db:rollback')
  end

  task phase_order: :environment do
    raise HandcuffsNotConfiguredError unless Handcuffs.config

    puts 'Configured Handcuffs phases, in order, are:'
    phases = Handcuffs.config.phases || return

    phases.in_order.each_with_index do |phase, idx|
      puts (idx + 1).to_s.rjust(3) + ". #{phase}, requires: #{phases.prereqs(phase).join(', ').presence || '(nothing)'}"
    end
  end

  def setup(args, task)
    phase = args.phase.presence&.to_sym

    raise RequiresPhaseArgumentError.new(task) unless phase.present?

    raise HandcuffsNotConfiguredError unless Handcuffs.config

    return phase if Handcuffs.config.phases.include?(phase) || phase == :all

    raise HandcuffsUnknownPhaseError.new(phase, Handcuffs.config.phases)
  end

  def patch_migrator!(phase)
    ActiveRecord::Migrator.prepend(Handcuffs::PendingFilterExt)
    ActiveRecord::Migrator.handcuffs_phase = phase
  end

  def run_task(name)
    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks
    Rake::Task[name].reenable # in case you're going to invoke the same task second time.
    Rake::Task[name].invoke
  end
end
