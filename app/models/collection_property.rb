class CollectionProperty < ActiveRecord::Base
  attr_accessible :property, :value

  belongs_to :collection

  validates :property, presence: true
  validates :value, presence: true
end
