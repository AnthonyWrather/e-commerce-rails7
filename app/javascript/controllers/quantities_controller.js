import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="quantities"
export default class extends Controller {
  static values = {
  }

  connect() {
  }

  greet() {
    this.outputTarget.textContent = "Hello from Stimulus!";
  }

  static targets = ["output"]
}
