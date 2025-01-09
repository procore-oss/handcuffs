# frozen_string_literal: true

require 'tsort'

module Handcuffs
  # Phases encapsulates the list of phases and any interdependencies
  class Phases
    def initialize(phases)
      @phases = case phases
                when Hash
                  phases.each_with_object({}) do |phase, acc|
                    acc[phase[0].to_sym] = Array(phase[1]).map(&:to_sym)
                  end
                else
                  # Assume each entry depends on all entries before it
                  phases.map(&:to_sym).each_with_object({}) do |phase, acc|
                    acc[phase] = phases.take_while { |defined_phase| defined_phase != phase }
                  end
                end
    end

    def to_sentence
      @phases.keys.to_sentence
    end

    def include?(phase)
      @phases.include?(phase)
    end

    def in_order
      TSort.tsort(
        @phases.method(:each_key),
        ->(phase, &block) { @phases.fetch(phase).each(&block) }
      )
    end

    def prereqs(attempted_phase)
      @phases.fetch(attempted_phase, [])
    end
  end
end
