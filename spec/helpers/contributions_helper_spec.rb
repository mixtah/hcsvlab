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
        src = "#{Rails.root}/test/samples/contributions/contrib_doc.zip"
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
      it "returns error result - not found" do
        #   prepare zip
        src = "#{Rails.root}/test/samples/contributions/contrib_doc.error.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.preview_import(contribution)

        error_not_found = false

        rlt.each do |row|
          if !row[:message].nil? && row[:message].include?("can't find existing document associated with")
            error_not_found = true
          end
        end

        expect(error_not_found).to be_true
      end

      it "returns error result - duplicated file" do
        #   prepare zip
        src = "#{Rails.root}/test/samples/contributions/contrib_doc.error.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.preview_import(contribution)

        error_duplicated_doc = false

        rlt.each do |row|
          if !row[:message].nil? && row[:message].include?("duplicated document found")
            error_duplicated_doc = true
          end
        end

        expect(error_duplicated_doc).to be_true

      end
    end

  end

  describe "test unzip" do

    let(:zip_file)  {ContributionsHelper.contribution_import_zip_file(contribution)}
    let(:unzip_dir) {File.join(File.dirname(zip_file), File.basename(zip_file, ".zip"))}

    after do
      #   clean up
      FileUtils.rm_r unzip_dir
    end

    context "with valid zip file" do
      let(:src) {"#{Rails.root}/test/samples/contributions/contrib_doc.zip"}
      let(:dest) {ContributionsHelper.contribution_import_zip_file(contribution)}

      it "returns array of file full path" do
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)
        rlt = ContributionsHelper.unzip(dest, unzip_dir)

        if !rlt.is_a? String

          rlt.each do |f|
            puts "checking [#{f[:dest_name]}]..."
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
        src = "#{Rails.root}/test/samples/contributions/contrib_doc.zip"
        dest = ContributionsHelper.contribution_import_zip_file(contribution)
        FileUtils.mkdir_p(ContributionsHelper.contribution_dir(contribution))
        FileUtils.cp(src, dest)

        rlt = ContributionsHelper.import(contribution)
        puts rlt.inspect
        expect(rlt.end_with?("document(s) imported.")).to be_true
      end
    end

    context "when zip is error" do
      it "returns string message indicates failure" do
        src = "#{Rails.root}/test/samples/contributions/contrib_doc.error.zip"
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

  describe "test next_available_name" do
    let(:contrib_id) {1}
    let(:src_file) {"test.txt"}
    let(:dest_file) {"test-c#{contrib_id}.txt"}
    let(:dest_file_2) {"test-c#{contrib_id}-c#{contrib_id}.txt"}

    context "rename: no duplicated file" do
      it "returns normal result" do
        existing_files = [
          {:name => 'not_me.txt', :contrib_id => 12},
          {:name => 'not_me_2.txt', :contrib_id => 123},
          {:name => 'not_me_3.txt', :contrib_id => nil}
        ]

        rlt = ContributionsHelper.next_available_name(contrib_id, src_file, existing_files)
        expect(rlt[:mode]).to eq("rename")
        expect(rlt[:file_name]).to eq(src_file)
      end
    end

    context "overwrite: src_file duplicated with same contribution" do
      it "returns overwrite result" do
        existing_files = [
          {:name => 'not_me.txt', :contrib_id => 12},
          {:name => src_file, :contrib_id => contrib_id},
          {:name => 'not_me_3.txt', :contrib_id => nil}
        ]

        rlt = ContributionsHelper.next_available_name(contrib_id, src_file, existing_files)
        expect(rlt[:mode]).to eq("overwrite")
        expect(rlt[:file_name]).to eq(src_file)
      end

    end

    context "rename: src_file duplicated with other contribution" do
      it "returns rename result" do
        existing_files = [
          {:name => 'not_me.txt', :contrib_id => 12},
          {:name => src_file, :contrib_id => 12},
          {:name => 'not_me_3.txt', :contrib_id => nil}
        ]

        rlt = ContributionsHelper.next_available_name(contrib_id, src_file, existing_files)
        expect(rlt[:mode]).to eq("rename")
        expect(rlt[:file_name]).to eq(dest_file)
      end
    end

    context "rename: src_file duplicated with null contribution (collection document)" do
      it "returns rename result" do
        existing_files = [
          {:name => 'not_me.txt', :contrib_id => 12},
          {:name => src_file, :contrib_id => nil},
          {:name => 'not_me_3.txt', :contrib_id => nil}
        ]

        rlt = ContributionsHelper.next_available_name(contrib_id, src_file, existing_files)
        expect(rlt[:mode]).to eq("rename")
        expect(rlt[:file_name]).to eq(dest_file)
      end
    end

    context "rename: dest_file duplicated with existing file" do
      it "returns rename result" do
        existing_files = [
          {:name => 'not_me.txt', :contrib_id => 12},
          {:name => src_file, :contrib_id => 12},
          {:name => dest_file, :contrib_id => nil}
        ]

        rlt = ContributionsHelper.next_available_name(contrib_id, src_file, existing_files)
        expect(rlt[:mode]).to eq("rename")
        expect(rlt[:file_name]).to eq(dest_file_2)
      end
    end
  end


end
