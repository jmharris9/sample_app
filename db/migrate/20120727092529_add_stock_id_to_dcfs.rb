class AddStockIdToDcfs < ActiveRecord::Migration
  def change
    add_column :dcfs, :stock_id, :integer

  end
end
