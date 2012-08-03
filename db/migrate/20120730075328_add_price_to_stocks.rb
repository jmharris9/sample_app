class AddPriceToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :price, :float

  end
end
