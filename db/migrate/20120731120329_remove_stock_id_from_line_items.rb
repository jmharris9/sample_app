class RemoveStockIdFromLineItems < ActiveRecord::Migration
  def up
    remove_column :line_items, :stock_id
      end

  def down
    add_column :line_items, :stock_id, :integer
  end
end
