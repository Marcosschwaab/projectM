class Objective < ApplicationRecord
  belongs_to :okr_cycle
  belongs_to :owner, class_name: "User", optional: true

  has_many :key_results, dependent: :destroy

  validates :title, presence: true

  def calculate_progress
    return 0 if key_results.empty?
    (key_results.average(:progress) || 0).round(2)
  end
end
