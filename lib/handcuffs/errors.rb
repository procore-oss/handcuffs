
  class HandcuffsError < StandardError; end

  class RequiresPhaseArgumentError < HandcuffsError
    def initialize(task)
      msg = <<-MESSAGE
        rake #{task} requires a phase argument.
        For example: #{task}[pre_deploy]
      MESSAGE
      super(msg)
    end
  end

  class HandcuffsNotConfiguredError < HandcuffsError
    def initialize
      msg = <<-MESSAGE
        You must configure Handcuffs in your Rails initializer.
        see README.md for details
      MESSAGE
      super(msg)
    end
  end

  class HandcuffsUnknownPhaseError < HandcuffsError
    def initialize(phase, phases)
      msg = <<-MESSAGE
        Unknown phase #{phase.to_s}
        Handcuffs is configured to allow #{phases.to_sentence}
      MESSAGE
      super msg
    end
  end

  class HandcuffsPhaseUndeclaredError < HandcuffsError
    def initialize(found_phases, allowed_phases)
      msg = <<-MESSAGE
        found declarations for #{found_phases.to_sentence}
        but only #{allowed_phases.to_sentence} are allowed
      MESSAGE
      super msg
    end
  end

  class HandcuffsPhaseOutOfOrderError < HandcuffsError
    def initialize(not_run_phase, attempted_phase)
      msg = <<-MESSAGE
        Your tried to run #{attempted_phase.to_s}, but #{not_run_phase.to_s} has not been run
      MESSAGE
      super msg
    end
  end

  class HandcuffsPhaseUndefinedError < HandcuffsError
    def initialize(undefined_phases)
      msg = <<-MESSAGE
        The following migrations do not have a phase defined
      #{undefined_phases.to_sentence}
      MESSAGE
      super msg
    end
  end
