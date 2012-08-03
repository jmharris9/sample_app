class AddDataModelTypeToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :data_model_type, :string

  end
end
