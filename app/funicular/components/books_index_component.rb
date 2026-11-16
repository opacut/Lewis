class BooksIndexComponent < ApplicationComponent
  SORT_OPTIONS = {
    "Title" => "title",
    "Author" => "author",
    "Location" => "location",
    "Date added" => "newest"
  }.freeze

  def initialize_state
    {
      books: [],
      tags: [],
      loading: true,
      notice: nil,
      search_name: "",
      search_author: "",
      location: "",
      selected_tags: [],
      sort: "title",
      direction: "asc",
      table_mode: true
    }
  end

  def component_mounted
    @alive = true
    puts "BooksIndexComponent mounted! Calling Book.all..."

    Book.all do |books, error|
      puts "Book.all callback: books=#{books.inspect}, error=#{error.inspect}"
      next unless @alive

      if error
        patch(notice: "Error loading books: #{error}", loading: false)
      else
        patch(books: books || [], loading: false)
      end
    end

    Tag.all do |tags, error|
      puts "Tag.all callback: tags=#{tags.inspect}, error=#{error.inspect}"
      next unless @alive
      patch(tags: tags || []) unless error
    end
  end

  # --- Actions & Event Handlers ---

  def toggle_tag(tag_name)
    current = state[:selected_tags]
    updated = current.include?(tag_name) ? current - [tag_name] : current + [tag_name]
    patch(selected_tags: updated)
  end

  def clear_search
    patch(
      search_name: "",
      search_author: "",
      location: "",
      selected_tags: []
    )
  end

  def change_sort(value)
    patch(sort: value)
  end

  def toggle_direction
    patch(direction: state[:direction] == "asc" ? "desc" : "asc")
  end

  def handle_destroy(book)
    return unless JS.global.confirm("Delete \"#{book.title}\"?")

    book.destroy do |success, error|
      next unless @alive
      if success
        patch(books: state[:books].reject { |b| b.id == book.id })
      else
        patch(error: error || "Failed to delete book")
      end
    end
  end

  # --- Client-Side Filtering & Sorting ---

  def filtered_and_sorted_books
    results = state[:books].select do |book|
      name_match = state[:search_name].empty? ||
                   book.title.to_s.downcase.include?(state[:search_name].downcase)

      author_match = state[:search_author].empty? ||
                     book.author.to_s.downcase.include?(state[:search_author].downcase)

      location_match = state[:location].empty? ||
                       book.location.to_s.downcase.include?(state[:location].downcase)

      book_tag_names = (book.tags || []).map { |t| t["name"] || t[:name] }
      tags_match = state[:selected_tags].all? { |t| book_tag_names.include?(t) }

      name_match && author_match && location_match && tags_match
    end

    dir = state[:direction] == "desc" ? -1 : 1

    results.sort do |a, b|
      val_a = sort_value_for(a)
      val_b = sort_value_for(b)
      (val_a <=> val_b) * dir
    end
  end

  def sort_value_for(book)
    case state[:sort]
    when "author"   then book.author.to_s.downcase
    when "location" then book.location.to_s.downcase
    when "newest"   then book.created_at.to_s
    else                 book.title.to_s.downcase
    end
  end

  def any_active_filters?
    !state[:search_name].empty? ||
      !state[:search_author].empty? ||
      !state[:location].empty? ||
      state[:selected_tags].any?
  end

  # --- Render ---

  def render
    div do
      p(class: "notice") { state[:notice] } if state[:notice]

      h1 { "Books" }
      button(onclick: -> { Funicular.router.navigate(routes.new_book_path) }) { "Create New book" }

      render_search_inputs
      render_active_filters
      render_tag_pills

      if any_active_filters?
        a(href: "#", onclick: ->(e) { e.prevent_default; clear_search }) { "Clear search" }
      end

      render_sorting
      render_view_switch
      state[:table_mode] ? render_books_table_view : render_books_cards_view
    end
  end

  private

  def render_search_inputs
    div(class: "search-forms") do
      div(class: "search-form") do
        input(
          type: "text",
          value: state[:search_name],
          placeholder: "Search by book name...",
          oninput: ->(e) { patch(search_name: e.target[:value]) }
        )
      end

      div(class: "search-form") do
        input(
          type: "text",
          value: state[:search_author],
          placeholder: "Search by book author...",
          oninput: ->(e) { patch(search_author: e.target[:value]) }
        )
      end

      div(class: "search-form") do
        input(
          type: "text",
          value: state[:location],
          placeholder: "Search by book location...",
          oninput: ->(e) { patch(location: e.target[:value]) }
        )
      end
    end
  end

  def render_active_filters
    return unless any_active_filters?

    text_filters = [
      ["Book name", :search_name],
      ["Author", :search_author],
      ["Location", :location]
    ]

    div(class: "active-filters") do
      strong { "Active filters: " }

      text_filters.each do |label, key|
        next if state[key].empty?

        span(class: "active-filter") do
          span { "#{label}: #{state[key]} " }
          a(
            href: "#",
            class: "remove-filter",
            aria_label: "Remove #{label} filter",
            onclick: ->(e) { e.prevent_default; patch(key => "") }
          ) { "×" }
        end
      end

      state[:selected_tags].each do |tag_name|
        span(class: "active-filter") do
          span { "Tag: #{tag_name} " }
          a(
            href: "#",
            class: "remove-filter",
            aria_label: "Remove #{tag_name} tag filter",
            onclick: ->(e) { e.prevent_default; toggle_tag(tag_name) }
          ) { "×" }
        end
      end
    end
  end

  def render_tag_pills
    div(class: "tag-pills") do
      state[:tags].each do |tag|
        selected = state[:selected_tags].include?(tag.name)
        button(
          type: "button",
          class: selected ? "tag-pill active" : "tag-pill",
          onclick: -> { toggle_tag(tag.name) }
        ) { tag.name }
      end
    end
  end

  def render_sorting
    div(class: "book-sorting") do
      strong { "Sort by: " }

      SORT_OPTIONS.each do |label, value|
        a(
          href: "#",
          class: "sort-link #{state[:sort] == value ? 'active' : ''}",
          onclick: ->(e) { e.prevent_default; change_sort(value) }
        ) { label }
      end

      a(
        href: "#",
        class: "sort-direction",
        onclick: ->(e) { e.prevent_default; toggle_direction }
      ) { state[:direction] == "asc" ? "↑ Ascending" : "↓ Descending" }
    end
  end

  def render_view_switch 
    div(class: "view-switch-toggle") do
        label { "Switch views: " }
        input(
          type: "checkbox",
          class: "switch",
          label: "Switch",
          oninput: ->(e) { state[:table_mode] ? patch(table_mode: false) : patch(table_mode: true) }
        )
    end
  end

  def render_books_cards_view
    div(id: "books") do
      p { "Cards view under construction" }
    end
  end

  def render_books_table_view
    div(id: "books") do
      if state[:loading]
        p { "Loading books..." }
      else
        table(class: "books-table") do
          thead do
            tr do
              th(class: "books-table-header-cell")
              th(class: "books-table-header-cell") { "Book Title" }
              th(class: "books-table-header-cell") { "Author" }
              th(class: "books-table-header-cell") { "Location" }
              th(class: "books-table-header-cell") { "Tags" }
              th(class: "books-table-header-cell")
            end
          end
          tbody do
            filtered_and_sorted_books.each do |book|
              component(::BookRowComponent, book: book, on_destroy: method(:handle_destroy))
            end
          end
        end
      end
    end
  end

  # Placeholder data loaders — see note below on Funicular's HTTP/Model API
  def load_books_and_tags
    # Fetch /books.json and /tags.json, then patch(books: ..., tags: ..., loading: false)
  end

  def delete_book(id)
    # Send DELETE /books/#{id}.json, then patch(books: state[:books].reject { |b| b[:id] == id })
  end
end