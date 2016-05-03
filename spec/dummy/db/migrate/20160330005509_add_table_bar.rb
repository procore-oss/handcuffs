class AddTableBar < ActiveRecord::Migration

  #look ma, no phase!

  def up
    create_table :bar
  end

  def down
    drop_table :bar
  end
end
