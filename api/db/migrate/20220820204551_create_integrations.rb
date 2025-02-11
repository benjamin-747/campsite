class CreateIntegrations < ActiveRecord::Migration[7.0]
  def change
    create_table :integrations, id: { type: :bigint, unsigned: true } do |t|
      t.string     :public_id, limit: 12, null: false, index: { unique: true }
      t.string     :provider, null: false, index: true
      t.string     :token, null: false
      t.references :creator, null: false, unsigned: true
      t.references :organization, null: false, unsigned: true
      t.timestamps
    end

    create_table :integration_data, id: { type: :bigint, unsigned: true } do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.references :integration, null: false, unsigned: true
      t.timestamps
    end

    create_table :project_memberships, id: { type: :bigint, unsigned: true } do |t|
      t.string :public_id, limit: 12, null: false, index: { unique: true }
      t.integer :position
      t.references :project, null: false, unsigned: true
      t.references :organization_membership, null: false, unsigned: true
      t.boolean    :remindable, null: false, default: true
      t.bigint :user_id, null: false, unsigned: true
      t.timestamps
    end
  end
end
