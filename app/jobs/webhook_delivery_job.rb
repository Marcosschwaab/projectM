class WebhookDeliveryJob < ApplicationJob
  queue_as :default

  def perform(webhook, event, payload)
    payload_with_event = payload.merge(event: event)

    body = payload_with_event.to_json
    signature = OpenSSL::HMAC.hexdigest("SHA256", webhook.secret, body)

    uri = URI.parse(webhook.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["X-Webhook-Signature"] = signature
    request["X-Webhook-Event"] = event
    request.body = body

    response = http.request(request)

    webhook.deliveries.create!(
      status: response.code.to_i,
      response: response.body.to_s
    )
  rescue => e
    webhook.deliveries.create!(
      status: 0,
      error: e.message
    )
  end
end
