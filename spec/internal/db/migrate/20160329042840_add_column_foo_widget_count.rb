class AddColumnFooWidgetCount < ActiveRecord::Migration[ActiveRecord::Migration.current_version]
  phase :pre_restart

  def up
    add_column :foo, :widget_count, :integer
  end

  def down
    remove_column :foo, :widget_count
  end
end
