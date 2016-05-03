class AddColumnFooWhatzitCount < ActiveRecord::Migration

  phase :pre_deploy

  def up
    add_column :foo, :whatzit_count, :integer
  end

  def down
    remove_column :foo, :whatzit_count
  end
end
