class AddYr5ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :yr5, :float

  end
end
