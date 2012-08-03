class AddYr7ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :yr7, :float

  end
end
