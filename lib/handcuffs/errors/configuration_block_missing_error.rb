# frozen_string_literal: true

module Handcuffs
  class ConfigurationBlockMissingError < ArgumentError
    include Error

    def initialize
      super('block argument required')
    end
  end
end
