require "handcuffs/errors/configuration_block_missing_error"

RSpec.describe Handcuffs::ConfigurationBlockMissingError do
  matcher :be_caught_with do |expected_identifier|
    match do |actual_exception|
      begin
        raise actual_exception
      rescue expected_identifier => e
        true
      rescue
        false
      end
    end
  end

  it do
    is_expected.to be_caught_with(Handcuffs::Error)
  end

  it do
    is_expected.to be_caught_with(ArgumentError)
  end

  specify do
    expect(subject.message).to eql("block argument required")
  end
end
