class AddColumnFooWidgetCount < ACTIVE_RECORD_MIGRATION_CLASS

  phase :pre_restart

  def up
    add_column :foo, :widget_count, :integer
  end

  def down
    remove_column :foo, :widget_count
  end
end
