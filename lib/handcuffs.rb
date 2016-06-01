require 'rails'
require 'active_record'

module Handcuffs; end

Dir[File.join(File.dirname(__FILE__), 'handcuffs', '*.rb')].each {|file| require file }

ActiveRecord::Migration.extend Handcuffs::Extensions

