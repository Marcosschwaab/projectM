class Webhook < ApplicationRecord
  belongs_to :organization
  has_many :deliveries, class_name: "WebhookDelivery", dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true, format: { with: /\Ahttps:\/\/.+\z/, message: "must be a valid HTTPS URL" }
  validates :events, presence: true
  validate :url_not_private

  class JsonOrYamlCoder
    def self.dump(obj)
      JSON.dump(obj)
    end

    def self.load(data)
      return [] if data.blank?

      JSON.parse(data)
    rescue JSON::ParserError
      YAML.safe_load(data) || []
    end
  end

  serialize :events, coder: JsonOrYamlCoder

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

  def url_not_private
    return unless url.present?

    host = URI.parse(url).host
    return if host.blank?

    private_patterns = [
      /\A127\./, /\A10\./, /\A172\.(1[6-9]|2\d|3[01])\./, /\A192\.168\./,
      /\Alocalhost\z/i, /\A::1\z/, /\A0\.0\.0\.0\z/
    ]

    if private_patterns.any? { |p| host.match?(p) }
      errors.add(:url, "cannot point to a private network address")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "is not a valid URL")
  end

  def generate_secret
    self.secret ||= SecureRandom.hex(32)
  end
end
