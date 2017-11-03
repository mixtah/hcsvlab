class Document < ActiveRecord::Base

  belongs_to :item, inverse_of: :documents
  has_many :document_audits, dependent: :destroy, inverse_of: :documents
  has_one :contribution_mappings, dependent: :destroy

end