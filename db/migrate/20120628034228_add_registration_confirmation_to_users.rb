class AddRegistrationConfirmationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registration_confirmation_token, :string

    add_column :users, :registration_confirmation_sent_at, :datetime

  end
end
