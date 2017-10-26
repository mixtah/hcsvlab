require 'kramdown'

class Contribution < ActiveRecord::Base
  belongs_to :owner, class_name: "User"
  belongs_to :collection
  attr_accessible :description, :name

  validates :name, presence: true, uniqueness: true
  validates :owner, presence: true
  validates :collection, presence: true

  def html_text
    Kramdown::Document.new(description.nil? ? '' : description).to_html
  end
end
