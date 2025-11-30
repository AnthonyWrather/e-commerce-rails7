import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

interface PresenceData {
  admin_id: number
  status: string
  admin_name: string
}

export default class extends Controller {
  static targets = ["indicator", "count"]

  declare readonly indicatorTarget: HTMLElement
  declare readonly countTarget: HTMLElement
  declare readonly hasIndicatorTarget: boolean
  declare readonly hasCountTarget: boolean

  subscription: ReturnType<typeof consumer.subscriptions.create> | null = null
  onlineAdmins: Set<number> = new Set()

  connect(): void {
    this.subscribeToPresence()
  }

  disconnect(): void {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToPresence(): void {
    this.subscription = consumer.subscriptions.create(
      { channel: "PresenceChannel" },
      {
        received: (data: PresenceData) => {
          if (data.status === 'online') {
            this.onlineAdmins.add(data.admin_id)
          } else {
            this.onlineAdmins.delete(data.admin_id)
          }
          this.updateIndicator()
        }
      }
    )
  }

  updateIndicator(): void {
    const count = this.onlineAdmins.size

    if (this.hasCountTarget) {
      this.countTarget.textContent = count.toString()
    }

    if (this.hasIndicatorTarget) {
      if (count > 0) {
        this.indicatorTarget.classList.add("bg-green-500")
        this.indicatorTarget.classList.remove("bg-gray-400")
      } else {
        this.indicatorTarget.classList.add("bg-gray-400")
        this.indicatorTarget.classList.remove("bg-green-500")
      }
    }
  }
}
