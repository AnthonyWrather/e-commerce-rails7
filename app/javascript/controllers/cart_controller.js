import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
  static values = {
    messageTimeout: { default: 3.5 * 1000, type: Number }
  }

  initialize() {

    console.log("cart controller initialized")
    const cart = JSON.parse(localStorage.getItem("cart"))
    if (!cart) {
      return
    }

    let total = 0
    const table_body = document.getElementById("table_body")
    for (let i=0; i < cart.length; i++) {
      const item = cart[i]
      total += item.price * item.quantity
      const name = `${item.name}`,
            price = `${this.formatCurrency(item.price)}`,
            size = `${item.size}`,
            quantity = `${item.quantity}`
      const tr = table_body.insertRow();

      const td_name = tr.insertCell();
      td_name.appendChild(document.createTextNode(name));
      td_name.style.border = '1px solid black';

      const td_size = tr.insertCell();
      td_size.appendChild(document.createTextNode(size));
      td_size.style.border = '1px solid black';

      const td_price = tr.insertCell();
      td_price.appendChild(document.createTextNode(price));
      td_price.style.border = '1px solid black';
      td_price.style.textAlign = 'right';

      const td_price_exvat = tr.insertCell();
      td_price_exvat.appendChild(document.createTextNode(this.formatCurrency(item.price/1.2)));
      td_price_exvat.style.border = '1px solid black';
      td_price_exvat.style.textAlign = 'right';
      td_price_exvat.style.color = 'black';

      const td_quantity = tr.insertCell();
      td_quantity.appendChild(document.createTextNode(quantity));
      td_quantity.style.border = '1px solid black';
      td_quantity.style.textAlign = 'right';

      const td_price_total = tr.insertCell();
      td_price_total.appendChild(document.createTextNode(this.formatCurrency(item.price * item.quantity)));
      td_price_total.style.border = '1px solid black';
      td_price_total.style.textAlign = 'right';

      const deleteButton = document.createElement("button")
      deleteButton.innerText = "Remove"
      console.log("item.id: ", item.id)
      deleteButton.value = JSON.stringify({id: item.id, size: item.size})
      deleteButton.classList.add("bg-red-500", "hover:bg-red-600", "rounded", "text-white", "px-2", "py-1", "ml-2")
      deleteButton.addEventListener("click", this.removeFromCart)

      const td_button = tr.insertCell();
      td_button.appendChild(deleteButton);
      td_button.style.border = '1px solid black';
    }

    const totalEl = document.createElement("div")
    totalEl.classList.add("text-white")
    totalEl.innerText= `Invoice Total (Inc VAT): ${this.formatCurrency(total)}`
    let totalContainer = document.getElementById("total")
    totalContainer.appendChild(totalEl)

    const totalExvatEl = document.createElement("div")
    totalExvatEl.classList.add("text-white")
    totalExvatEl.innerText= `Invoice Total (Ex VAT): ${this.formatCurrency(total/1.2)}`
    totalContainer.appendChild(totalExvatEl)

    const totalVatEl = document.createElement("div")
    totalVatEl.classList.add("text-white")
    totalVatEl.innerText= `Total VAT @20%: ${this.formatCurrency(total - (total/1.2))}`
    totalContainer.appendChild(totalVatEl)
  }

  clear() {
    localStorage.removeItem("cart")
    window.location.reload()
  }

  removeFromCart(event) {
    const cart = JSON.parse(localStorage.getItem("cart"))
    const values = JSON.parse(event.target.value)
    const {id, size} = values
    const index = cart.findIndex(item => item.id === id && item.size === size)
    if (index >= 0) {
      cart.splice(index, 1)
    }
    localStorage.setItem("cart", JSON.stringify(cart))
    window.location.reload()
  }

  checkout() {
    const cart = JSON.parse(localStorage.getItem("cart"))
    const payload = {
      authenticity_token: "",
      cart: cart
    }

    const csrfToken = document.querySelector("[name='csrf-token']").content

    fetch("/checkout", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(payload)
    }).then(response => {
        if (response.ok) {
          response.json().then(body => {
            window.location.href = body.url
          })
        } else {
          response.json().then(body => {
            this.addMessage({ message: `There was an error processing your order. ${body.error}` }, { type: 'alert' });
          })
        }
      })
  }

  addMessage(content, { type = "error" } = {}) {
    console.log("addMessage")
    const flashContainer = document.getElementById("flash");
    if (!flashContainer) return;

    const template = flashContainer.querySelector("[data-template]");
    const node = template.content.firstElementChild.cloneNode(true);
    node.querySelector("[data-value]").innerText = content.message;

    flashContainer.append(node);

    // optional - add timeout to remove after 3.5 seconds
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

