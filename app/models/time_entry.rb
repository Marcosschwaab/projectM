class TimeEntry < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :started_at, presence: true
  validate :ended_at_after_started_at, if: -> { ended_at.present? }

  scope :running, -> { where(ended_at: nil) }
  scope :stopped, -> { where.not(ended_at: nil) }
  scope :recent, -> { order(started_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :since, ->(date) { where("started_at >= ?", date) }
  scope :until, ->(date) { where("started_at <= ?", date) }

  def running?
    ended_at.nil?
  end

  def calculated_duration
    if duration.present?
      duration
    elsif ended_at.present?
      ((ended_at - started_at) / 60).round
    else
      ((Time.current - started_at) / 60).round
    end
  end

  def duration_hours
    (calculated_duration.to_f / 60).floor
  end

  def duration_minutes
    calculated_duration % 60
  end

  def formatted_duration
    h = duration_hours
    m = duration_minutes
    if h > 0
      "#{h}h #{m}m"
    else
      "#{m}m"
    end
  end

  def stop!
    update!(ended_at: Time.current, duration: calculated_duration)
  end

  private

  def ended_at_after_started_at
    if ended_at <= started_at
      errors.add(:ended_at, :after_started_at)
    end
  end
end
