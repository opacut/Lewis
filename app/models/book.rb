class Book < ApplicationRecord
    attribute :location, :string, default: "home"
    has_one_attached :image
    scope :search_name, ->(query) { where("title LIKE ?", "%#{query}%") }
    
    # attempting multiple filters
    scope :search_author, ->(query) { where("author LIKE ?", "%#{query}%") }
    scope :location, ->(query) { where("location LIKE ?", "%#{query}%")}

    has_and_belongs_to_many :tags

    scope :with_tags, ->(names) {
      joins(:tags)
        .where(tags: { name: names })
        .distinct
    }

    # Accept an array of tag names or IDs from the form
    def tag_names=(names)
        self.tags = names.reject(&:blank?).map do |name|
            Tag.where(name: name.strip.downcase).first_or_create!
        end
    end

    def tag_names
        tags.map(&:name)
    end
end
