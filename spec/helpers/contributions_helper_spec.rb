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
describe ContributionsHelper do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe "it should return entry names from zip file" do
    it "when zip file contains validated file" do
      zip_file = "/Users/mq20146034/Downloads/idea-multimarkdown.2.3.8.zip"
      ContributionsHelper.entry_names_from_zip(zip_file)
    end
  end

end
