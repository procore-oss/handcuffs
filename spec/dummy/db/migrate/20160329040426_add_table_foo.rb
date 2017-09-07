class AddTableFoo < ACTIVE_RECORD_MIGRATION_CLASS

  phase :pre_restart

  def up
    create_table :foo do |t|
      t.text :name, null: false
      t.timestamps null: false
    end
  end

  def down
    drop_table :foo
  end
end
