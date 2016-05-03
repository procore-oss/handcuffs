require_relative 'spec_helper.rb'

RSpec.describe 'handcuffs:migrate' do
  include_context 'rake'

  let!(:add_table_foo_version) { '20160329040426' } #pre_deploy
  let!(:add_column_foo_widget_count_version){ '20160329042840' } #pre_deploy
  let!(:add_index_foo_widget_count_version) { '20160329224617' } #post_deploy
  let!(:add_column_foo_whatzit_count_version){ '20160330002738' } #pre_deploy
  let!(:add_foo_whatzit_default_version){ '20160330003159' } #post_deploy
  let!(:add_table_bar_version){ '20160330005509' } #none

  it 'raises an error when not passed a phase argument' do
    expect { subject.invoke }.to raise_error(RequiresPhaseArgumentError)
  end

  it 'raises not configured error if Handcuffs is not configured' do
    Handcuffs.config = nil
    expect { subject.invoke(:pre_deploy) }.to raise_error(HandcuffsNotConfiguredError)
  end

  context 'with basic config' do
    before(:all) do
      Handcuffs.configure do |config|
        config.phases = [:pre_deploy, :post_deploy]
        config.default_phase = :pre_deploy
      end
    end

    it 'raises unknown phase error if given unkown phase' do
      expect { subject.invoke(:foo) }.to raise_error(HandcuffsUnknownPhaseError)
    end

    context '[pre_deploy]' do
      it 'runs pre_deploy migrations only' do
        subject.invoke(:pre_deploy)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version
        ]
      end
    end

    context '[post_deploy]' do
      it 'raises phase out of order error if post_deploy migrations run' do
        expect { subject.invoke(:post_deploy) }.to raise_error(HandcuffsPhaseOutOfOrderError)
      end

      it 'runs post_deploy migrations after pre_deploy migrations' do
        subject.invoke(:pre_deploy)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version
        ]
        subject.reenable
        subject.invoke(:post_deploy)
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
        config.phases = [:pre_deploy, :post_deploy]
      end
    end

    it 'raises error on nil phase' do
      expect { subject.invoke(:pre_deploy) }.to raise_error(HandcuffsPhaseUndefinedError)
    end
  end
end

RSpec.describe 'handcuffs:rollback' do
  include_context 'rake'

  let! (:add_table_foo_version) { '20160329040426' } #pre_deploy
  let! (:add_column_foo_widget_count_version){ '20160329042840' } #pre_deploy
  let!(:add_index_foo_widget_count_version) { '20160329224617' } #post_deploy
  let!(:add_column_foo_whatzit_count_version){ '20160330002738' } #pre_deploy
  let!(:add_foo_whatzit_default_version){ '20160330003159' } #post_deploy
  let!(:add_table_bar_version){ '20160330005509' } #none

  it 'raises an error when not passed a phase argument' do
    expect { subject.invoke }.to raise_error(RequiresPhaseArgumentError)
  end

  it 'raises not configured error if Handcuffs is not configured' do
    Handcuffs.config = nil
    expect { subject.invoke(:pre_deploy) }.to raise_error(HandcuffsNotConfiguredError)
  end

  context 'with basic config' do
    before(:all) do
      Handcuffs.configure do |config|
        config.phases = [:pre_deploy, :post_deploy]
        config.default_phase = :pre_deploy
      end
    end

    context '[post_deploy]' do

      it 'reverses last post_deploy migration' do
        rake['handcuffs:migrate'].invoke(:all)
        subject.invoke(:post_deploy)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_table_bar_version,
          add_index_foo_widget_count_version,
        ]
      end
    end

    context '[pre_deploy]' do
      it 'reverses last pre_deploy migration' do
        rake['handcuffs:migrate'].invoke(:all)
        subject.invoke(:pre_deploy)
        expect(SchemaMigrations.pluck(:version)).to eq [
          add_table_foo_version,
          add_column_foo_widget_count_version,
          add_column_foo_whatzit_count_version,
          add_index_foo_widget_count_version,
          add_foo_whatzit_default_version
        ]
      end
    end
  end
end

class SchemaMigrations < ActiveRecord::Base; end
