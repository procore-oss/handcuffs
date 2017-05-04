class AddColumnFooWhatzitCount < ACTIVE_RECORD_MIGRATION_CLASS

  phase :pre_restart

  def up
    add_column :foo, :whatzit_count, :integer
  end

  def down
    remove_column :foo, :whatzit_count
  end
end
