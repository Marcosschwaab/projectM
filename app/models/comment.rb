class Comment < ApplicationRecord
  include Webhookable

  belongs_to :task
  belongs_to :user

  validates :content, presence: true
  has_many_attached :files

  def organization
    task.project.organization
  end

  private

  def dispatch_webhooks_for_create
    dispatch_webhook_event("comment.created", webhook_payload_base)
  end

  def dispatch_webhooks_for_update
  end

  def serialized_for_webhook
    {
      id: id,
      content: content,
      user: user.name,
      task_id: task_id,
      task_title: task.title
    }
  end
end
