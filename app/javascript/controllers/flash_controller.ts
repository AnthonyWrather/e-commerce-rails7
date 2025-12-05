import { Controller } from "@hotwired/stimulus"

const ANIMATION_DURATION_MS = 300
const DEFAULT_DISMISS_AFTER_MS = 3000

export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: DEFAULT_DISMISS_AFTER_MS }
  }

  declare readonly dismissAfterValue: number
  private timeout: ReturnType<typeof setTimeout> | null = null

  connect(): void {
    this.scheduleDismiss()
    // Remove flash messages before Turbo caches the page to prevent them from reappearing
    document.addEventListener('turbo:before-cache', this.removeBeforeCache)
  }

  disconnect(): void {
    this.clearTimeout()
    document.removeEventListener('turbo:before-cache', this.removeBeforeCache)
  }

  scheduleDismiss(): void {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.dismissAfterValue)
  }

  dismiss(): void {
    this.clearTimeout()
    this.element.classList.add('opacity-0', 'transition-opacity', 'duration-300')
    setTimeout(() => {
      this.element.remove()
    }, ANIMATION_DURATION_MS)
  }

  // Arrow function to preserve 'this' context.
  // Uses immediate removal without animation because turbo:before-cache
  // is a synchronous event - the page snapshot is taken immediately after,
  // so animation would not complete before caching occurs.
  private removeBeforeCache = (): void => {
    this.clearTimeout()
    this.element.remove()
  }

  private clearTimeout(): void {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }
}
