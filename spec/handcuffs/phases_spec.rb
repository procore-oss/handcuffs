require "handcuffs/phases"

RSpec.describe Handcuffs::Phases do
  context 'linear order' do
    subject(:phases) do
      described_class.new(%i[a b c d])

      it 'can be ordered' do
        expect(phases.in_order).to eq(%i[a b c d])
      end

      it 'can find prereqs' do
        expect(phases.prereqs(:c)).to eq(%i[a b])
      end
    end
  end

  context 'dependency graph' do
    subject(:phases) do
      described_class.new(
        a: [],
        b: [:a],
        c: [:a],
        d: [:b, :c],
      )
    end

    it 'can be ordered' do
      expect(phases.in_order).to eq(%i[a b c d])
    end

    it 'can find prereqs' do
      expect(phases.prereqs(:c)).to eq([:a])
    end
  end
end
