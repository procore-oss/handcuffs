require 'tsort'

module Handcuffs
  class Phases
    def initialize(phases)
      @phases = case phases
      when Hash
        phases
      else
        # Assume each entry depends on all entries before it
        phases.each_with_object({}) do |phase, acc|
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
