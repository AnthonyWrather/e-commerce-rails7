// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

declare global {
  interface Window {
    dataLayer: any[];
    gtag: Gtag.Gtag;
  }
}

document.addEventListener("turbo:load", (_event: Event) => {
  const gaMetaTag = document.querySelector<HTMLMetaElement>("meta[name='google-analytics-id']");

  if (gaMetaTag) {
    console.log('Got Google ID');
    window.dataLayer = window.dataLayer || [];

    function gtag(...args: any[]): void {
      window.dataLayer.push(args);
    }

    gtag('js', new Date());
    gtag('config', gaMetaTag.content);
  }
});
