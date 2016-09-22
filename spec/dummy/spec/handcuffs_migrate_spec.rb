require_relative 'spec_helper.rb'

RSpec.describe 'handcuffs:migrate' do
  include_context 'rake'

  let!(:add_table_foo_version) { '20160329040426' } #pre_restart
  let!(:add_column_foo_widget_count_version){ '20160329042840' } #pre_restart
  let!(:add_index_foo_widget_count_version) { '20160329224617' } #post_restart
  let!(:add_column_foo_whatzit_count_version){ '20160330002738' } #pre_restart
  let!(:add_foo_whatzit_default_version){ '20160330003159' } #post_restart
  let!(:add_table_bar_version){ '20160330005509' } #none

  it 'raises an error when not passed a phase argument' do
    expect { subject.invoke }.to raise_error(RequiresPhaseArgumentError)
  end

  it 'raises not configured error if Handcuffs is not configured' do
    Handcuffs.config = nil
    expect { subject.invoke(:pre_restart) }.to raise_error(HandcuffsNotConfiguredError)
  end

  context 'with basic config' do
    before(:all) do
      Handcuffs.configure do |config|
        config.phases = [:pre_restart, :post_restart]
        config.default_phase = :pre_restart
      end
    end

    it 'raises unknown phase error if given unknown phase' do
      expect { subject.invoke(:foo) }.to raise_error(HandcuffsUnknownPhaseError)
    end

    context '[pre_restart]' do
      it 'runs pre_restart migrations only' do
        subject.invoke(:pre_restart)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version
        ]
      end

      it 'works with log file' do
        filename = 'handcuffs.pre_restart.12343289.json'
        ENV['HANDCUFFS_LOG'] = filename
        begin
          subject.invoke(:pre_restart)
          expect(SchemaMigrations.pluck(:version)).to eq [
            add_table_foo_version,
            add_column_foo_widget_count_version,
            add_column_foo_whatzit_count_version,
            add_table_bar_version
          ]
          hash_array = File.readlines(filename).map { |line| JSON.parse(line).symbolize_keys }
          expect(hash_array.length).to eql 4
          expect(hash_array[0]).to include({
            version: 20160329040426,
            direction: 'up',
            phase: 'pre_restart'
          })
          expect(hash_array[1]).to include({
            version: 20160329042840,
            direction: 'up',
            phase: 'pre_restart'
          })
          expect(hash_array[2]).to include({
            version: 20160330002738,
            direction: 'up',
            phase: 'pre_restart'
          })
          expect(hash_array[3]).to include({
            version: 20160330005509,
            direction: 'up',
            phase: 'pre_restart'
          })
        ensure
          ENV['HANDCUFFS_LOG'] = nil 
          File.delete(filename)
        end
      end
    end

    context '[post_restart]' do
      it 'raises phase out of order error if post_restart migrations run' do
        expect { subject.invoke(:post_restart) }.to raise_error(HandcuffsPhaseOutOfOrderError)
      end

      it 'runs post_restart migrations after pre_restart migrations' do
        subject.invoke(:pre_restart)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version
        ]
        subject.reenable
        subject.invoke(:post_restart)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version,
          add_index_foo_widget_count_version,
          add_foo_whatzit_default_version
        ]
      end
    end

    context '[all]' do
      it 'runs all migrations' do
        subject.invoke(:all)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version,
          add_index_foo_widget_count_version,
          add_foo_whatzit_default_version,
        ]
      end
    end

  end

  context 'no default phase' do
    before(:all) do
      Handcuffs.configure do |config|
        config.phases = [:pre_restart, :post_restart]
      end
    end

    it 'raises error on nil phase' do
      expect { subject.invoke(:pre_restart) }.to raise_error(HandcuffsPhaseUndefinedError)
    end
  end
end



class SchemaMigrations < ActiveRecord::Base; end
