require "handcuffs/errors/configuration_block_missing_error"

module Handcuffs
  mattr_accessor :config

  def self.configure
    raise ConfigurationBlockMissingError unless block_given?
    @@config = Configurator.new
    yield @@config
  end

  class Configurator
    attr_reader :phases
    attr_accessor :default_phase

    def initialize
      @phases = []
      @default_phase = nil
    end

    def phases=(phases)
      @phases = Phases.new(phases)
    end
  end
end

