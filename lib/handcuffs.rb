# frozen_string_literal: true

require 'rails'
require 'active_record'

require_relative 'handcuffs/configuration'
require_relative 'handcuffs/error'
require_relative 'handcuffs/dsl'
require_relative 'handcuffs/pending_filter'
require_relative 'handcuffs/phase_accessor'
require_relative 'handcuffs/phase_filter'
require_relative 'handcuffs/version'
require_relative 'handcuffs/railtie'

# Load error classes
Dir[File.join(File.dirname(__FILE__), 'handcuffs', 'errors', '*.rb')].each { |file| require file }

# nodoc:
module Handcuffs
  class << self
    # @return [Configuration]
    def configuration
      @_configuration ||= Configuration.new
    end

    def configure
      return yield(configuration) if block_given?

      raise ArgumentError, 'block argument required when using Handcuffs.configure'
    end

    def reset_configuration!
      @_configuration = nil
    end

    def configured?
      configuration.configured?
    end
  end
end

ActiveRecord::Migration.extend Handcuffs::Dsl

