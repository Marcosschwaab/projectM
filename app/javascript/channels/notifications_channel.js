import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  received(data) {
    const badges = document.querySelectorAll("[data-notification-badge]")
    badges.forEach(badge => {
      badge.textContent = data.count
      badge.classList.toggle("hidden", data.count === 0)
    })
  }
})
