class Invitation < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true

  enum :role, { member: 0, manager: 1, admin: 2 }

  validates :email, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :pending, -> { where(accepted: [ nil, false ]).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where(accepted: [ nil, false ]).where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }

  def accept!
    update!(accepted: true)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  private

  def generate_token
    self.token ||= SecureRandom.hex(16)
  end
end
