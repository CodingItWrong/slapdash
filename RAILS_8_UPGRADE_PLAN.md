# Rails 8 Upgrade Plan

Implementation plan for upgrading to Rails 8.0 defaults, Propshaft, and Thruster.

## Phase 1: Rails 8.0 Configuration Defaults ✅ Ship to Production

**Goal:** Update to Rails 8.0 defaults to get modern framework improvements.

### 1.1 Update Configuration Defaults
- [x] Update `config/application.rb`: Change `config.load_defaults 7.0` to `config.load_defaults 8.0`
- [x] Run `rails app:update` to see what new configurations are available (checked - keeping existing config)
- [x] Review the Rails 8.0 upgrade guide for any breaking changes (no breaking changes found)
- [x] Check for deprecation warnings: `RAILS_ENV=test bundle exec rails test` or `bundle exec rspec`

### 1.2 Test Configuration Changes
- [x] Run full test suite: `bundle exec rspec` (all 25 tests passing)
- [x] Rails environment loads successfully with 8.0 defaults
- [ ] Start development server and manually test key flows (ready for you to test):
  - [ ] User sign up/sign in
  - [ ] Creating/editing/deleting notes
  - [ ] Navigation and Turbo interactions
- [ ] Check browser console for JavaScript errors
- [ ] Verify CSS is loading correctly

### 1.3 Deployment
- [ ] Commit changes: `git add -A && git commit -m "Update to Rails 8.0 configuration defaults"`
- [ ] Deploy to production
- [ ] Monitor logs for errors
- [ ] Verify production app is working correctly

---

## Phase 2: Switch to Propshaft 🚀 Ship to Production

**Goal:** Replace Sprockets with Propshaft for modern asset pipeline.

**Important:** Propshaft only changes how assets are *served*, not how CSS is *built*.
- `cssbundling-rails` gem stays (still needed to compile SCSS → CSS)
- `package.json` build scripts stay the same (sass + postcss)
- `Procfile.dev` stays the same (still runs `yarn watch:css`)
- Only the asset serving mechanism changes (Sprockets → Propshaft)

### 2.1 Update Dependencies
- [x] Update `Gemfile`:
  - [x] Remove `gem "sprockets-rails"`
  - [x] Add `gem "propshaft"`
- [x] Run `bundle install`
- [x] Update `.gitignore` to include `public/assets/` if not already there

### 2.2 Update Configuration Files
- [x] Remove `config/initializers/assets.rb` (Propshaft doesn't use it)
- [x] Update `config/application.rb`:
  - [x] Remove `require "sprockets/railtie"` (line 15)
- [x] Update `config/environments/production.rb`:
  - [x] Remove or comment out `config.assets.compile = false`
  - [x] Remove or comment out any `config.assets.*` settings
- [x] Update `config/environments/development.rb`:
  - [x] Remove or comment out `config.assets.debug = true`
  - [x] Remove or comment out `config.assets.quiet = true`

### 2.3 Handle JavaScript Dependencies
**CRITICAL:** Propshaft can't serve files from `node_modules` like Sprockets does.

Current state (Sprockets):
- JS files (`bootstrap.min.js`, `turbo.min.js`, etc.) served from `node_modules/` via assets.rb config
- `config/initializers/assets.rb` adds node_modules paths to asset pipeline

With Propshaft (requires local copies):
- [x] Download all importmap dependencies locally:
  ```bash
  bin/importmap pin bootstrap --download
  bin/importmap pin @hotwired/turbo-rails --download
  bin/importmap pin @hotwired/stimulus --download
  bin/importmap pin @hotwired/stimulus-loading --download
  ```
- [x] Verify downloads: check `vendor/javascript/` contains all .js files
- [x] Review updated `config/importmap.rb` to confirm local paths

### 2.4 Verify Asset Structure
- [x] **IMPORTANT:** Keep `cssbundling-rails` in Gemfile - it's still needed!
- [x] Verify `app/assets/builds/` exists - cssbundling-rails outputs compiled CSS here
- [x] Check `app/assets/images/` contains all images
- [x] Check `app/assets/stylesheets/` contains your SCSS source files
- [x] Check `app/javascript/` contains all JS files
- [x] Propshaft will automatically serve everything in `app/assets/` and `vendor/javascript/`

### 2.5 Update Asset References
- [x] Check `app/views/layouts/application.html.erb`:
  - [x] `stylesheet_link_tag "application"` should work as-is
  - [x] `javascript_importmap_tags` should work as-is
- [x] Search for any `asset_path` or `image_url` helpers and verify they work
- [x] Check for any JavaScript files that reference assets

### 2.6 Verify Build Process (No Changes Needed!)
- [x] **NO CHANGES to `package.json`** - CSS build scripts stay identical:
  - `build:css:compile` - compiles SCSS with sass
  - `build:css:prefix` - runs autoprefixer with postcss
  - `build:css` - runs both steps
  - `watch:css` - watches for changes in development
- [x] **NO CHANGES to `Procfile.dev`** - still runs `yarn watch:css`
- [x] **How it works with Propshaft:**
  1. `cssbundling-rails` runs `yarn build:css` → outputs to `app/assets/builds/application.css`
  2. Propshaft picks up the compiled CSS from `app/assets/builds/`
  3. Propshaft copies all `app/assets/` files to `public/assets/` with digests
- [x] Test the full process: `rails assets:precompile` (completed - assets in public/assets/)
- [x] Verify compiled assets appear in `public/assets/` with digest fingerprints

### 2.7 Test Asset Loading
- [x] Clear `public/assets/`: `rm -rf public/assets`
- [x] Precompile assets: `RAILS_ENV=production rails assets:precompile`
- [ ] Start production mode locally: `RAILS_ENV=production rails server` (ready to test)
- [ ] Verify all assets load correctly:
  - [ ] Stylesheets (Bootstrap, custom CSS)
  - [ ] JavaScript (Stimulus controllers, Turbo)
  - [ ] Images (logo, favicons)
- [ ] Test in development mode:
  - [ ] Start dev server with `bin/dev`
  - [ ] Verify hot reloading of CSS still works
  - [ ] Verify JavaScript changes are reflected

### 2.8 Deployment
- [ ] Commit changes: `git add -A && git commit -m "Switch from Sprockets to Propshaft"`
- [ ] Ensure deployment process runs `rails assets:precompile`
- [ ] Deploy to production
- [ ] Monitor asset loading carefully:
  - [ ] Check browser network tab for 404s
  - [ ] Verify CSS styling is correct
  - [ ] Verify JavaScript functionality works
  - [ ] Check favicon and images load
- [ ] If issues occur, have rollback plan ready

---

## Phase 3: Add Thruster for Production 🚀 Ship to Production

**Goal:** Add HTTP/2 proxy server for better production performance.

### 3.1 Add Thruster Gem
- [ ] Update `Gemfile`:
  - [ ] Add `gem "thruster", require: false` to production group
- [ ] Run `bundle install`

### 3.2 Configure Thruster
- [ ] Create `config/thruster.yml` if needed for custom configuration
- [ ] Review Thruster documentation for optimal settings
- [ ] Configure caching headers if needed
- [ ] Configure X-Sendfile support if serving files

### 3.3 Update Deployment Configuration
- [ ] Determine your deployment platform (Heroku, Render, VPS, etc.)
- [ ] Update Procfile for production: `web: bundle exec thrust bin/rails server`
- [ ] Or update systemd/init scripts if using VPS
- [ ] Ensure SSL/TLS termination is configured correctly

### 3.4 Test Locally (Production Mode)
- [ ] Test Thruster locally:
  ```bash
  RAILS_ENV=production bundle exec thrust bin/rails server
  ```
- [ ] Verify HTTP/2 is working (check browser dev tools)
- [ ] Verify asset serving is fast
- [ ] Check compression is working
- [ ] Test SSL if applicable

### 3.5 Deployment
- [ ] Commit changes: `git add -A && git commit -m "Add Thruster for production HTTP/2 support"`
- [ ] Deploy to production
- [ ] Monitor performance:
  - [ ] Check response times
  - [ ] Verify HTTP/2 in production
  - [ ] Monitor server logs for any Thruster errors
  - [ ] Test asset loading speed
- [ ] Use browser dev tools to verify improvements

---

## Rollback Plans

### If Phase 1 Fails
- [ ] Revert to `config.load_defaults 7.0`
- [ ] Deploy rollback

### If Phase 2 Fails
- [ ] Add `gem "sprockets-rails"` back to Gemfile
- [ ] Remove `gem "propshaft"`
- [ ] **Keep `gem "cssbundling-rails"`** - don't remove it!
- [ ] Restore `config/initializers/assets.rb`
- [ ] Restore `require "sprockets/railtie"` in `config/application.rb`
- [ ] Restore any `config.assets.*` settings
- [ ] Run `bundle install`
- [ ] Deploy rollback

### If Phase 3 Fails
- [ ] Remove Thruster from Procfile
- [ ] Revert to standard Rails server command
- [ ] Deploy rollback

---

## Notes

- Each phase can be shipped independently
- Test thoroughly in development before each production deploy
- Monitor production closely after each deployment
- Keep rollback plans ready
- Phase 2 (Propshaft) is the riskiest - plan extra testing time
- Consider deploying Phase 2 during low-traffic hours

### Understanding the Asset Pipeline (Phase 2)

**cssbundling-rails vs Propshaft - They do different jobs:**
- `cssbundling-rails` = CSS **build** system (SCSS → CSS compilation)
- `Propshaft` = Asset **serving** system (delivers compiled assets to browsers)

**The flow:**
1. You edit `app/assets/stylesheets/*.scss` files
2. `cssbundling-rails` runs `yarn build:css` (sass + postcss)
3. Compiled CSS is output to `app/assets/builds/application.css`
4. Propshaft picks up the compiled CSS from `app/assets/builds/`
5. Propshaft copies it to `public/assets/application-[digest].css`
6. Your app serves the digested asset to users

**What changes in Phase 2:**
- ❌ Sprockets (old asset serving) → ✅ Propshaft (new asset serving)

**What stays the same:**
- ✅ cssbundling-rails (still compiles your SCSS)
- ✅ package.json scripts (sass + postcss commands)
- ✅ Procfile.dev (still runs yarn watch:css)
- ✅ app/assets/stylesheets/ (your SCSS source files)
- ✅ app/assets/builds/ (compiled CSS output)
