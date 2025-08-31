import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
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
            price = `£${item.price/100.0}`,
            size = `${item.size}`,
            quantity = `${item.quantity}`
      const tr = table_body.insertRow();

      const td_name = tr.insertCell();
      td_name.appendChild(document.createTextNode(name));
      td_name.style.border = '1px solid black';

      const td_price = tr.insertCell();
      td_price.appendChild(document.createTextNode(price));
      td_price.style.border = '1px solid black';

      const td_size = tr.insertCell();
      td_size.appendChild(document.createTextNode(size));
      td_size.style.border = '1px solid black';

      const td_quantity = tr.insertCell();
      td_quantity.appendChild(document.createTextNode(quantity));
      td_quantity.style.border = '1px solid black';

      const deleteButton = document.createElement("button")
      deleteButton.innerText = "Remove"
      console.log("item.id: ", item.id)
      deleteButton.value = JSON.stringify({id: item.id, size: item.size})
      deleteButton.classList.add("bg-gray-500", "rounded", "text-white", "px-2", "py-1", "ml-2")
      deleteButton.addEventListener("click", this.removeFromCart)

      const td_button = tr.insertCell();
      td_button.appendChild(deleteButton);
      td_button.style.border = '1px solid black';
    }

    const totalEl = document.createElement("div")
    totalEl.classList.add("text-white")
    totalEl.innerText= `Total: £${total/100.0}`
    let totalContainer = document.getElementById("total")
    totalContainer.appendChild(totalEl)
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
            const errorEl = document.createElement("div")
            errorEl.innerText = `There was an error processing your order. ${body.error}`
            let errorContainer = document.getElementById("errorContainer")
            errorContainer.appendChild(errorEl)
          })
        }
      })
  }

}

