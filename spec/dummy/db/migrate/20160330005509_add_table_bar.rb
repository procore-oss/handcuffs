class AddTableBar < ACTIVE_RECORD_MIGRATION_CLASS

  #look ma, no phase!

  def up
    create_table :bar
  end

  def down
    drop_table :bar
  end
end
