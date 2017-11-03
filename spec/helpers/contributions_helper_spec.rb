require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ContributionsHelper. For example:
#
# describe ContributionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ContributionsHelper, :type => :helper do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe "it should return entry names from zip file" do
    it "when zip file contains validated file" do
      zip_file = "/Users/mq20146034/Downloads/idea-multimarkdown.2.3.8.zip"
      ContributionsHelper.entry_names_from_zip(zip_file)
    end
  end

  describe "it should raise exception" do
    it "when zip file is invalid or damaged" do
      zip_file = "/data/collections/ace.n3"
      rlt = ContributionsHelper.entry_names_from_zip(zip_file)
      expect(rlt).to eq("Zip end of central directory signature not found")
    end

    it "when zip file is not found" do
      zip_file = "/Users/mq20146034/Downloads/idea-multimarkdown.2.3.8.zip_"
      rlt = ContributionsHelper.entry_names_from_zip(zip_file)
      expect(rlt).to end_with("not found")
    end
  end

end
