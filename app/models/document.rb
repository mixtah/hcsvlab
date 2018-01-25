class Document < ActiveRecord::Base

  belongs_to :item, inverse_of: :documents
  has_many :document_audits, dependent: :destroy

  validates :file_name, presence: true
  validates :file_path, presence: true
  validates :item_id, presence: true

  def destroy
    # check contribution_mappings
    cm = ContributionMapping.find_by_document_id(self.id)
    if !cm.nil?
      cm.destroy
    end
    FileUtils.rm_f(self.file_path)

    super
  end

end