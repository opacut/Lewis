class Tag < ApplicationRecord
  has_and_belongs_to_many :books
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  before_save :downcase_name

  private

  def downcase_name
    self.name = name.strip.downcase
  end
end