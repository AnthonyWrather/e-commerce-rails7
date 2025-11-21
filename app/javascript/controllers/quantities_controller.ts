import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="quantities"
export default class extends Controller {
  static values = {
  }

  static targets = ["output"]

  declare readonly outputTarget: HTMLElement

  connect(): void {
  }

  greet(): void {
    this.outputTarget.textContent = "Hello from Stimulus!";
  }
}
