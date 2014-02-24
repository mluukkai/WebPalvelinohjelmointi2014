class AddConfirmationStatusToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :confirmed, :boolean
  end
end
