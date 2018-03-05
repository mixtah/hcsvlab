class ContributionMapping < ActiveRecord::Base
  belongs_to :contribution
  belongs_to :item
  belongs_to :document

  validates :contribution, presence: true
  validates :item, presence: true
  validates :document, presence: true

  # validates :contribution_id, uniqueness: {scope: :document_id}
  validates :contribution_id, uniqueness: {scope: :document_id}

  attr_accessible :contribution_id, :item_id, :document_id
end
