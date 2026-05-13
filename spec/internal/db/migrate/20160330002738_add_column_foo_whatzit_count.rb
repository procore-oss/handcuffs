class AddColumnFooWhatzitCount < ActiveRecord::Migration[ActiveRecord::Migration.current_version]
  phase :pre_restart

  def up
    add_column :foo, :whatzit_count, :integer
  end

  def down
    remove_column :foo, :whatzit_count
  end
end
