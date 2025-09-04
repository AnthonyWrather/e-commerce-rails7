// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", (event) => {
  // let googleId = document.querySelector("meta[name='google-analytics-id']").content
  let googleId = "G-481BNJ1GVB"
  if(googleId) {
    console.log('Got Google ID')
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', googleId);
  } else {
    console.log('No Google ID')
    let googleId = "G-481BNJ1GVB"
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', googleId);
  }
})
