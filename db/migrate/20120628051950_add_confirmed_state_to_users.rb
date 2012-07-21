class AddConfirmedStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmed_state, :string

  end
end
