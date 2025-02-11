class MakeCallRoomsPublicIdNonNullable < ActiveRecord::Migration[7.1]


  def down
    change_column :call_rooms, :public_id, :string, limit: 12
  end
end
