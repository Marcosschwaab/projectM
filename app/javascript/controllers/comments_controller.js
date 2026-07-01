import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["list"]
  static values = { taskId: Number }

  connect() {
    this.subscribeToChannel()
  }

  disconnect() {
    this.unsubscribe()
  }

  subscribeToChannel() {
    if (!this.hasTaskIdValue) return
    this.subscription = consumer.subscriptions.create(
      { channel: "CommentsChannel", task_id: this.taskIdValue },
      {
        received: (data) => {
          this.listTarget.insertAdjacentHTML("beforeend", data.html)
        }
      }
    )
  }

  unsubscribe() {
    if (this.subscription) {
      consumer.subscriptions.remove(this.subscription)
    }
  }
}
