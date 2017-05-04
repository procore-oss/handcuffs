class AddIndexFooWidgetCount < ACTIVE_RECORD_MIGRATION_CLASS

  disable_ddl_transaction!

  phase :post_restart

  def up
    add_index :foo,
      :widget_count,
      algorithm: :concurrently
  end

  def down
    remove_index :foo, :widget_count
  end

end
