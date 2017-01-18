class CollectionProperty < ActiveRecord::Base
  attr_accessible :property, :value

  belongs_to :collection, dependent: :destroy

  validates :property, presence: true
  validates :value, presence: true
end
