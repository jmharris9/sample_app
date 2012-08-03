class AddYr8ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :yr8, :float

  end
end
