# app/funicular/initializer.rb
JS::Object::StandardError = ::StandardError if defined?(JS::Object)
Funicular.load_schemas({ Book => "book", Tag => "tag" }) do
  Funicular.start(container: 'app') do |router|
    router.get('/books',          to: BooksIndexComponent, as: 'books')
    router.get('/books/new',      to: BookNewComponent,    as: 'new_book')
    router.get('/books/:id',      to: BookShowComponent,   as: 'book')
    router.get('/books/:id/edit', to: BookEditComponent,   as: 'edit_book')
    router.get('/tags',           to: TagsIndexComponent,  as: 'tags')
    router.get('/tags/:id',       to: TagShowComponent,    as: 'tag')
    router.set_default('/books')
  end
end