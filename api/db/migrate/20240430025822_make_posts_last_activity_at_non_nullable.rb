class MakePostsLastActivityAtNonNullable < ActiveRecord::Migration[7.1]
  class MigrationPost < ActiveRecord::Base
    self.table_name = "posts"
  end

  def up
    MigrationPost.where(last_activity_at: nil).find_each do |post|
      post.update_columns(last_activity_at: post.updated_at)
    end

    change_column :posts, :last_activity_at, :datetime, null: false
  end
end