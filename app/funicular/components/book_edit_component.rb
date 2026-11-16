class BookEditComponent < ApplicationComponent
  use_suspense :book,
    ->(resolve, reject) {
      Book.find(props[:id]) do |book, error|
        error ? reject.call(error) : resolve.call(book)
      end
    }

  def render
    div do
      h1 { "Edit book" }

      suspense(
        :book,
        fallback: -> { div { "Loading book..." } },
        error: ->(e) {
          div do
            span { "Failed to load book: #{e}" }
            button(onclick: -> { reload_suspense(:book) }) { "Retry" }
          end
        }
      ) do |res|
        book = res[:book]
        div do
          component(::BookFormComponent, book: book)
          link_to routes.book_path(book), navigate: true do
            span { "Cancel" }
          end
        end
      end
    end
  end
end