class AddPexipToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pexip, :boolean, default: true
  end
end
