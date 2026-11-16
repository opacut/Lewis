class BookNewComponent < ApplicationComponent
  def initialize_state
    { scanning: false, scan_error: nil }
  end

  def handle_scan(e)
    e.prevent_default
    file_input = refs[:scan_photo]
    file = file_input && file_input[:files][0]
    return patch(scan_error: "Please select a photo first.") unless file

    patch(scanning: true, scan_error: nil)

    form_data = JS.global.FormData.new
    form_data.append("photo", file)

    csrf = JS.document.querySelector('meta[name="csrf-token"]')&.getAttribute("content")

    JS.global.fetch("/books/scan.json", {
      method: "POST",
      headers: { "X-CSRF-Token" => csrf, "Accept" => "application/json" },
      body: form_data
    }).then do |res|
      res.json.then do |data|
        if res[:ok]
          Funicular.router.navigate(routes.book_path(data[:id]))
        else
          err = data[:error] || (data[:errors] && data[:errors].values.flatten.join(", ")) || "Scan failed"
          patch(scanning: false, scan_error: err)
        end
      end
    end
  end

  def render
    div do
      h1 { "New book" }

      div(class: "photo-scan-section") do
        h2 { "Scan from Photo" }
        p(class: "error") { state[:scan_error] } if state[:scan_error]

        form(onsubmit: :handle_scan) do
          input(ref: :scan_photo, type: "file", accept: "image/*")
          button(type: "submit", disabled: state[:scanning]) do
            state[:scanning] ? "Scanning..." : "Scan Book"
          end
        end
      end

      h2 { "Or enter manually:" }

      component(::BookFormComponent, book: nil)

      br
      div do
        link_to routes.books_path, navigate: true do
          span { "Back to books" }
        end
      end
    end
  end
end