class AddFooWhatzitDefault < ACTIVE_RECORD_MIGRATION_CLASS

  phase :post_restart

  def up
    change_column_default :foo, :whatzit_count, 0
  end

  def down
    change_column_default :foo, :whatzit_count, nil
  end
end
