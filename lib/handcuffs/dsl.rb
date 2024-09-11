module Handcuffs
  module Dsl
    attr_reader :handcuffs_phase

    # Sets the desired phase for a migration.
    # @param phase [Symbol]
    def phase(phase)
      @handcuffs_phase = phase
    end
  end
end

