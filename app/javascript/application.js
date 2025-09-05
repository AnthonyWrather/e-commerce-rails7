// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", (event) => {
  if(document.querySelector("meta[name='google-analytics-id']")) {
    console.log('Got Google ID')
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', document.querySelector("meta[name='google-analytics-id']").content);
  }
})
