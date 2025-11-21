import { Controller } from "@hotwired/stimulus"

interface Product {
  id: number
  name: string
  price: number
}

interface Stock {
  size: string
  price: number
  amount: number
}

interface MessageOptions {
  type?: 'error' | 'alert' | 'success'
}

// Connects to data-controller="products"
export default class extends Controller {
  static values = {
    size: String,
    product: Object,
    stock: Array,
    messageTimeout: { default: 2.5 * 1000, type: Number }
  }

  declare sizeValue: string
  declare readonly productValue: Product
  declare readonly stockValue: Stock[]
  declare readonly messageTimeoutValue: number

  addToCart(): void {
    console.log("product: ", this.productValue)
    // If Size is set then get the Price from Stock
    let price = 0
    if (this.sizeValue) {
      const stockIndex = this.stockValue.findIndex(item => item.size === this.sizeValue)
      price = this.stockValue[stockIndex].price
    } else {
      price = this.productValue.price
    }

    const cartData = localStorage.getItem("cart")
    if (cartData) {
      const cartArray = JSON.parse(cartData)
      const foundIndex = cartArray.findIndex((item: any) => item.id === this.productValue.id && item.size === this.sizeValue)
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

  selectSize(e: Event): void {
    // TODO: Need to do this properly.
    const target = e.target as HTMLButtonElement
    this.sizeValue = target.value
    const selectedSizeEl = document.getElementById("selected-size")
    if (selectedSizeEl) {
      selectedSizeEl.innerText = `Selected Size: ${this.sizeValue}`
    }

    const selectedButtonTextEl = document.getElementById(target.id)
    if (selectedButtonTextEl) {
      const myPrice = selectedButtonTextEl.innerText.split("£")
      const selectedPriceEl = document.getElementById("product-price")
      if (myPrice[1]) {
        if (selectedPriceEl) {
          selectedPriceEl.innerText = `£${myPrice[1]}`
        }
        const selectedPriceExVatEl = document.getElementById("product-price-exvat")
        if (selectedPriceExVatEl) {
          selectedPriceExVatEl.innerText = `Ex VAT £${(parseFloat(myPrice[1]) / 1.2).toFixed(2)}`
        }
      } else {
        if (selectedPriceEl) {
          selectedPriceEl.innerText = "Out of stock."
        }
      }
    }

    const addToCartButton = document.getElementById("add-to-cart-button") as HTMLButtonElement | null
    if (addToCartButton) {
      addToCartButton.disabled = false
      addToCartButton.classList.remove("invisible")
    }
  }

  addMessage(content: { message: string }, { type: _type = "error" }: MessageOptions = {}): void {
    const flashContainer = document.getElementById("flash");
    if (!flashContainer) return;

    const template = flashContainer.querySelector("[data-template]") as HTMLTemplateElement | null;
    if (!template) return;

    const node = template.content.firstElementChild?.cloneNode(true) as HTMLElement;
    const valueElement = node.querySelector("[data-value]");
    if (valueElement) {
      valueElement.textContent = content.message;
    }

    flashContainer.append(node);

    // optional - add timeout to remove after 2.5 seconds
    window.setTimeout(() => {
      node.remove();
    }, this.messageTimeoutValue);
  }

  formatCurrency(price: number): string {
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
