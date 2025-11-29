import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard"
export default class extends Controller {
  static values = {
    revenue: Array,
    elementid: String
  }

  declare readonly revenueValue: Array<[string, number]>
  declare readonly elementidValue: string

  async initialize(): Promise<void> {
    const data = this.revenueValue.map((item) => item[1] / 100.0)
    const labels = this.revenueValue.map((item) => item[0])

    const ctx = document.getElementById(this.elementidValue) as HTMLCanvasElement
    
    const { Chart, registerables } = await import('chart.js')
    Chart.register(...registerables)

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Revenue £',
          data: data,
          borderWidth: 3,
          fill: true
        }]
      },
      options: {
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            }
          },
          y: {
            border: {
              dash: [5, 5]
            },
            grid: {
              color: "#d4f3ef"
            },
            beginAtZero: true
          }
        }
      }
    })
  }
}
