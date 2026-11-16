class TagShowComponent < ApplicationComponent
  def initialize_state
    {
      tag: nil,
      books: [],
      loading: true,
      error: nil
    }
  end

  def component_mounted
    @alive = true

    Tag.find(props[:id]) do |tag, error|
      next unless @alive
      if error
        patch(error: error, loading: false)
      else
        patch(tag: tag, loading: false)
      end
    end

    Book.all do |books, error|
      next unless @alive
      patch(books: books || []) unless error
    end
  end

  def component_unmounted
    @alive = false
  end

  def render
    div do
      if state[:loading]
        p { "Loading tag..." }
      elsif state[:error]
        p { "Error: #{state[:error]}" }
      elsif state[:tag]
        tag = state[:tag]
        h1 { "Tag: #{tag.name}" }

        matching_books = state[:books].select do |book|
          (book.tags || []).any? { |t| (t["id"] || t[:id]).to_s == tag.id.to_s }
        end

        if matching_books.empty?
          p { "No books with this tag." }
        else
          ul do
            matching_books.each do |book|
              li do
                link_to(routes.book_path(book.id), navigate: true) { book.title }
              end
            end
          end
        end

        div do
          link_to(routes.tags_path, navigate: true) { "All Tags" }
          span { " | " }
          link_to(routes.books_path, navigate: true) { "Back to Books" }
        end
      end
    end
  end
end