require_relative 'spec_helper.rb'

RSpec.describe 'handcuffs:migrate_log:up' do
  include_context 'rake'

  let!(:add_table_foo_version) { '20160329040426' } #pre_restart
  let!(:add_column_foo_widget_count_version){ '20160329042840' } #pre_restart
  let!(:add_index_foo_widget_count_version) { '20160329224617' } #post_restart
  let!(:add_column_foo_whatzit_count_version){ '20160330002738' } #pre_restart
  let!(:add_foo_whatzit_default_version){ '20160330003159' } #post_restart
  let!(:add_table_bar_version){ '20160330005509' } #none

  context 'with basic config' do
    before(:all) do
      Handcuffs.configure do |config|
        config.phases = [:pre_restart, :post_restart]
        config.default_phase = :pre_restart
      end
    end

    it 'rolls back and re-runs files in log' do
      filename = 'handcuffs.up.pre_restart.12343289.json'
      ENV['HANDCUFFS_LOG'] = filename
      begin
        rake['handcuffs:migrate'].invoke(:pre_restart)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version
        ]
        rake['handcuffs:migrate_log:down'].invoke(filename)
        expect(SchemaMigrations.pluck(:version)).to eql []
        subject.invoke(filename)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version
        ]
      ensure
        ENV['VERSION'] = nil
        ENV['HANDCUFFS_LOG'] = nil 
        File.delete(filename)
      end
    end
  end
end

class SchemaMigrations < ActiveRecord::Base; end
