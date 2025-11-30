import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

interface MessageData {
  message?: string
  typing?: boolean
  sender_id?: number
  sender_type?: string
}

interface MessageOptions {
  type?: 'success' | 'error' | 'alert'
}

export default class extends Controller {
  static targets = ["messages", "input", "form", "typingIndicator", "messageTemplate"]
  static values = {
    conversationId: Number,
    currentUserId: Number,
    currentUserType: String,
    messageTimeout: { type: Number, default: 3500 }
  }

  declare readonly messagesTarget: HTMLElement
  declare readonly inputTarget: HTMLInputElement
  declare readonly formTarget: HTMLFormElement
  declare readonly typingIndicatorTarget: HTMLElement
  declare readonly hasMessageTemplateTarget: boolean
  declare readonly messageTemplateTarget: HTMLTemplateElement

  declare conversationIdValue: number
  declare currentUserIdValue: number
  declare currentUserTypeValue: string
  declare messageTimeoutValue: number

  subscription: ReturnType<typeof consumer.subscriptions.create> | null = null
  typingTimeout: number | null = null

  connect(): void {
    this.subscribeToConversation()
    this.scrollToBottom()
  }

  disconnect(): void {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }
  }

  subscribeToConversation(): void {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "ConversationChannel",
        conversation_id: this.conversationIdValue
      },
      {
        received: (data: MessageData) => {
          if (data.message) {
            this.appendMessage(data.message)
          }
          if (data.typing && data.sender_id !== this.currentUserIdValue) {
            this.showTypingIndicator()
          }
        }
      }
    )
  }

  sendMessage(event: Event): void {
    event.preventDefault()

    const content = this.inputTarget.value.trim()
    if (!content || !this.subscription) return

    this.subscription.perform("speak", { message: content })
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  handleTyping(): void {
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }

    if (this.subscription) {
      this.subscription.perform("typing", {})
    }

    this.typingTimeout = window.setTimeout(() => {
      // Stop typing indicator after 3 seconds
    }, 3000)
  }

  appendMessage(messageHTML: string): void {
    this.messagesTarget.insertAdjacentHTML("beforeend", messageHTML)
    this.scrollToBottom()
  }

  showTypingIndicator(): void {
    this.typingIndicatorTarget.classList.remove("hidden")
    setTimeout(() => {
      this.typingIndicatorTarget.classList.add("hidden")
    }, 3000)
  }

  scrollToBottom(): void {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  addMessage(content: { message: string }, options: MessageOptions = {}): void {
    if (!this.hasMessageTemplateTarget) return

    const template = this.messageTemplateTarget
    const clone = template.content.cloneNode(true) as DocumentFragment
    const messageEl = clone.querySelector('.message-content')
    if (messageEl) {
      messageEl.textContent = content.message
    }

    document.body.appendChild(clone)
    setTimeout(() => {
      const alerts = document.querySelectorAll('.fixed.top-20.right-4')
      alerts.forEach(alert => alert.remove())
    }, this.messageTimeoutValue)
  }
}
