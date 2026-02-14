# Asset Pipeline Documentation

This document describes how assets (CSS, JavaScript, images) are managed, processed, and served in the Slapdash application.

## Overview

The application uses a modern Rails asset pipeline with the following key components:

- **Propshaft** - Asset serving and fingerprinting
- **Importmap-rails** - JavaScript module management without bundling
- **cssbundling-rails** - CSS compilation using external tools (Sass, PostCSS)
- **Bootstrap** - UI framework (downloaded from npm)
- **Bootstrap Icons** - Icon library (downloaded from npm)

## What's Committed to the Repository

### Source Files (Committed)

```
app/assets/
├── config/
│   └── manifest.js              # Propshaft asset manifest config
├── images/
│   └── logo-30@3x.png          # Application images
├── stylesheets/
│   ├── application.bootstrap.scss  # Main SCSS entry point
│   ├── custom.scss              # Custom styles
│   ├── overrides.scss           # Bootstrap overrides
│   └── prism.css                # Syntax highlighting styles
└── builds/
    └── .keep                    # Directory placeholder (contents ignored)

app/javascript/
├── application.js               # Main JS entry point
└── controllers/                 # Stimulus controllers
    ├── application.js
    ├── filter_controller.js
    └── index.js

vendor/javascript/
├── prism/
│   └── prism.js                 # Syntax highlighting library
├── stimulus-loading.js          # Stimulus loader
├── stimulus.min.js              # Stimulus framework
└── turbo.min.js                 # Turbo Drive/Frames

config/
└── importmap.rb                 # JavaScript import map configuration
```

### Configuration Files (Committed)

- `Gemfile` - Ruby dependencies (propshaft, importmap-rails, cssbundling-rails)
- `package.json` - Node.js dependencies and build scripts
- `config/importmap.rb` - JavaScript module mappings
- `app/assets/config/manifest.js` - Propshaft asset paths

## What's Downloaded (Not Committed)

### Downloaded from npm

```
node_modules/
├── bootstrap/                   # Bootstrap CSS framework and JS
├── bootstrap-icons/             # Bootstrap icon fonts
├── sass/                        # Sass compiler
├── postcss/                     # CSS post-processor
├── autoprefixer/                # CSS vendor prefix automation
└── nodemon/                     # File watcher for development
```

**Installed via:** `yarn install` or `npm install`

### Generated Build Artifacts (Not Committed)

```
app/assets/builds/
├── application.css              # Compiled CSS from SCSS
└── bootstrap.min.js             # Copied Bootstrap JavaScript

public/assets/
├── .manifest.json               # Propshaft digest mapping
├── application-[digest].css     # Fingerprinted CSS
├── bootstrap.min-[digest].js    # Fingerprinted Bootstrap JS
├── logo-30@3x-[digest].png     # Fingerprinted images
├── prism/
│   └── prism-[digest].js       # Fingerprinted Prism JS
└── [various other fingerprinted assets]
```

## Development Mode

### Startup Process

When you run `bin/dev`:

1. **Foreman** starts multiple processes defined in `Procfile.dev`:
   - `web` process: Rails server (`bin/rails server`)
   - `css` process: CSS watcher (`yarn watch:css`)

### CSS Processing Pipeline (Development)

```
1. Source SCSS files change in app/assets/stylesheets/
   └─> Watched by nodemon (via yarn watch:css)

2. Nodemon triggers: yarn build:css
   ├─> Step 1: Sass compilation
   │   └─> sass compiles application.bootstrap.scss → app/assets/builds/application.css
   │       • Imports Bootstrap SCSS from node_modules/bootstrap/scss/
   │       • Imports Bootstrap Icons from node_modules/bootstrap-icons/
   │       • Includes custom.scss and overrides.scss
   │       • Library: Dart Sass (sass npm package)
   │
   └─> Step 2: PostCSS processing
       └─> postcss adds vendor prefixes to app/assets/builds/application.css
           • Library: Autoprefixer (via postcss-cli)
           • Ensures cross-browser CSS compatibility

3. Propshaft serves the file
   └─> Rails helper: <%= stylesheet_link_tag "application" %>
       • Propshaft maps "application" → "application.css"
       • Served from app/assets/builds/application.css
       • NO fingerprinting in development
       • Direct file serving (no digest in filename)
```

**Key Libraries:**
- **sass** (npm) - Dart Sass compiler that processes .scss files
- **postcss-cli** (npm) - CLI tool to run PostCSS
- **autoprefixer** (npm) - PostCSS plugin that adds vendor prefixes
- **nodemon** (npm) - File watcher that triggers rebuilds

### JavaScript Processing Pipeline (Development)

```
1. Browser requests JavaScript modules
   └─> Rails helper: <%= javascript_importmap_tags %>
       • Generates importmap script tag with module mappings

2. Importmap resolves module names to paths
   └─> Config: config/importmap.rb
       • pin "application" → /assets/application.js
       • pin "bootstrap", to: "bootstrap.min.js" → /assets/bootstrap.min.js
       • pin "@hotwired/turbo-rails", to: "turbo.min.js"
       • pin "@hotwired/stimulus", to: "stimulus.min.js"
       • Library: importmap-rails gem

3. Browser uses native ES modules
   └─> import '@hotwired/turbo-rails' (in application.js)
       • Browser resolves via importmap
       • Loads from /assets/turbo.min.js
       • NO bundling, NO transpilation
       • Native browser module system

4. Propshaft serves JavaScript files
   ├─> app/javascript/**/*.js → /assets/**/*.js
   ├─> vendor/javascript/**/*.js → /assets/**/*.js
   └─> app/assets/builds/**/*.js → /assets/**/*.js
```

**Key Libraries:**
- **importmap-rails** (gem) - Generates importmap and manages JS dependencies
- **propshaft** (gem) - Serves JS files from configured asset paths
- **Browser ES Modules** - Native browser support (no build step needed)

### Image Processing (Development)

```
1. Rails view helper: <%= image_tag('logo-30@3x.png') %>

2. Propshaft resolves path
   └─> Finds: app/assets/images/logo-30@3x.png
       • Serves directly without fingerprinting
       • URL: /assets/logo-30@3x.png

3. Browser requests and caches image
   └─> No digest in development (for easier debugging)
```

### Asset Serving in Development

**Propshaft** handles all asset serving:
- Serves files from paths defined in `app/assets/config/manifest.js`
- NO fingerprinting/digesting (filenames unchanged)
- Files served directly from source locations
- Fast iteration without build step

## Production Mode

### Build Process

When deploying to production (e.g., during `rails assets:precompile`):

```
1. CSS Build: yarn build
   ├─> yarn build:css:compile
   │   └─> Sass compiles SCSS → app/assets/builds/application.css
   │       • Same process as development
   │       • --no-source-map flag (no source maps in production)
   │
   └─> yarn build:css:prefix
       └─> Autoprefixer adds vendor prefixes
           • Ensures cross-browser compatibility

2. JavaScript Build: yarn build:js
   └─> Copies Bootstrap JS: cp node_modules/bootstrap/dist/js/bootstrap.bundle.min.js
       → app/assets/builds/bootstrap.min.js
       • Pre-minified version from npm package
       • No further processing needed

3. Asset Precompilation: rails assets:precompile
   └─> Propshaft processes all assets
       ├─> Reads: app/assets/config/manifest.js
       │   • //= link_tree ../images
       │   • //= link_tree ../../javascript .js
       │   • //= link_tree ../../../vendor/javascript .js
       │   • //= link_tree ../builds
       │
       ├─> Copies files to public/assets/
       │   • Adds content digest to filenames
       │   • Example: application.css → application-8f33e7d3.css
       │   • Example: logo-30@3x.png → logo-30@3x-a508809a.png
       │
       └─> Generates: public/assets/.manifest.json
           • Maps logical names to digested paths
           • Example: {"application.css": {"digested_path": "application-8f33e7d3.css"}}
```

**Key Libraries:**
- **sass** (npm) - Compiles SCSS to CSS
- **autoprefixer** (npm) - Adds vendor prefixes
- **propshaft** (gem) - Fingerprints and copies assets to public/

### Asset Serving in Production

```
1. Rails view renders: <%= stylesheet_link_tag "application" %>

2. Propshaft helper resolves path
   └─> Reads: public/assets/.manifest.json
       • Looks up "application.css"
       • Finds digested path: "application-8f33e7d3.css"

3. Generates HTML: <link rel="stylesheet" href="/assets/application-8f33e7d3.css">

4. Web server (Nginx/CDN) serves file
   └─> Static file from public/assets/application-8f33e7d3.css
       • Content-based hash ensures cache busting
       • Aggressive caching headers (immutable content)
       • No Rails process involved
```

**Production Optimizations:**
- Fingerprinted filenames enable long-term caching (1 year+)
- Content-based digests ensure automatic cache invalidation
- Static file serving (no Ruby/Rails overhead)
- CDN-friendly (assets can be served from edge locations)

### JavaScript in Production

```
1. Rails view renders: <%= javascript_importmap_tags %>

2. Importmap helper generates script tags
   └─> <script type="importmap">
       {
         "imports": {
           "application": "/assets/application-bbf8dd8b.js",
           "bootstrap": "/assets/bootstrap.min-91dc4555.js",
           "@hotwired/turbo-rails": "/assets/turbo.min-86bf8853.js",
           ...
         }
       }
       </script>
       • Uses fingerprinted paths from Propshaft manifest

3. Browser loads and executes modules
   └─> Native ES modules with fingerprinted paths
       • Same mechanism as development
       • Fingerprinted URLs for cache busting
```

## Library Responsibilities Summary

### Ruby Gems

| Gem | Purpose | Role |
|-----|---------|------|
| **propshaft** | Asset serving & fingerprinting | Serves assets in dev, fingerprints & copies to public/ in production |
| **importmap-rails** | JavaScript module management | Generates import maps, manages JS dependencies without bundling |
| **cssbundling-rails** | CSS build integration | Provides Rake tasks (`rails css:build`) to integrate external CSS tools |
| **turbo-rails** | Hotwire Turbo integration | Provides Turbo Drive, Frames, and Streams for SPA-like navigation |
| **stimulus-rails** | Stimulus integration | Provides Stimulus framework for JavaScript controllers |

### NPM Packages

| Package | Purpose | Role |
|---------|---------|------|
| **bootstrap** | UI framework | Provides SCSS source files and pre-built JavaScript |
| **bootstrap-icons** | Icon library | Provides icon font files referenced in SCSS |
| **sass** | SCSS compiler | Compiles .scss files to .css (Dart Sass implementation) |
| **postcss** & **postcss-cli** | CSS post-processor | Runs PostCSS plugins on compiled CSS |
| **autoprefixer** | CSS vendor prefixing | PostCSS plugin that adds browser-specific CSS prefixes |
| **nodemon** | File watcher | Watches SCSS files and triggers rebuild on changes |

## Asset Workflow Summary

### Development Workflow

```
Developer edits file
    ↓
┌───────────────────────────────────────────┐
│ CSS: Nodemon watches → Sass compiles     │
│      → Autoprefixer processes             │
│      → Propshaft serves (no digest)       │
└───────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────┐
│ JS: Propshaft serves source files         │
│     → Importmap resolves module names     │
│     → Browser loads via ES modules        │
└───────────────────────────────────────────┘
    ↓
Browser loads and renders
```

### Production Build Workflow

```
Deployment triggers
    ↓
┌───────────────────────────────────────────┐
│ 1. yarn build                             │
│    • Sass compiles SCSS → CSS             │
│    • Autoprefixer processes CSS           │
│    • Copy Bootstrap JS                    │
└───────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────┐
│ 2. rails assets:precompile                │
│    • Propshaft reads manifest.js          │
│    • Fingerprints all assets              │
│    • Copies to public/assets/             │
│    • Generates .manifest.json             │
└───────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────┐
│ 3. Production serving                     │
│    • Rails helpers use manifest           │
│    • Web server serves static files       │
│    • Long-term browser caching            │
└───────────────────────────────────────────┘
```

## Common Commands

### Development

```bash
# Start dev server with CSS watching
bin/dev

# Manually rebuild CSS
yarn build:css

# Manually copy Bootstrap JS
yarn build:js

# Build all assets (CSS + JS)
yarn build
```

### Production

```bash
# Install dependencies
yarn install

# Build CSS and JS
yarn build

# Precompile and fingerprint assets
rails assets:precompile

# Clean old assets (keep last 3 versions)
rails assets:clean

# Remove all compiled assets
rails assets:clobber
```

### Importmap Management

```bash
# Add a new JavaScript package from CDN
bin/importmap pin package-name

# Update a pinned package
bin/importmap update package-name

# List all pinned packages
bin/importmap json

# Audit pinned packages for outdated versions
bin/importmap outdated
```

## File Locations Quick Reference

| Asset Type | Source Location | Build Output | Production Output |
|------------|----------------|--------------|-------------------|
| SCSS | `app/assets/stylesheets/` | `app/assets/builds/application.css` | `public/assets/application-[digest].css` |
| JS (app) | `app/javascript/` | *(none)* | `public/assets/**/*-[digest].js` |
| JS (vendor) | `vendor/javascript/` | *(none)* | `public/assets/**/*-[digest].js` |
| Bootstrap JS | `node_modules/bootstrap/` | `app/assets/builds/bootstrap.min.js` | `public/assets/bootstrap.min-[digest].js` |
| Images | `app/assets/images/` | *(none)* | `public/assets/**/*-[digest].png` |
| Manifest | - | - | `public/assets/.manifest.json` |

## Cache Busting Strategy

- **Development**: No fingerprinting, files served with original names
- **Production**: Content-based SHA256 digest appended to filenames
- **Benefits**:
  - Aggressive caching (1 year+) without stale content
  - Automatic cache invalidation when content changes
  - CDN-friendly (assets are immutable)

## Debugging

### View all available assets
```bash
rails assets:reveal
```

### View full paths of assets
```bash
rails assets:reveal:full
```

### Check importmap configuration
```bash
bin/importmap json
```

### Inspect production manifest
```bash
cat public/assets/.manifest.json | jq
```
