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

### 2.1 Update Dependencies
- [ ] Update `Gemfile`:
  - [ ] Remove `gem "sprockets-rails"`
  - [ ] Add `gem "propshaft"`
- [ ] Run `bundle install`
- [ ] Update `.gitignore` to include `public/assets/` if not already there

### 2.2 Update Configuration Files
- [ ] Remove `config/initializers/assets.rb` (Propshaft doesn't use it)
- [ ] Update `config/application.rb`:
  - [ ] Remove `require "sprockets/railtie"` (line 15)
- [ ] Update `config/environments/production.rb`:
  - [ ] Remove or comment out `config.assets.compile = false`
  - [ ] Remove or comment out any `config.assets.*` settings
- [ ] Update `config/environments/development.rb`:
  - [ ] Remove or comment out `config.assets.debug = true`
  - [ ] Remove or comment out `config.assets.quiet = true`

### 2.3 Reorganize Assets
- [ ] Move precompiled Bootstrap JS from manual precompile list (no longer needed with Propshaft)
- [ ] Verify `app/assets/builds/` is still being used for CSS output from cssbundling-rails
- [ ] Ensure `app/assets/images/` contains all images
- [ ] Ensure `app/javascript/` contains all JS files

### 2.4 Update Asset References
- [ ] Check `app/views/layouts/application.html.erb`:
  - [ ] `stylesheet_link_tag "application"` should work as-is
  - [ ] `javascript_importmap_tags` should work as-is
- [ ] Search for any `asset_path` or `image_url` helpers and verify they work
- [ ] Check for any JavaScript files that reference assets

### 2.5 Update Build Process
- [ ] Update `package.json` scripts if needed (CSS bundling should still work)
- [ ] Update `Procfile.dev` if needed (should work as-is with css watcher)
- [ ] Test asset compilation: `rails assets:precompile`
- [ ] Verify compiled assets are in `public/assets/`

### 2.6 Test Asset Loading
- [ ] Clear `public/assets/`: `rm -rf public/assets`
- [ ] Precompile assets: `RAILS_ENV=production rails assets:precompile`
- [ ] Start production mode locally: `RAILS_ENV=production rails server`
- [ ] Verify all assets load correctly:
  - [ ] Stylesheets (Bootstrap, custom CSS)
  - [ ] JavaScript (Stimulus controllers, Turbo)
  - [ ] Images (logo, favicons)
- [ ] Test in development mode:
  - [ ] Start dev server with `bin/dev`
  - [ ] Verify hot reloading of CSS still works
  - [ ] Verify JavaScript changes are reflected

### 2.7 Deployment
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
- [ ] Restore `config/initializers/assets.rb`
- [ ] Restore `require "sprockets/railtie"` in `config/application.rb`
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
