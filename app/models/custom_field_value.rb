class CustomFieldValue < ApplicationRecord
  belongs_to :custom_field
  belongs_to :customizable, polymorphic: true

  validates :value, presence: true, if: -> { custom_field&.required? }
  validate :value_matches_field_type, if: -> { custom_field.present? && value.present? }

  private

  def value_matches_field_type
    case custom_field.field_type
    when "number"
      errors.add(:value, :not_a_number) unless numeric_value?
    when "date"
      errors.add(:value, :invalid_date) unless valid_date?
    when "select"
      unless custom_field.options.include?(value)
        errors.add(:value, :not_in_options)
      end
    end
  end

  def numeric_value?
    Float(value)
    true
  rescue ArgumentError, TypeError
    false
  end

  def valid_date?
    Date.parse(value.to_s)
    true
  rescue ArgumentError
    false
  end
end
