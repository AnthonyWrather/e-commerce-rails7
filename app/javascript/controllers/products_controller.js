import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static values = {
    size: String,
    product: Object,
    stock: Array,
    messageTimeout: { default: 2.5 * 1000, type: Number }
  }

  addToCart() {
    console.log("product: ", this.productValue)
    // If Size is set then get the Price from Stock
    let price = 0
    if (this.sizeValue) {
      const stockIndex = this.stockValue.findIndex(item => item.size === this.sizeValue)
      price = this.stockValue[stockIndex].price
    } else {
      price = this.productValue.price
    }

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
          price: price,
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
        price: price,
        size: this.sizeValue,
        quantity: 1
      })
      localStorage.setItem("cart", JSON.stringify(cartArray))
    }
    this.addMessage({ message: `${this.productValue.name} added to basket.` }, { type: 'alert' });
  }

  selectSize(e) {
    // TODO: Need to do this properly.
    this.sizeValue = e.target.value
    const selectedSizeEl = document.getElementById("selected-size")
    selectedSizeEl.innerText = `Selected Size: ${this.sizeValue}`

    const selectedButtonTextEl = document.getElementById(e.target.id)
    const myPrice = selectedButtonTextEl.innerText.split("£")
    const selectedPriceEl = document.getElementById("product-price")
    if (myPrice[1]) {
      selectedPriceEl.innerText = `£${myPrice[1]}`
      const selectedPriceExVatEl = document.getElementById("product-price-exvat")
      selectedPriceExVatEl.innerText = `Ex VAT £${(myPrice[1] / 1.2).toFixed(2)}`
    } else {
      selectedPriceEl.innerText = "Out of stock."
    }

    const addToCartButton = document.getElementById("add-to-cart-button")
    addToCartButton.disabled = false
    addToCartButton.classList.remove("invisible")
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

  formatCurrency(price) {
    // TODO: I think this is better done with events.
    const unit = "£";
    const separator = ".";
    const delimiter = ",";

    // Convert price to a float value and format to two decimal places
    let number = (price / 100.0).toFixed(2);

    // Split the number into integer and decimal parts
    let [integerPart, decimalPart] = number.split(".");

    // Add thousands delimiter
    integerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, delimiter);

    // Combine integer part and decimal part with separator
    return `${unit}${integerPart}${separator}${decimalPart}`;
  }
}
