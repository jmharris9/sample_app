class AddNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notifications, :boolean, default: true

  end
end
