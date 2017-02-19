require 'rails_helper'

describe Attachment do
  describe "attachment test" do
    it "should have thumbnail icon according to ext" , :focus => true do
      file_name = "abc.jpg"
      icon = Attachment.file_icon(file_name)
      expect(icon).to eq "jpg"

      file_name = "abc"
      icon = Attachment.file_icon(file_name)
      expect(icon).to eq "jpg"


    end
  end




end
