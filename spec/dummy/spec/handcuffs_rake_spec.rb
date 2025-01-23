# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'handcuffs' do
  include_context 'rake'
  let!(:add_table_foo_version) { '20160329040426' } # pre_restart
  let!(:add_column_foo_widget_count_version) { '20160329042840' } # pre_restart
  let!(:add_index_foo_widget_count_version) { '20160329224617' } # post_restart
  let!(:add_column_foo_whatzit_count_version) { '20160330002738' } # pre_restart
  let!(:add_foo_whatzit_default_version) { '20160330003159' } # post_restart
  let!(:add_table_bar_version) { '20160330005509' } # none

  describe 'handcuffs:migrate' do
    subject { rake['handcuffs:migrate'] }

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
          config.phases = %i[pre_restart post_restart]
          config.default_phase = :pre_restart
        end
      end

      it 'raises unknown phase error if given unknown phase' do
        expect { subject.invoke(:foo) }.to raise_error(HandcuffsUnknownPhaseError)
      end

      context 'when running phase [pre_restart]' do
        it 'runs pre_restart migrations only' do
          subject.invoke(:pre_restart)
          expect(SchemaMigrations.pluck(:version)).to eq [
            add_table_foo_version,
            add_column_foo_widget_count_version,
            add_column_foo_whatzit_count_version,
            add_table_bar_version
          ]
        end
      end

      context 'when running phase [post_restart]' do
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

      context 'when running phase [all]' do
        it 'runs all migrations' do
          subject.invoke(:all)
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
    end

    context 'with no default phase' do
      before(:all) do
        Handcuffs.configure do |config|
          config.phases = %i[pre_restart post_restart]
        end
      end

      it 'raises error on nil phase' do
        expect { subject.invoke(:pre_restart) }.to raise_error(HandcuffsPhaseUndefinedError)
      end
    end

    context 'explicitly dependency graph' do
      before(:all) do
        Handcuffs.configure do |config|
          config.phases = {
            post_restart: [:pre_restart],
            pre_restart: []
          }
          config.default_phase = :pre_restart
        end
      end

      it 'can run phases without dependencies' do
        expect { subject.invoke(:pre_restart) }.not_to raise_error
      end

      it 'enforces dependencies' do
        expect { subject.invoke(:post_restart) }.to raise_error(HandcuffsPhaseOutOfOrderError)
      end

      it 'can run once dependencies run' do
        subject.invoke(:pre_restart)
        expect { subject.invoke(:post_restart) }.not_to raise_error
      end
    end
  end

  describe 'handcuffs:rollback' do
    subject { rake['handcuffs:rollback'] }

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
          config.phases = %i[pre_restart post_restart]
          config.default_phase = :pre_restart
        end
      end

      context '[post_restart]' do
        it 'reverses last post_restart migration' do
          rake['handcuffs:migrate'].invoke(:all)
          subject.invoke(:post_restart)
          expect(SchemaMigrations.pluck(:version)).to eq [
            add_table_foo_version,
            add_column_foo_widget_count_version,
            add_column_foo_whatzit_count_version,
            add_table_bar_version,
            add_index_foo_widget_count_version
          ]
        end
      end

      context '[pre_restart]' do
        it 'reverses last pre_restart migration' do
          rake['handcuffs:migrate'].invoke(:all)
          subject.invoke(:pre_restart)
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
end

class SchemaMigrations < ActiveRecord::Base; end
