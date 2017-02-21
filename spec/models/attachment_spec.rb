require 'spec_helper'

describe Attachment do
  describe "attachment thumbnail " do
    context "attachment is img" do
      it "should set thumbnail as icon" do
        file_name = "abc.jpg"
        icon = Attachment::file_icon(file_name)
        # expect(icon).to eq "abc.jpg"
        icon.should eq("abc.jpg")
      end

    end

    context "attachment is not img" do
      context "but with registered file ext" do
        it "should set icon image as thumbnail according to attachment ext" do
          file_name = "abc.pdf"
          icon = Attachment::file_icon(file_name)
          # expect(icon).to eq "pdf"
          icon.should eq("/assets/fileicons/file_extension_pdf.png")
        end
      end

      context "but with unknown file ext" do
        it "should set unknown icon as thumbnail" do
          file_name = "abc.u_dont_know_me"
          icon = Attachment::file_icon(file_name)
          # expect(icon).to eq "unknown"
          icon.should eq("/assets/fileicons/file_extension_unknown.png")
        end
      end
    end
  end

end
