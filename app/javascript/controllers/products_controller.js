import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static values = {
    size: String,
    product: Object,
    messageTimeout: { default: 2.5 * 1000, type: Number }
  }

  addToCart() {
    console.log("product: ", this.productValue)
    const cart = localStorage.getItem("cart")
    if (cart) {
      const cartArray = JSON.parse(cart)
      const foundIndex = cartArray.findIndex(item => item.id === this.productValue.id && item.size === this.sizeValue)
      if (foundIndex >= 0) {
        cartArray[foundIndex].quantity = parseInt(cartArray[foundIndex].quantity) + 1
      } else {
        cartArray.push({
          id: this.productValue.id,
          name: this.productValue.name,
          price: this.productValue.price,
          size: this.sizeValue,
          quantity: 1
        })
      }
      localStorage.setItem("cart", JSON.stringify(cartArray))
    } else {
      const cartArray = []
      cartArray.push({
        id: this.productValue.id,
        name: this.productValue.name,
        price: this.productValue.price,
        size: this.sizeValue,
        quantity: 1
      })
      localStorage.setItem("cart", JSON.stringify(cartArray))
    }
    this.addMessage({ message: `${this.productValue.name} added to basket.` }, { type: 'alert' });
  }

  selectSize(e) {
    this.sizeValue = e.target.value
    const selectedSizeEl = document.getElementById("selected-size")
    selectedSizeEl.innerText = `Selected Size: ${this.sizeValue}`

    const selectedButtonTextEl = document.getElementById(e.target.id)
    const myPrice = selectedButtonTextEl.innerText.split("£")
    const selectedPriceEl = document.getElementById("product-price")
    if (myPrice[1]) {
      selectedPriceEl.innerText = `£${myPrice[1]}`
    } else {
      selectedPriceEl.innerText = "Out of stock."
    }
  }

  addMessage(content, { type = "error" } = {}) {
    const flashContainer = document.getElementById("flash");
    if (!flashContainer) return;

    const template = flashContainer.querySelector("[data-template]");
    const node = template.content.firstElementChild.cloneNode(true);
    node.querySelector("[data-value]").innerText = content.message;

    flashContainer.append(node);

    // optional - add timeout to remove after 2.5 seconds
    window.setTimeout(() => {
      node.remove();
    }, this.messageTimeoutValue);
  }
}
