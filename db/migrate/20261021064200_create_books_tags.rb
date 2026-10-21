class CreateBooksTags < ActiveRecord::Migration[8.1]
  def change
    create_table :books_tags, id: false do |t|
      t.integer :book_id, null: false
      t.integer :tag_id, null: false

      t.index [:book_id, :tag_id]
      t.index [:tag_id, :book_id]
    end
  end
end
