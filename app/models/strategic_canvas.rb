class StrategicCanvas < ApplicationRecord
  belongs_to :project

  validates :goal, presence: true
end
