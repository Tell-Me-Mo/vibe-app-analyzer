# 📋 GitHub Pages Launch Checklist

## Pre-Launch (15 minutes)

### 1. Enable GitHub Pages
- [ ] Go to repository Settings → Pages
- [ ] Set Source: Branch `main`, Folder `/docs`
- [ ] Click Save
- [ ] Note the deployment URL

### 2. Update URLs in Files

**In `index.html`:**
- [ ] Replace `https://yourdomain.github.io/vibe-app-analyzer/` with actual URL (6 locations)
- [ ] Update `https://app.vibecheck.dev` with real app URL (3 locations)
- [ ] Update GitHub links in footer

**In `sitemap.xml`:**
- [ ] Replace placeholder URL with actual URL

**In `robots.txt`:**
- [ ] Update Sitemap URL

**In `CNAME` (if using custom domain):**
- [ ] Add your custom domain OR delete file if using github.io

### 3. Add Images (CRITICAL for social media)

**OG Image** (1200x630px PNG - REQUIRED for social sharing):
- [ ] Convert `og-image.svg` to PNG using [Canva](https://canva.com), Figma, or:
  ```bash
  # Using ImageMagick (if installed)
  convert og-image.svg -resize 1200x630 og-image.png
  ```
- [ ] OR create custom image at [Canva](https://canva.com) (search "Open Graph Image")
- [ ] Optimize with [TinyPNG](https://tinypng.com)
- [ ] Delete og-image.svg after creating PNG

**Favicon** (DONE):
- [x] Inline SVG favicon already added to HTML (displays "V" logo)

### 4. Test Locally

- [ ] Open `index.html` in browser
- [ ] Check mobile view (iPhone, Android sizes)
- [ ] Verify all links work
- [ ] Test smooth scrolling
- [ ] Check animations on scroll

## Launch Day (10 minutes)

### 5. Deploy

- [ ] Commit all changes: `git add docs/ && git commit -m "Add landing page"`
- [ ] Push to GitHub: `git push origin main`
- [ ] Wait 2-3 minutes for GitHub Pages to deploy
- [ ] Visit your site URL

### 6. Verify Live Site

- [ ] Homepage loads correctly
- [ ] Mobile responsive works
- [ ] No console errors (F12 → Console)
- [ ] HTTPS enabled (padlock icon)
- [ ] All navigation links work
- [ ] CTA buttons link correctly

## Post-Launch (30 minutes)

### 7. SEO Setup

- [ ] Submit to [Google Search Console](https://search.google.com/search-console)
- [ ] Add sitemap in Search Console
- [ ] Verify ownership (HTML file or DNS)
- [ ] Submit to [Bing Webmaster Tools](https://www.bing.com/webmasters)

### 8. Validate SEO

- [ ] Test with [Google Rich Results Test](https://search.google.com/test/rich-results)
- [ ] Fix any structured data errors
- [ ] Validate with [Schema Markup Validator](https://validator.schema.org/)

### 9. Social Media Cards

- [ ] Test Twitter card: [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- [ ] Test Facebook: [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- [ ] Test LinkedIn: [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/)
- [ ] Share on social media to verify cards look good

### 10. Performance

- [ ] Test with [PageSpeed Insights](https://pagespeed.web.dev/)
- [ ] Aim for 90+ score
- [ ] Fix any issues identified
- [ ] Test on [GTmetrix](https://gtmetrix.com/)

### 11. Analytics (Optional)

- [ ] Add Google Analytics or Plausible
- [ ] Test that events are tracking
- [ ] Set up goals/conversions
- [ ] Monitor traffic

## Custom Domain Setup (if applicable)

### 12. DNS Configuration

- [ ] Add CNAME record at domain provider
- [ ] Point to `yourusername.github.io`
- [ ] Wait 10-60 minutes for DNS propagation
- [ ] Verify with `dig yourdomain.com`

### 13. Enable HTTPS

- [ ] Return to GitHub Pages settings
- [ ] Wait for "DNS check successful" message
- [ ] Enable "Enforce HTTPS" checkbox
- [ ] Verify site loads with https://

## Ongoing Maintenance

### Weekly
- [ ] Check Google Search Console for errors
- [ ] Monitor page performance
- [ ] Review analytics data

### Monthly
- [ ] Update content if needed
- [ ] Check for broken links
- [ ] Review and respond to issues
- [ ] Update dependencies (if any)

## Troubleshooting

### Site not loading?
1. Check GitHub Actions tab for deployment errors
2. Verify branch and folder settings in Pages
3. Clear browser cache (Ctrl+Shift+R)
4. Wait 5-10 minutes and try again

### Images not showing?
1. Ensure images are in `/docs` folder
2. Use absolute paths or relative from `/docs`
3. Check image file extensions (case-sensitive)
4. Verify images are committed to Git

### SEO not working?
1. Submit sitemap to Google Search Console
2. Request indexing for homepage
3. Wait 3-7 days for Google to crawl
4. Build backlinks to improve ranking

### Social cards broken?
1. Verify og-image.png exists and is accessible
2. Use absolute URLs (not relative)
3. Clear social media cache with debuggers
4. Check image dimensions (1200x630px)

## Success Criteria

✅ Site loads in under 2 seconds  
✅ Mobile responsive works perfectly  
✅ SEO score 90+ on PageSpeed Insights  
✅ Social media cards preview correctly  
✅ All links functional  
✅ No console errors  
✅ HTTPS enabled  
✅ Indexed by Google (within 7 days)

---

**Estimated Total Time**: 1 hour from start to fully optimized launch

**Questions?** Open an issue on GitHub or check `SETUP_GUIDE.md` for details.
