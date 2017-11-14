class Document < ActiveRecord::Base

  belongs_to :item, inverse_of: :documents
  has_many :document_audits, dependent: :destroy

  def destroy
    # check contribution_mappings
    ContributionMapping.find_by_document_id(self.id).destroy

    FileUtils.rm_f(self.file_path)

    super
  end

end