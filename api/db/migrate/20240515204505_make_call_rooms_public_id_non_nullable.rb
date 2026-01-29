class MakeCallRoomsPublicIdNonNullable < ActiveRecord::Migration[7.1]
  class MigrationCallRoom < ActiveRecord::Base
    self.table_name = "call_rooms"
  end

  def up
    MigrationCallRoom.where(public_id: nil).find_each do |room|
      room.update_columns(public_id: SecureRandom.alphanumeric(12))
    end

    change_column :call_rooms, :public_id, :string, limit: 12, null: false
  end
end