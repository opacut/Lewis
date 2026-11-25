class BookRowComponent < ApplicationComponent
  def render
    book = props[:book]

    tr(id: "book_#{book.id}") do
      td do
        if book.image_url && !book.image_url.empty?
          img(src: book.image_url, alt: book.title, class: "book-thumb")
        else
          span { "—" }
        end
      end  
    
      td do
        link_to(routes.book_path(book.id), navigate: true) { book.title }
      end

      td { book.author }

      td { book.location }

      td do
        (book.tags || []).each do |tag|
          tag_name = tag["name"] || tag[:name]
          tag_id   = tag["id"]   || tag[:id]
          span(class: "tag-badge") do
            if tag_id
              link_to(routes.tag_path(tag_id), navigate: true) { tag_name }
            else
              tag_name
            end
          end
        end
      end

      #td do
      #  button(onclick: -> { Funicular.router.navigate(routes.edit_book_path(book.id)) }) { "Edit" }
      #  span { " | " }
      #  button(onclick: -> { props[:on_destroy]&.call(book) }) { "Delete" }
      #end

      td do
        details(class: 'dropdown') do
          summary(class: 'btn btn-primary') { "≡" }
          ul(class: 'dropdown-menu') do
            li do 
              button(class: 'dropdown-btn', onclick: -> {Funicular.router.navigate(routes.book_path(book.id))}) { "Show" }
            end 
            li do
              button(class: 'dropdown-btn', onclick: -> { Funicular.router.navigate(routes.edit_book_path(book.id)) }) { "Edit" }
            end 
            li do
              button(class: 'dropdown-btn', onclick: -> { props[:on_destroy]&.call(book) }) { "Delete" }
            end
          end 
        end
      end
    end
  end
end