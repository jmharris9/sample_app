class RemoveDataModelFromLineItems < ActiveRecord::Migration
  def up
    remove_column :line_items, :data_model
      end

  def down
    add_column :line_items, :data_model, :integer
  end
end
