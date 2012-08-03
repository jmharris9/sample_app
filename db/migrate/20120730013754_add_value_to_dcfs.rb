class AddValueToDcfs < ActiveRecord::Migration
  def change
    add_column :dcfs, :value, :float

  end
end
