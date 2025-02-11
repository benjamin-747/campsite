class MakeCallRoomsOrganizationIdNonNullable < ActiveRecord::Migration[7.1]
  def up


    change_column :call_rooms, :organization_id, :bigint, unsigned: true, null: false
  end

  def down
    change_column :call_rooms, :organization_id, :bigint, unsigned: true, null: true
  end
end
