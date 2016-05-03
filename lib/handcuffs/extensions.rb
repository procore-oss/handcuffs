module Handcuffs
  module Extensions

    attr_reader :handcuffs_phase

    def phase(phase)
      @handcuffs_phase = phase
    end

  end
end

