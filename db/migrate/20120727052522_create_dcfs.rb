class CreateDcfs < ActiveRecord::Migration
  def change
    create_table :dcfs do |t|
      t.float :growth_rate
      t.float :discount_rate
      t.string :name

      t.timestamps
    end
  end
end
