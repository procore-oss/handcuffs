class AddIndexFooWidgetCount < ActiveRecord::Migration

  disable_ddl_transaction!

  phase :post_deploy

  def up
    add_index :foo,
      :widget_count,
      algorithm: :concurrently
  end

  def down
    remove_index :foo, :widget_count
  end

end
