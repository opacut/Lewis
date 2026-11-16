json.extract! book, :id, :title, :author, :location, :description, :created_at, :updated_at

json.image_url(
  if book.image.attached?
    rails_representation_url(book.image.variant(resize_to_limit: [200, 50]), only_path: true)
  end
)

json.tags book.tags do |tag|
  json.extract! tag, :id, :name
end

json.url book_url(book, format: :json)