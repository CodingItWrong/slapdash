# Debug: Search Filter Not Working

## Symptom

Typing in the search box on the notes index page does not narrow the list.

## Root Cause

Two separate issues compound:

### 1. Bootstrap class leftover (fixed)

`app/javascript/controllers/filter_controller.js` was toggling `d-none` (a Bootstrap utility) to hide non-matching items. After the Tailwind migration `d-none` is not in the CSS, so items never disappeared. **Fixed** by changing it to `hidden` (Tailwind equivalent).

### 2. importmap-rails / Propshaft digest mismatch (open)

After running `rails assets:clobber` (which deleted `public/assets/.manifest.json`), importmap-rails and Propshaft start computing file digests independently using different algorithms. They produce different hashes for the same file, so the URL in the importmap 404s.

- Importmap-rails generates: `filter_controller-bf17f3e3.js` → **404**
- Propshaft computes:          `filter_controller-ba5f4e83.js` → **200**

When `public/assets/.manifest.json` exists (after `assets:precompile`), both tools read from it and agree on all paths. Without the manifest they diverge.

## Investigation Notes

- `window.Stimulus` is present and the `filter` controller is registered.
- The browser never executes the controller because the JS file 404s.
- Confirmed by evaluating the importmap in-page and `curl`-ing both hash variants.
- The mismatch only appeared after `assets:clobber` was run to fix an earlier stale-cache problem.

## Suggested Next Steps

1. **Quickest local fix** — run `bin/rails assets:precompile` to regenerate `public/assets/.manifest.json`. Both tools will read the manifest and agree on paths. (`public/assets` is gitignored, so this is a local dev step only.)

2. **Investigate gem versions** — check whether there is a known importmap-rails + Propshaft incompatibility in the current versions that causes the divergence even without `assets:clobber`.

3. **Verify fix in Playwright** — once JS loads, type in the search box and confirm non-matching list items are hidden.
