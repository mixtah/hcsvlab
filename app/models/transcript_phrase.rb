class TranscriptPhrase < ActiveRecord::Base

  has_no_table

  belongs_to :transcript

  has_many :words, class_name: 'TranscriptWord', dependent: :destroy

  default_scope order(:start_time)

  accepts_nested_attributes_for :words

  validates :start_time, presence: true, numericality: true
  validates :end_time, presence: true, numericality: true
  validates :phrase_id, presence: true
  validates :original, presence: true, length: {maximum: 4096}
  validates :translation, length: {maximum: 4096}
  validates :graid, length: {maximum: 4096}

  attr_accessor :transcript_id, :phrase_id, :start_time, :end_time, :original, :translation, :graid

end
