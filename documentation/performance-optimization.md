# Performance Optimization Guide

This document describes the performance optimizations implemented in this application.

## Overview

The following optimizations are in place to ensure fast page loads and good Lighthouse scores:

## 1. Gzip Compression

**Implementation**: `config/application.rb`

The application uses `Rack::Deflater` middleware to compress all text-based responses (HTML, CSS, JS, JSON) using Gzip compression. This reduces bandwidth and improves load times.

```ruby
config.middleware.use Rack::Deflater
```

**Note**: Brotli compression is typically handled at the CDN/reverse proxy level (e.g., Cloudflare) for better compression ratios.

## 2. JavaScript Bundle Optimization

**Implementation**: `package.json`

The JavaScript bundle has been optimized through:

### Minification
All JavaScript is minified in production builds using esbuild's `--minify` flag.

### Code Splitting
Chart.js is dynamically imported only on admin dashboard pages where it's needed. This reduces the main bundle from ~762KB to ~145KB.

```json
{
  "build": "esbuild ... --minify --splitting --format=esm ..."
}
```

### Bundle Sizes
| Bundle | Size |
|--------|------|
| Main application.js | ~145KB (minified) |
| Chart.js chunk | ~200KB (loaded only on admin pages) |

### ES Modules
The application uses ES modules (`type="module"`) for better tree-shaking and code-splitting support.

## 3. WebP Image Variants

**Implementation**: `app/models/product.rb`, `app/models/category.rb`

Active Storage variants include WebP formats for modern browsers:

```ruby
has_many_attached :images do |attachable|
  attachable.variant :thumb, resize_to_limit: [50, 50]
  attachable.variant :thumb_webp, resize_to_limit: [50, 50], format: :webp
  attachable.variant :medium, resize_to_limit: [250, 250]
  attachable.variant :medium_webp, resize_to_limit: [250, 250], format: :webp
end
```

To use WebP variants in views, you can use the `picture` element for browser fallback:

```erb
<picture>
  <source srcset="<%= url_for(product.images.first.variant(:medium_webp)) %>" type="image/webp">
  <img src="<%= url_for(product.images.first.variant(:medium)) %>" alt="...">
</picture>
```

## 4. Lazy Loading Images

**Implementation**: `app/helpers/application_helper.rb`

A helper method is available for lazy loading images:

```ruby
def lazy_image_tag(source, options = {})
  options[:loading] ||= 'lazy'
  options[:decoding] ||= 'async'
  image_tag(source, options)
end
```

Use `lazy_image_tag` instead of `image_tag` for below-the-fold images:

```erb
<%= lazy_image_tag(product.images.first, class: "rounded") %>
```

This uses native browser lazy loading (`loading="lazy"`) and async decoding (`decoding="async"`).

## 5. Font Loading Optimization

The Inter font is loaded with `font-display: swap`, which:
- Shows a fallback font immediately
- Swaps to Inter when it's loaded
- Prevents invisible text (FOIT)

This is handled automatically by the `tailwindcss-rails` gem.

## 6. CDN Configuration (Cloudflare)

For production deployments, we recommend using Cloudflare CDN:

### Setup Steps

1. **Add your domain to Cloudflare**
   - Sign up at cloudflare.com
   - Add your domain and update nameservers

2. **Enable Brotli Compression**
   - Speed → Optimization → Brotli: ON

3. **Configure Caching**
   - Caching → Configuration → Caching Level: Standard
   - Browser Cache TTL: 4 hours (or higher)

4. **Enable Asset Optimization**
   - Speed → Optimization:
     - Auto Minify: JS, CSS, HTML
     - Rocket Loader: OFF (conflicts with Turbo)

5. **Configure Page Rules (optional)**
   ```
   *.example.com/assets/*
   - Cache Level: Cache Everything
   - Edge Cache TTL: 1 month
   ```

### Rails Configuration

Set the asset host in production:

```ruby
# config/environments/production.rb
config.asset_host = ENV['CDN_HOST'] # e.g., 'cdn.example.com'
```

## Performance Budget

| Metric | Target | Current |
|--------|--------|---------|
| JavaScript Bundle | < 400KB | ~145KB ✅ |
| First Contentful Paint | < 1.8s | Measure with Lighthouse |
| Largest Contentful Paint | < 2.5s | Measure with Lighthouse |
| Cumulative Layout Shift | < 0.1 | Measure with Lighthouse |
| Total Blocking Time | < 200ms | Measure with Lighthouse |

## Lighthouse Audit

Run a Lighthouse audit to verify performance:

1. Open Chrome DevTools (F12)
2. Go to "Lighthouse" tab
3. Select "Performance" and "Desktop"
4. Click "Analyze page load"

Target: Lighthouse Performance score > 90

## Additional Recommendations

### For Future Optimization

1. **Service Worker**: Add offline support and caching
2. **Resource Hints**: Add `preconnect` for external origins
3. **Critical CSS**: Inline above-the-fold CSS
4. **Image Optimization**: Consider using a dedicated image CDN (Cloudinary, imgix)
5. **Database Queries**: Use eager loading to prevent N+1 queries

### Monitoring

- Use Chrome DevTools Performance tab for profiling
- Monitor Core Web Vitals in Google Search Console
- Use Real User Monitoring (RUM) for production metrics
