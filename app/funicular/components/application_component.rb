# app/funicular/components/application_component.rb
class ApplicationComponent < Funicular::Component
  def details(props = {}, &block)
    tag(:details, props, &block)
  end

  def summary(props = {}, &block)
    tag(:summary, props, &block)
  end

  def strong(props = {}, &block)
    tag(:strong, props, &block)
  end

  def i(props = {}, &block)
    tag(:i, props, &block)
  end
end