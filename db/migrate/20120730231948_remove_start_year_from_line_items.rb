class RemoveStartYearFromLineItems < ActiveRecord::Migration
  def up
    remove_column :line_items, :start_year
      end

  def down
    add_column :line_items, :start_year, :float
  end
end
