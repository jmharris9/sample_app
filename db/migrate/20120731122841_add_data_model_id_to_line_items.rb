class AddDataModelIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :data_model_id, :integer

  end
end
