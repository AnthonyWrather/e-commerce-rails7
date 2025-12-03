// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

declare global {
  interface Window {
    dataLayer: any[];
    gtag: Gtag.Gtag;
    Honeybadger: HoneybadgerClient | undefined;
  }
}

interface HoneybadgerClient {
  notify: (error: Error | string, options?: Record<string, unknown>) => void;
  setContext: (context: Record<string, unknown>) => void;
  configure: (options: Record<string, unknown>) => void;
  resetContext: (context?: Record<string, unknown>) => void;
  clear: () => void;
  beforeNotify: (callback: (notice: Record<string, unknown>) => boolean | void) => void;
}

interface UserContext {
  id: number | null;
  email: string | null;
  type: 'admin' | 'user' | 'guest';
}

let honeybadgerInitialized = false;

function getUserContext(): UserContext | null {
  const userContextMeta = document.querySelector<HTMLMetaElement>("meta[name='honeybadger-user-context']");
  if (!userContextMeta?.content) return null;

  try {
    return JSON.parse(userContextMeta.content) as UserContext;
  } catch {
    return null;
  }
}

function initializeHoneybadger(): void {
  if (honeybadgerInitialized) return;

  const honeybadgerApiKey = document.querySelector<HTMLMetaElement>("meta[name='honeybadger-api-key']")?.content;
  if (!honeybadgerApiKey || !window.Honeybadger) return;

  const honeybadgerEnv = document.querySelector<HTMLMetaElement>("meta[name='honeybadger-environment']")?.content;
  const userContext = getUserContext();

  window.Honeybadger.configure({
    apiKey: honeybadgerApiKey,
    environment: honeybadgerEnv || 'production',
    revision: document.querySelector<HTMLMetaElement>("meta[name='honeybadger-revision']")?.content
  });

  if (userContext) {
    window.Honeybadger.setContext({
      user_id: userContext.id,
      user_email: userContext.email,
      user_type: userContext.type
    });
  }

  window.addEventListener('error', (event: ErrorEvent) => {
    if (window.Honeybadger && event.error) {
      window.Honeybadger.notify(event.error, {
        context: {
          url: window.location.href,
          userAgent: navigator.userAgent
        }
      });
    }
  });

  window.addEventListener('unhandledrejection', (event: PromiseRejectionEvent) => {
    if (window.Honeybadger) {
      const error = event.reason instanceof Error ? event.reason : new Error(String(event.reason));
      window.Honeybadger.notify(error, {
        context: {
          type: 'unhandledrejection',
          url: window.location.href
        }
      });
    }
  });

  honeybadgerInitialized = true;
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

  initializeHoneybadger();
});
