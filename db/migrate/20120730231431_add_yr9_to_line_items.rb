class AddYr9ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :yr9, :float

  end
end
