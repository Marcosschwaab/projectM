class KeyResult < ApplicationRecord
  belongs_to :objective
  validates :title, presence: true

  def calculate_progress
    return 0 if target_value.blank? || target_value.zero?
    ((current_value.to_f / target_value.to_f) * 100).round(1)
  end

  def update_progress!
    update!(progress: calculate_progress)
    objective.update_progress!
  end

  def remaining
    return 0 if target_value.blank?
    [target_value - current_value.to_f, 0].max
  end
end
