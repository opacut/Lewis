class BookFormComponent < ApplicationComponent
  def initialize_state
    #JS.eval("debugger;")
    book = props[:book]
    {
      book: {
        title:       book&.title || "",
        author:      book&.author || "",
        location:    book&.location || "",
        description: book&.description || "",
        tag_names:   book ? (book.tags || []).map { |t| t["name"] || t[:name] } : []
      },
      errors: {},
      is_submitting: false
    }
  end

  def component_mounted
    # may gods forgive this workaround
    desc_el = refs[:description_input]
    if desc_el
      JS.eval("(function(el, val) { el.value = val; })").call(desc_el, state[:book][:description].to_s)
    end

    el = refs[:tag_select]
    return unless el && JS.global[:TomSelect]

    init_fn = JS.eval(<<~JS)
      (function(el) {
        if (el.tomselect) return;
        new TomSelect(el, {
          valueField: 'name',
          labelField: 'name',
          searchField: 'name',
          persist: false,
          createOnBlur: true,
          create: true,
          load: function(query, callback) {
            fetch('/tags.json?q=' + encodeURIComponent(query))
              .then(function(r) { return r.json(); })
              .then(function(json) { callback(json); })
              .catch(function() { callback(); });
          }
        });
      })
    JS
    init_fn.call(el)
  end

  def handle_submit(form_data)
    selected_tags = read_selected_tags
    file_input    = refs[:image_input]
    has_file      = file_input && JS.eval("(function(el) { return !!(el && el.files && el.files.length > 0); })").call(file_input)

    clean_attrs = {
      title:       form_data[:title],
      author:      form_data[:author],
      location:    form_data[:location],
      description: form_data[:description],
      tag_names:   selected_tags
    }

    patch(is_submitting: true, errors: {})

    if has_file
      submit_with_image(clean_attrs, file_input)
    elsif props[:book]&.id
      props[:book].update(clean_attrs) { |updated, errors| on_save_result(updated, errors) }
    else
      Book.create(clean_attrs) { |created, errors| on_save_result(created, errors) }
    end
  end

  def submit_with_image(attrs, file_input)
    is_edit = !props[:book]&.id.nil?
    url     = is_edit ? "/books/#{props[:book].id}.json" : "/books.json"
    method  = is_edit ? "PATCH" : "POST"

    # Listen for completion via DOM CustomEvent (supported natively by PicoRuby)
    file_input.addEventListener("upload-success") do |event|
      book_id = event[:detail][:id].to_s
      Funicular.router.navigate(routes.book_path(book_id))
    end

    file_input.addEventListener("upload-error") do |event|
      err_msg = event[:detail][:message].to_s
      patch(is_submitting: false, errors: { base: [err_msg] })
    end

    upload_fn = JS.eval(<<~JS)
      (function(url, method, title, author, location, description, tagNamesJoined, inputEl) {
        var fd = new FormData();
        fd.append("book[title]", title);
        fd.append("book[author]", author);
        fd.append("book[location]", location);
        fd.append("book[description]", description);

        if (inputEl && inputEl.files && inputEl.files[0]) {
          fd.append("book[image]", inputEl.files[0]);
        }

        if (tagNamesJoined && tagNamesJoined.length > 0) {
          var tags = tagNamesJoined.split("|||");
          for (var i = 0; i < tags.length; i++) {
            fd.append("book[tag_names][]", tags[i]);
          }
        }

        var csrfEl = document.querySelector('meta[name="csrf-token"]');
        var csrf = csrfEl ? csrfEl.getAttribute('content') : '';

        fetch(url, {
          method: method,
          headers: { 'X-CSRF-Token': csrf, 'Accept': 'application/json' },
          body: fd
        })
        .then(function(res) {
          return res.json().then(function(data) {
            if (res.ok) {
              inputEl.dispatchEvent(new CustomEvent('upload-success', { detail: { id: String(data.id) } }));
            } else {
              inputEl.dispatchEvent(new CustomEvent('upload-error', { detail: { message: JSON.stringify(data.errors || data) } }));
            }
          });
        })
        .catch(function(err) {
          inputEl.dispatchEvent(new CustomEvent('upload-error', { detail: { message: String(err) } }));
        });
      })
    JS

    upload_fn.call(
      url,
      method,
      attrs[:title].to_s,
      attrs[:author].to_s,
      attrs[:location].to_s,
      attrs[:description].to_s,
      (attrs[:tag_names] || []).join("|||"),
      file_input
    )
  end

  def on_save_result(record, errors)
    if record
      Funicular.router.navigate(routes.book_path(record.id))
    elsif errors.respond_to?(:messages)
      patch(is_submitting: false, errors: errors.messages)
    else
      patch(is_submitting: false, errors: { base: [errors.to_s] })
    end
  end

  def read_selected_tags
    el = refs[:tag_select]
    return state[:book][:tag_names] unless el

    joined = JS.eval("(function(el) { return Array.from(el.selectedOptions).map(function(o) { return o.value; }).join('|||'); })").call(el).to_s
    joined.empty? ? [] : joined.split("|||")
  end

  def render
    existing_tags = state[:book][:tag_names] || []

    form_for(:book, on_submit: :handle_submit) do |f|
      if state[:errors][:base]
        div(class: "error") do
          ul do
            Array(state[:errors][:base]).each { |msg| li { msg } }
          end
        end
      end

      div do
        f.label(:title)
        f.text_field(:title, autofocus: true)
      end

      div do
        f.label(:author)
        f.text_field(:author)
      end

      div(class: "mb-3") do
        f.label(:location)
        f.text_field(:location)
      end

      div do
        f.label(:description)
        f.textarea(:description, ref: :description_input)
      end

      div do
        f.label(:image)
        f.file_field(:image, accept: "image/*", ref: :image_input)
      end

      div do
        f.label(:tag_names) { "Tags" }
        select(ref: :tag_select, multiple: true, id: "book-tag-select") do
          existing_tags.each do |name|
            option(value: name, selected: true) { name }
          end
        end
      end

      div(class: "actions") do
        f.submit(
          state[:is_submitting] ? "Saving..." : "Save Book",
          class: "btn btn-primary",
          disabled: state[:is_submitting]
        )
      end
    end
  end
end