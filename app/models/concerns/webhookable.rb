module Webhookable
  extend ActiveSupport::Concern

  included do
    after_create_commit :dispatch_webhooks_for_create
    after_update_commit :dispatch_webhooks_for_update
  end

  private

  def dispatch_webhook_event(event, payload)
    organization.webhooks.active.each do |webhook|
      next unless webhook.events.include?(event)

      WebhookDeliveryJob.perform_later(webhook, event, payload)
    end
  end

  def webhook_payload_base
    {
      organization_id: organization.id,
      data: serialized_for_webhook,
      timestamp: Time.current.iso8601
    }
  end

  def serialized_for_webhook
    raise NotImplementedError
  end
end
