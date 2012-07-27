class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.string :name
      t.float :yr0
      t.float :yr1
      t.float :yr2
      t.float :yr3
      t.float :yr4
      t.float :start_year

      t.timestamps
    end
  end
end
