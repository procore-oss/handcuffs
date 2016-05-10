require "rails"
require "handcuffs/configuration"

RSpec.describe Handcuffs do
  specify do
    expect{ described_class.configure }.to raise_error(Handcuffs::ConfigurationBlockMissingError)
  end
end
