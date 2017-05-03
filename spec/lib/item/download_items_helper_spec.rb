require 'spec_helper'
require "#{Rails.root}/lib/item/download_items_helper.rb"
require 'tempfile'
require 'fileutils'

DOCUMENT_FILENAMES = ['document.txt', 'document.wav', 'sample-plain.txt', 'sample-raw.txt', 'audio-doc.mp3']

def test_document_filter(glob_pattern, expected_files)
  expect(Item::DownloadItemsHelper.filter_item_files(DOCUMENT_FILENAMES, glob_pattern)).to eq expected_files
end

describe 'filter_item_files' do
  describe 'filter item files using a specific glob pattern' do
    it 'should return all files with the glob *' do
      test_document_filter('*', DOCUMENT_FILENAMES)
    end

    it 'should only return files matching an ending with glob pattern' do
      test_document_filter('*.txt', ['document.txt', 'sample-plain.txt', 'sample-raw.txt'])
      test_document_filter('*.wav', ['document.wav'])
    end

    it 'should only return files matching a starting with glob pattern' do
      test_document_filter('sample-*', ['sample-plain.txt', 'sample-raw.txt'])
    end

    it 'should only return files matching a glob union pattern' do
      test_document_filter('{*.wav}', ['document.wav'])
      test_document_filter('{*.mp3,*.wav}', ['document.wav', 'audio-doc.mp3'])
    end

    it 'should return files corresponding to an exact filename' do
      test_document_filter('document.txt', ['document.txt'])
    end
  end
end

describe "filter tmp download files to be removed according to filename" do
  it 'should return correct result according to tmp file' 's timestamp' do
    i_true_timestamp = Time.now.getutc.to_i - APP_CONFIG['download_expired_time'].to_i*60*60 - 1
    i_false_timestamp = Time.now.getutc.to_i - 100

    # create tmp file for test
    tmp_false_file = Tempfile.new('false.test')
    tmp_true_file = Tempfile.new('true.test')
    File.utime(File.atime(tmp_true_file.path), i_true_timestamp, tmp_true_file.path)

    expected_true_filenames = ["aaa_#{i_true_timestamp}.tmp", tmp_true_file.path]

    expected_false_filenames = [nil, "bbb_#{i_false_timestamp}.tmp", tmp_false_file.path]

    expected_true_filenames.each do |filename|
      expect(Item::DownloadItemsHelper.filter_expired_tmp_files(filename)).to be_true
    end

    expected_false_filenames.each do |filename|
      expect(Item::DownloadItemsHelper.filter_expired_tmp_files(filename)).to be_false
    end

    tmp_true_file.close
    tmp_false_file.close
  end

  it "should delete files match" do
    #   create test file
    test_file_delete = File.new(FileUtils.touch(File.join(APP_CONFIG['download_tmp_dir'], "delete.me")).first)
    test_file_remain = File.new(FileUtils.touch(File.join(APP_CONFIG['download_tmp_dir'], "save.me")).first)

    i_true_timestamp = Time.now.getutc.to_i - APP_CONFIG['download_expired_time'].to_i*60*60 - 1
    File.utime(File.atime(test_file_delete.path), i_true_timestamp, test_file_delete.path)

    # run function
    Item::DownloadItemsHelper.tmp_dir_cleaning

    filenames = Dir[File.join(APP_CONFIG['download_tmp_dir'], "*")].select {|f| File.file?(f)}

    # expect test_file_delete gone
    expect(filenames.include? test_file_delete.path).to be_false

    # expect test_file_remain remain
    expect(filenames.include? test_file_remain.path).to be_true

    #   remove test file
    File.delete(test_file_remain)

  end
end

