class CollectionProperty < ActiveRecord::Base
  attr_accessible :property, :value

  belongs_to :collection, inverse_of: :collection_properties

  validates :property, presence: true
  validates :value, presence: true
end
