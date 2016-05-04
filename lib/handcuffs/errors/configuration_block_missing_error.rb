require "handcuffs/error"

module Handcuffs
  class ConfigurationBlockMissingError < ArgumentError
    include Handcuffs::Error

    def to_s
      "block argument required"
    end
  end
end
