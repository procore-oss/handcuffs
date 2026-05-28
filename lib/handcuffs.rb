# frozen_string_literal: true

require 'logger'
require 'active_record'
require 'active_support/all'
require 'rails/railtie'

require_relative 'handcuffs/errors/unknown_phase_error'
require_relative 'handcuffs/errors/undeclared_phase_error'
require_relative 'handcuffs/errors/requires_phase_argument_error'
require_relative 'handcuffs/errors/phase_undefined_error'
require_relative 'handcuffs/errors/phases_out_of_order_error'
require_relative 'handcuffs/errors/not_configured_error'

require_relative 'handcuffs/configuration'
require_relative 'handcuffs/error'
require_relative 'handcuffs/dsl'
require_relative 'handcuffs/pending_filter'
require_relative 'handcuffs/phases'
require_relative 'handcuffs/phase_filter'
require_relative 'handcuffs/phase_tracker'
require_relative 'handcuffs/railtie'
require_relative 'handcuffs/version'

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
