class AddColumnFooWidgetCount < ActiveRecord::Migration

  phase :pre_deploy

  def up
    add_column :foo, :widget_count, :integer
  end

  def down
    remove_column :foo, :widget_count
  end
end
