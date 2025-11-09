# VibeCheck Landing Page

This directory contains the GitHub Pages landing page for VibeCheck.

## 🚀 Setup GitHub Pages

### 1. Enable GitHub Pages

1. Go to your repository settings
2. Navigate to **Pages** section
3. Under **Source**, select:
   - Branch: `main` (or your default branch)
   - Folder: `/docs`
4. Click **Save**

### 2. Custom Domain (Optional)

If you have a custom domain:

1. Edit the `CNAME` file and add your domain:
   ```
   vibecheck.dev
   ```
2. Configure DNS records at your domain provider:
   - Add a CNAME record pointing to `yourusername.github.io`
3. Enable **Enforce HTTPS** in GitHub Pages settings

### 3. Update URLs

Replace placeholder URLs in `index.html`:

- Line 10: Update canonical URL
- Line 14-16: Update Open Graph URLs
- Line 19-21: Update Twitter Card URLs
- All instances of `https://yourdomain.github.io/vibe-app-analyzer/`

Also update `sitemap.xml` with your actual domain.

## 📊 SEO Features

### Implemented Optimizations

✅ **Structured Data (JSON-LD)**
- SoftwareApplication schema for AI discoverability
- FAQPage schema for featured snippets
- Rich snippets for search results

✅ **Meta Tags**
- Open Graph (Facebook, LinkedIn)
- Twitter Cards
- Proper title, description, keywords

✅ **AI Crawler Support**
- Optimized for ChatGPT, Claude, Gemini
- Semantic HTML structure
- Question-answer format in FAQ schema

✅ **Performance**
- Inline CSS (no external requests)
- Minimal JavaScript
- Responsive images (when added)
- Fast loading time

✅ **Accessibility**
- Semantic HTML5
- ARIA labels
- Proper heading hierarchy
- Color contrast compliance

## 🎨 Design Features

- **Dark theme** with glassmorphism effects
- **Mobile-responsive** design (desktop, tablet, mobile)
- **Smooth animations** and scroll effects
- **Modern 2025 aesthetics** with gradients and glass effects
- **Single clear CTA** for conversion optimization

## 📱 Testing

Test the responsive design at:
- Desktop: 1920px+
- Tablet: 768px - 1024px
- Mobile: 375px - 767px

Test SEO with:
- [Google Rich Results Test](https://search.google.com/test/rich-results)
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)

## 🔧 Customization

### Colors

Edit CSS variables in `index.html` (around line 100):

```css
:root {
    --bg-primary: #0a0a0f;
    --accent-primary: #6366f1;
    /* ... more variables */
}
```

### Content

Update the following sections:
- Hero headline and description
- Features grid (6 feature cards)
- How It Works steps (4 steps)
- Pricing tiers (3 packages)
- Footer links

### App Link

Replace `https://app.vibecheck.dev` with your actual app URL.

## 📈 Analytics (Recommended)

Add Google Analytics or Plausible Analytics:

```html
<!-- Add before </head> -->
<script defer data-domain="yourdomain.com" src="https://plausible.io/js/script.js"></script>
```

## 🌐 Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 📄 Files

- `index.html` - Main landing page
- `robots.txt` - Search engine crawler instructions
- `sitemap.xml` - Sitemap for SEO
- `CNAME` - Custom domain configuration
- `.nojekyll` - Disable Jekyll processing
- `404.html` - Custom 404 error page

## 🚨 Before Going Live

- [ ] Replace all placeholder URLs
- [ ] Update CNAME with your domain (or delete if using github.io)
- [ ] Add actual app URL links
- [ ] Test on mobile devices
- [ ] Validate structured data
- [ ] Test social media cards
- [ ] Add favicon and OG image
- [ ] Enable HTTPS in GitHub Pages settings

## 📞 Support

For issues or questions, open an issue in the GitHub repository.
