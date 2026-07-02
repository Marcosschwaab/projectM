class CustomField < ApplicationRecord
  FIELD_TYPES = %w[text number date select].freeze

  belongs_to :organization
  has_many :custom_field_values, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }
  validates :options, presence: true, if: :select_type?

  def select_type?
    field_type == "select"
  end
end
