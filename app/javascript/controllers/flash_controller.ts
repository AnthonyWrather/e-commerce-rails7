import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 5000 }
  }

  declare readonly dismissAfterValue: number
  private timeout: ReturnType<typeof setTimeout> | null = null

  connect(): void {
    this.scheduleDismiss()
  }

  disconnect(): void {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  scheduleDismiss(): void {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.dismissAfterValue)
  }

  dismiss(): void {
    this.element.classList.add('opacity-0', 'transition-opacity', 'duration-300')
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
