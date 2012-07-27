class AddStockIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :stock_id, :integer

  end
end
