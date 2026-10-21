json.extract! book, :id, :title, :author, :location, :description, :image, :created_at, :updated_at
json.url book_url(book, format: :json)
