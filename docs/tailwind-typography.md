# Tailwind Typography & Rendered Markdown

## Problem

After migrating from Bootstrap to Tailwind CSS v4, rendered markdown content
lost all visual structure — lists appeared as plain lines with no bullets or
indentation, headings rendered at body text size, and links had no color or
underline. The HTML itself was correct (proper `<ul>`, `<h2>`, `<a>` tags), but
Tailwind's **Preflight** CSS reset strips all browser-default element styles,
so nothing was making them visually distinct.

The view (`app/views/notes/show.html.erb`) wraps rendered markdown in:

```html
<div class="rendered-markdown prose max-w-none">…</div>
```

The `prose` class comes from the **`@tailwindcss/typography`** plugin, which is
designed exactly for this situation — it re-applies opinionated, readable
typographic styles to HTML content you don't control (e.g. markdown rendered to
HTML). Without the plugin registered, `prose` is an unknown class and does
nothing.

## Current Workaround

A hand-written `.rendered-markdown` CSS block in
`app/assets/tailwind/application.css` (marked `BEGIN/END rendered-markdown
styles`) restores the most important browser defaults: list styles and
indentation, heading sizes and weights, link color and underline, paragraph
spacing, etc.

## Future: Switch to `@tailwindcss/typography`

The proper long-term fix is to install and vendor `@tailwindcss/typography` the
same way DaisyUI is vendored in `app/assets/tailwind/vendor/`.

### Steps

1. **Download the plugin build.** The standalone Tailwind v4 binary loads
   plugins as ES modules (`.mjs`). You can build or obtain
   `@tailwindcss/typography` as a single `.mjs` file and place it at
   `app/assets/tailwind/vendor/typography.mjs`.

   A quick way with `npx`:
   ```bash
   node -e "
     import('@tailwindcss/typography').then(m => {
       require('fs').writeFileSync(
         'app/assets/tailwind/vendor/typography.mjs',
         '// @tailwindcss/typography\nexport default ' + JSON.stringify(m.default)
       );
     });
   "
   ```
   Or just copy the bundled output from `node_modules/@tailwindcss/typography/dist/`.

2. **Register the plugin** in `app/assets/tailwind/application.css`:
   ```css
   @plugin "./vendor/typography.mjs";
   ```

3. **Remove the workaround block** (marked `BEGIN/END rendered-markdown styles`)
   from `application.css` — `prose max-w-none` on the wrapper div will take
   over.

4. **Keep** the `rendered-markdown` class on the div if you want to scope any
   custom overrides on top of `prose`.

### Why it's better

- Covers more elements (tables, `kbd`, `figcaption`, nested blockquotes, etc.)
- Maintained upstream alongside Tailwind
- Supports dark mode via `prose-invert`
- Configurable via CSS variables
