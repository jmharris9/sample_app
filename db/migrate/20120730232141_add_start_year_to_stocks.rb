class AddStartYearToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :start_year, :integer

  end
end
