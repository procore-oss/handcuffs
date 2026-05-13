# frozen_string_literal: true

require "handcuffs/phases"

RSpec.describe Handcuffs::Phases do
  context 'linear order' do
    subject(:phases) do
      described_class.new(%i[a b c d])
    end

    it 'can be ordered' do
      expect(phases.in_order).to eq(%i[a b c d])
    end

    it 'can find prereqs' do
      expect(phases.prereqs(:c)).to eq(%i[a b])
    end
  end

  context 'dependency graph' do
    subject(:phases) do
      described_class.new(
        a: [],
        b: [:a],
        c: [:a],
        d: %i[b c]
      )
    end

    it 'can be ordered' do
      expect(phases.in_order).to eq(%i[a b c d])
    end

    it 'can find prereqs' do
      expect(phases.prereqs(:c)).to eq([:a])
    end
  end

  describe '#configured?' do
    context 'when phases are configured' do
      subject(:phases) do
        described_class.new(%i[a b c])
      end

      it 'returns true' do
        expect(phases.configured?).to be(true)
      end
    end

    context 'when phases are not configured' do
      subject(:phases) do
        described_class.new([])
      end

      it 'returns false' do
        expect(phases.configured?).to be(false)
      end
    end
  end
end
