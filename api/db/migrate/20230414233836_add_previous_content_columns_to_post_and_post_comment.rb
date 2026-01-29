class AddPreviousContentColumnsToPostAndPostComment < ActiveRecord::Migration[7.0]
  class MigrationPost < ActiveRecord::Base
    self.table_name = "posts"
  end

  class MigrationPostComment < ActiveRecord::Base
    self.table_name = "post_comments"
  end
  def change
    add_column :posts, :previous_description, :text
    add_column :post_comments, :previous_body, :text

    reversible do |dir|
      dir.up do
        MigrationPost.in_batches do |posts|
          posts.update_all("previous_description = description")
        end

        MigrationPostComment.in_batches do |comments|
          comments.update_all("previous_body = body")
        end
      end
    end
  end
end
