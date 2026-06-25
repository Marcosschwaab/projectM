class OkrCycle < ApplicationRecord
  belongs_to :organization

  has_many :objectives, dependent: :destroy

  validates :title, presence: true

  enum :status, { draft: 0, active: 1, completed: 2, cancelled: 3 }
end
