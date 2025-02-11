class AddPreviousContentColumnsToPostAndPostComment < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :previous_description, :text
    add_column :post_comments, :previous_body, :text

  end
end
