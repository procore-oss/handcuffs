# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Handcuffs do
  describe '.configure' do
    it 'configures Handcuffs functionality' do
      described_class.configure do |config|
        config.phases = %i[a b c]
        config.default_phase = :a
      end

      expect(described_class.configuration.phases.to_sentence).to eq('a, b, and c')
      expect(described_class.configuration.default_phase).to eq(:a)
    end
  end

  describe '.configuration' do
    it 'returns a configuration object' do
      expect(described_class.configuration).to be_a(Handcuffs::Configuration)
    end
  end

  describe '.configured?' do
    context 'when Handcuffs is configured' do
      before do
        described_class.configure do |config|
          config.phases = %i[a b c]
          config.default_phase = :a
        end
      end

      it 'returns true' do
        expect(described_class.configured?).to be(true)
      end
    end

    context 'when Handcuffs is not configured' do
      before do
        described_class.reset_configuration!
      end

      it 'returns false' do
        expect(described_class.configured?).to be(false)
      end
    end
  end

  describe '.reset_configuration!' do
    before do
      described_class.configure do |config|
        config.phases = %i[a b c]
        config.default_phase = :a
      end
    end

    it 'resets the configuration' do
      expect { described_class.reset_configuration! }.
        to change { described_class.configured? }.from(true).to(false)
    end
  end
end
