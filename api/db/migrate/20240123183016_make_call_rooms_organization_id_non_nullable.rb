class MakeCallRoomsOrganizationIdNonNullable < ActiveRecord::Migration[7.1]
  class MigrationCallRoom < ActiveRecord::Base
    self.table_name = "call_rooms"
  end

  class MigrationSubject < ActiveRecord::Base
    self.table_name = "subjects"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    MigrationCallRoom
      .where(organization_id: nil)
      .find_each do |room|
        subject = MigrationSubject.find_by(id: room.subject_id)
        next unless subject

        owner = MigrationUser.find_by(id: subject.owner_id)
        next unless owner

        room.update_columns(
          organization_id: owner.organization_id
        )
      end

    change_column :call_rooms, :organization_id, :bigint, unsigned: true, null: false
  end

  def down
    change_column :call_rooms, :organization_id, :bigint, unsigned: true, null: true
  end
end