class Webhook < ApplicationRecord
  belongs_to :organization
  has_many :deliveries, class_name: "WebhookDelivery", dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true, format: { with: /\Ahttps?:\/\/.+\z/, message: "must be a valid URL" }
  validates :events, presence: true

  serialize :events, coder: YAML

  after_initialize :generate_secret, if: :new_record?

  scope :active, -> { where(active: true) }

  def event_types
    %w[task.created task.updated task.moved comment.created]
  end

  def delivery_count
    deliveries.count
  end

  def last_delivery
    deliveries.order(created_at: :desc).first
  end

  private

  def generate_secret
    self.secret ||= SecureRandom.hex(32)
  end
end
