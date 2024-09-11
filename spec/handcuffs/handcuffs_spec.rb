# frozen_string_literal: true

require 'handcuffs'

RSpec.describe Handcuffs do
  describe '.configure', aggregate_failures: true do
    context 'when a block is given' do
      it 'updates the configuration' do
        described_class.configure do |config|
          config.phases = %i[foo bar]
          config.default_phase = :foo
        end
        expect(Handcuffs.configuration.phases).to eq(%i[foo bar])
        expect(Handcuffs.configuration.default_phase).to eq(:foo)
      end
    end
    context 'when a block is not given' do
      it 'raises an error' do
        expect { described_class.configure }.
          to raise_error(ArgumentError, 'block argument required when using Handcuffs.configure')
      end
    end
  end

  describe '.reset_configuration!' do
    before do
      described_class.configure do |config|
        config.phases = %i[foo bar]
        config.default_phase = :foo
      end
    end
    it 'resets the configuration' do
      expect { described_class.reset_configuration! }.
        to change { Handcuffs.configuration.phases }.from(%i[foo bar]).to([])
    end
  end

  describe '.configured?' do
    context 'when phases have been configured' do
      before do
        described_class.configure do |config|
          config.phases = %i[foo bar]
        end
      end
      it 'returns true' do
        expect(described_class.configured?).to eq(true)
      end
    end
  end
  context 'when phases have not been configured' do
    before do
      described_class.reset_configuration!
    end
    it 'returns false' do
      expect(described_class.configured?).to eq(false)
    end
  end
end
