class AddYr6ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :yr6, :float

  end
end
