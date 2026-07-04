class Risk < ApplicationRecord
  PROBABILITY_LEVELS = (1..5).freeze
  IMPACT_LEVELS = (1..5).freeze
  STATUSES = %w[identified assessing mitigating monitored closed].freeze

  belongs_to :project
  delegate :organization, to: :project
  belongs_to :owner, class_name: "User", optional: true

  validates :name, presence: true
  validates :probability, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :impact, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :by_severity, -> { order(Arel.sql("(probability * impact) DESC")) }
  scope :open, -> { where.not(status: "closed") }

  def severity
    probability * impact
  end

  def severity_label
    case severity
    when 1..3  then "low"
    when 4..6  then "medium"
    when 7..12 then "high"
    else "critical"
    end
  end

  def probability_label
    case probability
    when 1 then "very_low"
    when 2 then "low"
    when 3 then "medium"
    when 4 then "high"
    when 5 then "very_high"
    end
  end

  def impact_label
    case impact
    when 1 then "very_low"
    when 2 then "low"
    when 3 then "medium"
    when 4 then "high"
    when 5 then "very_high"
    end
  end
end