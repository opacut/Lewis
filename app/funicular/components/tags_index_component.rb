class TagsIndexComponent < ApplicationComponent
  def initialize_state
    { tags: [], loading: true, error: nil }
  end

  def component_mounted
    @alive = true
    Tag.all do |tags, error|
      next unless @alive
      error ? patch(error: error, loading: false) : patch(tags: tags, loading: false)
    end
  end

  def component_unmounted
    @alive = false
  end

  def handle_delete(tag)
    return unless JS.global.confirm("Are you sure?")

    tag.destroy do |_ok, error|
      next unless @alive
      if error
        patch(error: "Could not delete tag: #{error}")
      else
        patch(tags: state[:tags].reject { |t| t.id == tag.id })
      end
    end
  end

  def render
    div do
      h1 { "All Tags" }
      p(class: "error") { state[:error] } if state[:error]

      if state[:loading]
        p { "Loading tags..." }
      else
        ul do
          state[:tags].each do |tag|
            li do
              span { "#{tag.name} " }
              a(
                href: "#",
                onclick: ->(e) { e.prevent_default; handle_delete(tag) }
              ) { "Delete" }
            end
          end
        end
      end

      link_to routes.books_path, navigate: true do
        span { "Back to books" }
      end
    end
  end
end