class BookShowComponent < ApplicationComponent
  use_suspense :book,
    ->(resolve, reject) {
      Book.find(props[:id]) do |book, error|
        error ? reject.call(error) : resolve.call(book)
      end
    }

  def handle_destroy(book)
    return unless JS.global.confirm("Are you sure you want to delete this book?")

    book.destroy do |_ok, error|
      if error
        patch(notice: "Delete failed: #{error}")
      else
        Funicular.router.navigate(routes.books_path)
      end
    end
  end

  def render
    div do
      p(class: "notice") { state[:notice] } if state[:notice]

      suspense(
        :book,
        fallback: -> { div { "Loading book..." } },
        error: ->(e) { div { "Error: #{e}" } }
      ) do |res|
        book = res[:book]

        div do
          img(src: book.image_url) if book.image_url
          h2 { book.title }
          p { strong { "Author: " }; span { book.author } }
          p { strong { "Location: " }; span { book.location } }
          p { strong { "Description: " }; span { book.description } }

          if (book.tags || []).any?
            p do
              strong { "Tags: " }
              book.tags.each do |tag|
                span { "#{tag['name'] || tag[:name]} " }
              end
            end
          end

          div do
            link_to routes.edit_book_path(book), navigate: true do
              span { "Edit this book" }
            end
            span { " | " }
            link_to routes.books_path, navigate: true do
              span { "Back to books" }
            end
            span { " " }
            button(onclick: -> { handle_destroy(book) }) { "Destroy this book" }
          end
        end
      end
    end
  end
end