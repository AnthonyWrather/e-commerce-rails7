# frozen_string_literal: true

class Address < ApplicationRecord
  has_paper_trail

  belongs_to :user

  validates :label, presence: true, length: { maximum: 50 }
  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :line1, presence: true, length: { maximum: 255 }
  validates :line2, length: { maximum: 255 }, allow_blank: true
  validates :city, presence: true, length: { maximum: 100 }
  validates :county, length: { maximum: 100 }, allow_blank: true
  validates :postcode, presence: true
  validates :country, presence: true, length: { maximum: 100 }
  validates :phone, format: { with: /\A[\d\s+\-()]+\z/, message: 'only allows numbers, spaces, and +/-()' },
                    allow_blank: true

  validate :validate_uk_postcode

  before_save :ensure_single_primary

  scope :primary_address, -> { where(primary: true) }
  scope :by_label, ->(label) { where(label: label) }

  UK_POSTCODE_REGEX = /\A([A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}|GIR\s?0AA)\z/i

  def make_primary!
    transaction do
      user.addresses.where(primary: true).update_all(primary: false)
      update!(primary: true)
    end
  end

  def formatted_address
    [full_name, line1, line2, city, county, postcode, country].compact_blank.join(', ')
  end

  private

  def validate_uk_postcode
    return if postcode.blank?
    return if country.present? && country != 'United Kingdom'

    normalized = postcode.to_s.gsub(/\s+/, ' ').strip.upcase
    return if normalized.match?(UK_POSTCODE_REGEX)

    errors.add(:postcode, 'is not a valid UK postcode format')
  end

  def ensure_single_primary
    return unless primary? && primary_changed?

    user.addresses.where.not(id: id).update_all(primary: false)
  end
end
