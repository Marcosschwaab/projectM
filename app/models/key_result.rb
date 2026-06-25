class KeyResult < ApplicationRecord
  belongs_to :objective

  validates :title, presence: true

  def calculate_progress
    return 0 if target_value.blank? || target_value.zero?
    ((current_value.to_f / target_value.to_f) * 100).round(2)
  end
end
