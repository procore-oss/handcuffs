# frozen_string_literal: true

require "handcuffs/configuration"

RSpec.describe Handcuffs::Configuration do
  describe '#configured?' do
    it 'returns true if phases have been configured' do
      configuration = described_class.new(phases: %i[foo bar])
      expect(configuration.configured?).to eq(true)
    end

    it 'returns false if phases have not been configured' do
      configuration = described_class.new
      expect(configuration.configured?).to eq(false)
    end
  end
end
