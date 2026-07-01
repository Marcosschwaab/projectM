class OkrCycle < ApplicationRecord
  belongs_to :organization
  has_many :objectives, dependent: :destroy
  has_many :key_results, through: :objectives
  validates :title, presence: true
  enum :status, { draft: 0, active: 1, completed: 2, cancelled: 3 }, default: :draft

  def overall_progress
    return 0 if objectives.empty?
    (objectives.map(&:calculate_progress).sum / objectives.size).round(1)
  end

  def objectives_completed
    objectives.count { |o| o.calculate_progress >= 100 }
  end

  def krs_achieved
    key_results.count { |kr| kr.calculate_progress >= 100 }
  end

  def kr_count
    key_results.size
  end
end
