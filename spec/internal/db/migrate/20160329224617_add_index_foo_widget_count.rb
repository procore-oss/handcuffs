class AddIndexFooWidgetCount < ActiveRecord::Migration[ActiveRecord::Migration.current_version]
  disable_ddl_transaction!

  phase :post_restart

  def up
    add_index :foo,
              :widget_count
  end

  def down
    remove_index :foo, :widget_count
  end
end
