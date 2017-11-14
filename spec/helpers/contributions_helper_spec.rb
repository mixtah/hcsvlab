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

  let!(:owner) {FactoryGirl.create(:user_data_owner)}
  let!(:collection) {FactoryGirl.create(:collection, owner: owner)}
  let!(:item) {FactoryGirl.create(:item, collection: collection)}
  let!(:doc_1) {FactoryGirl.create(:document, item: item, file_name: "Rodney.wav")}
  let!(:doc_2) {FactoryGirl.create(:document, item: item, file_name: "Isaac.wav")}
  let!(:doc_3) {FactoryGirl.create(:document, item: item, file_name: "Phoebe.wav")}
  let!(:contribution) {FactoryGirl.create(:contribution, collection: collection)}

  after do
    FileUtils.rm_r(APP_CONFIG["contrib_dir"])
    FileUtils.mkdir_p(APP_CONFIG["contrib_dir"])
  end

  describe "test entry_names_from_zip" do
    context "when zip file contains validated file" do
      it "returns entry names from zip file" do
        zip_file = "test/samples/contributions/contrib_doc.zip"
        rlt = ContributionsHelper.entry_names_from_zip(zip_file)

        expect(rlt.is_a?(Array)).to be_true
      end
    end

    context "when zip file is invalid or damaged" do
      it "raises exception" do
        zip_file = "test/samples/austalk.n3"
        rlt = ContributionsHelper.entry_names_from_zip(zip_file)
        expect(rlt).to eq("Zip end of central directory signature not found")
      end
    end

    context "when zip file is not found" do
      it "raises exception" do
        zip_file = "test/samples/contributions/contrib_doc.zip.not_exists"
        rlt = ContributionsHelper.entry_names_from_zip(zip_file)
        expect(rlt).to end_with("not found")
      end
    end
  end

  describe "test preview_import" do

    context "when zip contains all good files" do
      it "returns all success" do
        #   prepare zip
        src = "test/samples/contributions/contrib_doc.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.preview_import(contribution)

        rlt.each do |row|
          expect(row[:message].nil?).to be_true
        end
      end
    end

    context "when zip contains bad file" do
      it "returns error result" do
        #   prepare zip
        src = "test/samples/contributions/contrib_doc.error.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.preview_import(contribution)

        error_duplicated_doc = false
        error_not_found = false

        rlt.each do |row|
          if !row[:message].nil? && row[:message].include?("can't find existing document associated with")
            error_not_found = true
          end

          if !row[:message].nil? && row[:message].include?("duplicated document file")
            error_duplicated_doc = true
          end
        end

        expect(error_not_found).to be_true
        expect(error_duplicated_doc).to be_true

      end
    end
  end

  describe "test unzip" do

    after do
      #   clean up
      zip_file = ContributionsHelper.contribution_import_zip_file(contribution)
      unzip_dir = File.join(File.dirname(zip_file), File.basename(zip_file, ".zip"))
      FileUtils.rm_r unzip_dir
    end

    context "with valid zip file" do
      let(:src) {"test/samples/contributions/contrib_doc.zip"}
      let(:dest) {ContributionsHelper.contribution_import_zip_file(contribution)}

      it "returns array of file full path" do
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)
        rlt = ContributionsHelper.unzip(dest)

        if rlt.is_a? String

          rlt.each do |f|
            expect(File.exists?(f[:dest_name])).to be_true
          end

        end
      end

      # context "with invalid zip file" do
      #   it "returns error message" do
      #
      #   end
      # end
    end
  end

  describe "test import" do
    context "when zip is not present" do
      it "returns zip file not found" do
        rlt = ContributionsHelper.import(contribution)

        puts rlt

        expect(rlt.end_with?("not found")).to be_true
      end
    end

    context "when zip is present and valid" do
      it "returns string message indicates success" do
        src = "test/samples/contributions/contrib_doc.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.import(contribution)
        puts rlt.inspect
        expect(rlt.end_with?("document(s) imported.")).to be_true
      end
    end

    context "when zip is error" do
      it "returns string message indicates failure" do
        src = "test/samples/contributions/contrib_doc.error.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.import(contribution)
        puts rlt.inspect
        expect(rlt.start_with?("import failed")).to be_true
      end
    end
  end

  describe "test contribution_dir" do
    context "when contribution is valid" do
      it "returns valid directory" do
        dir = File.join(APP_CONFIG["contrib_dir"], contribution.collection.name, contribution.id.to_s)
        rlt = ContributionsHelper.contribution_dir(contribution)

        expect(rlt).to eq(dir)
      end
    end

    context "when contribution is nil" do
      it "returns nil" do
        contribution = nil
        rlt = ContributionsHelper.contribution_dir(contribution)

        expect(rlt.nil?).to be_true
      end
    end

    context "when contribution is invalid, collection is nil" do
      it "returns nil" do
        contribution.collection = nil
        rlt = ContributionsHelper.contribution_dir(contribution)

        expect(rlt.nil?).to be_true
      end
    end
  end

end
