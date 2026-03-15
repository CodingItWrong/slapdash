# Migration Plan: Bootstrap/Sass → Tailwind CSS + DaisyUI

## Overview

This document is the step-by-step plan for migrating Slapdash from Bootstrap 5 + Sass to
Tailwind CSS + DaisyUI, using the standalone bundle file approach (no npm packages for Tailwind
or DaisyUI). After the migration, npm is used only for ESLint, Prettier, and related tooling.

### Goals

- Remove Bootstrap, Bootstrap Icons, Sass, PostCSS, autoprefixer, nodemon from npm
- Replace `cssbundling-rails` gem with `tailwindcss-rails` gem
- Install DaisyUI via downloaded standalone `.mjs` files (no npm)
- Use DaisyUI `light` as the default theme, `dim` for dark mode — OS preference switches automatically via `--prefersdark` (no JavaScript needed)
- Override DaisyUI's primary color to `#ff784e` (the existing orange brand color) for both themes
- Convert all Bootstrap component classes to DaisyUI/Tailwind equivalents across all views

---

## Current State Summary

| Layer         | Current                           | After Migration                     |
|---------------|-----------------------------------|-------------------------------------|
| CSS Framework | Bootstrap 5 (npm)                 | DaisyUI (downloaded .mjs bundle)    |
| Utility CSS   | Bootstrap utilities               | Tailwind CSS v4                     |
| CSS Build     | Sass + PostCSS (npm) via cssbundling-rails | tailwindcss-rails gem (bundled binary) |
| Icons         | Bootstrap Icons (npm, unused)     | Removed                             |
| JS (UI)       | Bootstrap JS (importmap pin)      | Removed (DaisyUI is CSS-only)       |
| Gem           | cssbundling-rails                 | tailwindcss-rails                   |

---

## Step 1: Update the Gemfile

### Remove

```ruby
gem "cssbundling-rails", "~> 1.4"
```

### Add

```ruby
gem "tailwindcss-rails"
```

The `tailwindcss-rails` gem ships a standalone Tailwind CSS CLI binary — no Node.js or npm
involvement for CSS compilation. It replaces `cssbundling-rails` entirely for CSS building.

Run:

```bash
bundle install
```

---

## Step 2: Run the Tailwind Installer

```bash
bin/rails tailwindcss:install
```

This generator will:

1. Download the Tailwind CLI binary to `bin/tailwindcss`
2. Create `app/assets/tailwind/application.css` (new CSS entry point)
3. Update `Procfile.dev` — replaces `css: yarn watch:css` with `css: bin/rails tailwindcss:watch`
4. Update `config/initializers/` if needed

The output path (`app/assets/builds/application.css`) and the `stylesheet_link_tag "application"`
call in the layout are unchanged — Propshaft continues to serve from `app/assets/builds/`.

---

## Step 3: Download DaisyUI Bundle Files

Download the two standalone `.mjs` plugin files directly from GitHub releases into the
`app/assets/tailwind/` directory:

```bash
curl -sLo app/assets/tailwind/daisyui.mjs \
  https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.mjs

curl -sLo app/assets/tailwind/daisyui-theme.mjs \
  https://github.com/saadeghi/daisyui/releases/latest/download/daisyui-theme.mjs
```

These files are committed to the repository (they are source assets, not build artifacts).
Pin the version in the filenames if reproducible builds matter, e.g.:

```bash
curl -sLo app/assets/tailwind/daisyui.mjs \
  https://github.com/saadeghi/daisyui/releases/download/v5.0.35/daisyui.mjs
```

Check the latest release at https://github.com/saadeghi/daisyui/releases.

---

## Step 4: Configure app/assets/tailwind/application.css

Replace the generated file content with:

```css
@import "tailwindcss";
@plugin "./daisyui.mjs" {
  themes: light --default, dim --prefersdark;
}

/*
  Override DaisyUI primary color to preserve the original orange brand (#ff784e).
  #ff784e in OKLCH ≈ oklch(71.8% 0.184 37.5)
  Applied to :root so it affects both light and dim themes.
*/
:root,
[data-theme] {
  --color-primary: oklch(71.8% 0.184 37.5);
  --color-primary-content: oklch(100% 0 0);
}

/* Syntax highlighting (Prism.js) */
@import "../stylesheets/prism.css";

/* ─── Layout ─────────────────────────────────────────────── */

body {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.full-height {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* ─── Typography / Prose ─────────────────────────────────── */

code {
  color: inherit;
}

blockquote {
  border-left: solid 2px oklch(var(--color-base-content) / 0.3);
  padding-left: 0.625rem;
}

/* ─── Markdown editor textarea ───────────────────────────── */

.markdown-editor {
  font-family: Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace;
  flex: 1;
}

/* ─── Form utilities ─────────────────────────────────────── */

/* Always show validation error text (mirrors Bootstrap's .invalid-feedback) */
.field-error {
  display: block;
}

.form-group__body {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* ─── Navbar ─────────────────────────────────────────────── */

.navbar-logo {
  width: 30px;
  height: 30px;
}
```

### Theme strategy

- `light --default` — shown when OS is in light mode (or no preference set)
- `dim --prefersdark` — shown automatically when OS is in dark mode via `prefers-color-scheme: dark`

DaisyUI emits a `@media (prefers-color-scheme: dark)` block in its CSS output for the
`--prefersdark` theme. No JavaScript is required.

The `dim` theme was chosen for dark mode because its dark gray (`base-300`) maps naturally to
the existing Bootstrap dark navbar, and orange reads clearly against it.

To offer a manual theme toggle later, add `data-theme="light"` or `data-theme="dim"` to `<html>`
via JavaScript — this overrides the media query.

### Primary color OKLCH conversion

`#ff784e` → `oklch(71.8% 0.184 37.5)`

| Property | Bootstrap | DaisyUI (override, both themes) |
|----------|-----------|----------------------------------|
| `--color-primary` | `$primary: #ff784e` | `oklch(71.8% 0.184 37.5)` |
| Used by | `btn-primary`, alerts, links | `btn-primary`, focus rings, accents |

---

## Step 5: Update package.json

### Remove these dependencies entirely

```
dependencies:
  bootstrap
  bootstrap-icons

devDependencies:
  sass
  postcss
  postcss-cli
  autoprefixer
  nodemon
```

### Switch from yarn to pnpm

As part of this migration, switch the package manager from yarn to pnpm for the remaining
dev dependencies (ESLint, Prettier).

**Install pnpm** (if not already installed):

```bash
npm install -g pnpm
# or via corepack:
corepack enable
corepack prepare pnpm@latest --activate
```

**Migrate:**

```bash
# Remove yarn lockfile and node_modules
rm yarn.lock
rm -rf node_modules

# Install dependencies with pnpm
pnpm install
```

**Update CI/CD** — replace any `yarn install` or `yarn lint` steps with `pnpm install` and
`pnpm run lint`.

Add to `.gitignore` if not already present:

```
node_modules/
# pnpm lockfile is committed:
# pnpm-lock.yaml  ← commit this
```

Commit `pnpm-lock.yaml` and delete `yarn.lock`.

### Updated package.json

```json
{
  "name": "app",
  "private": "true",
  "engines": {
    "node": "24.x"
  },
  "scripts": {
    "format": "pnpm prettier app/assets/tailwind app/javascript --write",
    "lint:format": "pnpm prettier app/assets/tailwind app/javascript --check",
    "lint:eslint": "pnpm eslint . --max-warnings=0",
    "lint": "pnpm run lint:eslint && pnpm run lint:format"
  },
  "devDependencies": {
    "eslint": "^8.57.0",
    "eslint-config-prettier": "^9.1.0",
    "prettier": "^3.2.5"
  }
}
```

Run `pnpm install` after updating.

---

## Step 6: Remove Old CSS Source Files

Delete the following files (they are replaced by `app/assets/tailwind/application.css`):

```
app/assets/stylesheets/application.bootstrap.scss   ← delete
app/assets/stylesheets/overrides.scss               ← delete
app/assets/stylesheets/custom.scss                  ← delete (content migrated to application.css)
```

Keep:

```
app/assets/stylesheets/prism.css    ← keep (imported via @import in application.css)
```

---

## Step 7: Update config/importmap.rb

Remove the Bootstrap JS pin — DaisyUI components are CSS-only and do not require Bootstrap's
JavaScript:

```ruby
# Remove this line:
pin "bootstrap", to: "bootstrap.min.js"
```

Also delete the generated Bootstrap JS build artifact if present:

```bash
rm -f app/assets/builds/bootstrap.min.js
```

---

## Step 8: Verify Procfile.dev

The `tailwindcss:install` generator updates `Procfile.dev`. Verify it looks like:

```
web: env RUBY_DEBUG_OPEN=true bin/rails server
css: bin/rails tailwindcss:watch
```

The old `css: yarn watch:css` line must be gone.

---

## Step 9: View Migration — Bootstrap → DaisyUI Classes

### Quick Reference: Class Mapping

| Bootstrap class | DaisyUI/Tailwind replacement |
|-----------------|------------------------------|
| `navbar navbar-dark bg-dark navbar-expand-lg` | `navbar bg-base-300 shadow-sm` |
| `navbar-brand` | Brand link inside `navbar-start` div |
| `navbar-toggler` + Bootstrap JS collapse | DaisyUI `dropdown` (CSS-only, see below) |
| `navbar-nav` | `menu menu-horizontal` (desktop) / `menu menu-sm` (mobile dropdown) |
| `nav-item` / `nav-link` | `<li>` / anchor inside `menu` |
| `container` | `container mx-auto px-4` |
| `row` / `col-sm` | Remove; use flexbox or `flex-1` |
| `btn btn-primary` | `btn btn-primary` |
| `btn btn-light` | `btn btn-ghost` |
| `btn btn-danger` | `btn btn-error` |
| `alert alert-success` | `alert alert-success` |
| `alert alert-danger` | `alert alert-error` |
| `form-group` | `fieldset` (DaisyUI v5) or plain `div` with spacing |
| `form-control` (input) | `input input-bordered w-full` |
| `form-control` (textarea) | `textarea textarea-bordered w-full` |
| `is-invalid` | `input-error` / `textarea-error` |
| `invalid-feedback` | `<p class="text-error text-sm field-error">` |
| `form-check` | plain `div` with `flex items-center gap-2` |
| `form-check-input` (checkbox) | `checkbox` |
| `form-check-label` | `label` |
| `form-text text-muted` | `<p class="text-sm text-base-content/60">` |
| `text-muted` | `text-base-content/60` |
| `list-group` | `menu bg-base-100 rounded-box w-full` |
| `list-group-item list-group-item-action` | `<li><a>` inside `menu` |
| `breadcrumb` / `breadcrumb-item` | `breadcrumbs` / `<li>` inside `<ul>` |
| `mb-3`, `mb-2` | same (`mb-3`, `mb-2` — Tailwind uses same naming) |
| `mr-1` | `mr-1` (same) |

---

### app/views/layouts/application.html.erb

Full replacement:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= yield :title %> | Slapdash</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= render 'shared/favicons' %>

    <%= javascript_importmap_tags %>
    <%= stylesheet_link_tag "application" %>
  </head>

  <body>
    <div class="navbar bg-base-300 shadow-sm mb-3">
      <div class="container mx-auto px-4">
        <div class="flex-1">
          <%= link_to root_path, class: 'btn btn-ghost text-xl' do %>
            <%= image_tag('logo-30@3x.png', class: 'navbar-logo mr-1') %>
            Slapdash
          <% end %>
        </div>

        <% if user_signed_in? %>
          <%# Mobile: dropdown menu %>
          <div class="dropdown dropdown-end lg:hidden">
            <div tabindex="0" role="button" class="btn btn-ghost">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </div>
            <ul tabindex="0"
                class="menu menu-sm dropdown-content bg-base-200 rounded-box z-50 mt-3 w-52 p-2 shadow">
              <li><%= link_to 'My Notes', notes_path(current_user.display_name) %></li>
              <li>
                <%= link_to 'Sign Out',
                            destroy_user_session_path,
                            data: {turbo_method: :delete, turbo_confirm: 'Are you sure?'} %>
              </li>
            </ul>
          </div>

          <%# Desktop: inline menu %>
          <div class="hidden lg:flex">
            <ul class="menu menu-horizontal px-1">
              <li><%= link_to 'My Notes', notes_path(current_user.display_name) %></li>
              <li>
                <%= link_to 'Sign Out',
                            destroy_user_session_path,
                            data: {turbo_method: :delete, turbo_confirm: 'Are you sure?'} %>
              </li>
            </ul>
          </div>
        <% end %>
      </div>
    </div>

    <div class="container mx-auto px-4 full-height">
      <div class="full-height">
        <% if notice.present? %>
          <div role="alert" class="alert alert-success mb-3">
            <%= notice %>
          </div>
        <% end %>
        <% if alert.present? %>
          <div role="alert" class="alert alert-error mb-3">
            <%= alert %>
          </div>
        <% end %>

        <%= yield %>
      </div>
    </div>
  </body>
</html>
```

Key notes:
- `data-theme="dim"` on `<html>` activates the DaisyUI dim theme globally
- Mobile nav uses DaisyUI `dropdown` with a hamburger SVG icon (CSS-only, no JS needed)
- Desktop nav uses `hidden lg:flex` — Tailwind responsive utility
- Bootstrap JS is no longer required for the navbar

---

### app/views/notes/index.html.erb

```erb
<% content_for :title do %>
  <%= @user.display_name %>'s Notes
<% end %>

<nav aria-label="breadcrumb" class="text-sm breadcrumbs mb-3">
  <ul>
    <li class="text-base-content/60"><%= @user.display_name %></li>
  </ul>
</nav>

<h1 class="text-2xl font-bold mb-3"><%= @user.display_name %>'s Notes</h1>

<% if policy(@note).create? %>
  <div class="mb-3">
    <%= link_to 'Add', new_note_path(@user.display_name), class: 'btn btn-primary' %>
  </div>
<% end %>

<form data-controller="filter" onsubmit="return false">
  <input type="search"
         data-filter-target="filterTextField"
         data-action="keyup->filter#update"
         class="input input-bordered w-full mb-2"
         placeholder="search" />

  <ul class="menu bg-base-100 rounded-box w-full mb-3">
    <% @notes.each do |note| %>
      <li data-filter-target="listItem">
        <%= link_to note.title, note_path(@user, note) %>
      </li>
    <% end %>
  </ul>
</form>
```

---

### app/views/notes/show.html.erb

```erb
<% content_for :title do %>
  <%= @note.title %> | <%= @user.display_name %>'s Notes
<% end %>

<nav aria-label="breadcrumb" class="text-sm breadcrumbs mb-3">
  <ul>
    <li><%= link_to @user.display_name, notes_path(@user.display_name) %></li>
    <li class="text-base-content/60"><%= @note.title %></li>
  </ul>
</nav>

<h1 class="text-2xl font-bold mb-3"><%= @note.title %></h1>

<% if policy(@note).update? || policy(@note).destroy? %>
  <div class="flex gap-2 mb-3">
    <% if policy(@note).update? %>
      <%= link_to 'Edit', edit_note_path(@user.display_name, @note.slug), class: 'btn btn-ghost' %>
    <% end %>
    <% if policy(@note).destroy? %>
      <%= link_to 'Delete',
                  note_path(@user.display_name, @note.slug),
                  class: 'btn btn-error',
                  data: {
                    turbo_method: :delete,
                    turbo_confirm: 'Are you sure you want to delete this page?',
                    turbo_frame: '_top',
                  } %>
    <% end %>
  </div>
<% end %>

<div class="rendered-markdown prose max-w-none">
  <%= raw markdown_to_html(@note.body) %>
</div>
```

Note: `prose max-w-none` applies Tailwind's built-in prose styles to rendered markdown HTML. If
Tailwind Typography plugin is not available, replace these with custom CSS on `.rendered-markdown`.

---

### app/views/notes/edit.html.erb

```erb
<% content_for :title do %>
  Edit | <%= @note.title %> | <%= @user.display_name %>'s Notes
<% end %>

<nav aria-label="breadcrumb" class="text-sm breadcrumbs mb-3">
  <ul>
    <li><%= link_to @user.display_name, notes_path(@user.display_name) %></li>
    <li><%= link_to @note.title, note_path(@user.display_name, @note.slug) %></li>
    <li class="text-base-content/60">Edit</li>
  </ul>
</nav>

<%= render 'form' %>
```

---

### app/views/notes/new.html.erb

```erb
<% content_for :title do %>
  Add Note | <%= @user.display_name %>'s Notes
<% end %>

<nav aria-label="breadcrumb" class="text-sm breadcrumbs mb-3">
  <ul>
    <li><%= link_to @user.display_name, notes_path(@user.display_name) %></li>
    <li class="text-base-content/60">Add Note</li>
  </ul>
</nav>

<%= render 'form' %>
```

---

### app/views/notes/_form.html.erb

```erb
<%= form_with model: @note,
              url: @note.persisted? ? note_path(@user.display_name, @note.slug) : notes_path(@user.display_name),
              method: @note.persisted? ? :patch : :post,
              local: true,
              class: 'full-height' do |f| %>

  <div class="flex gap-2 mb-3">
    <%= f.submit 'Save', class: 'btn btn-primary' %>
    <%= link_to 'Cancel',
                @note.persisted? ? note_path(@user.display_name, @note.slug) : notes_path(@user.display_name),
                class: 'btn btn-ghost' %>
  </div>

  <fieldset class="fieldset mb-3">
    <%= f.label :title, class: 'fieldset-legend' %>
    <%= f.text_field :title,
                     class: "input input-bordered w-full #{@note.errors.include?(:title) ? 'input-error' : ''}" %>
    <% @note.errors.full_messages_for(:title).each do |message| %>
      <p class="text-error text-sm field-error"><%= message %></p>
    <% end %>
  </fieldset>

  <fieldset class="fieldset form-group__body">
    <%= f.label :body, class: 'fieldset-legend' %>
    <p class="text-sm text-base-content/60 mb-1">
      Accepts
      <a href="https://kramdown.gettalong.org/quickref.html"
         class="link link-hover"
         target="_blank"
         rel="noopener noreferrer">kramdown-flavored</a>
      markdown
    </p>
    <% @note.errors.full_messages_for(:body).each do |message| %>
      <p class="text-error text-sm field-error"><%= message %></p>
    <% end %>
    <%= f.text_area :body, rows: 7,
                    class: "textarea textarea-bordered w-full markdown-editor #{@note.errors.include?(:body) ? 'textarea-error' : ''}" %>
  </fieldset>

<% end %>
```

---

### app/views/devise/sessions/new.html.erb

```erb
<% content_for :title, 'Sign in' %>
<h2 class="text-2xl font-bold mb-4">Sign in</h2>

<%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
  <fieldset class="fieldset mb-3">
    <%= f.label :email, class: 'fieldset-legend' %>
    <%= f.email_field :email, autofocus: true, autocomplete: "email",
                      class: 'input input-bordered w-full' %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :password, class: 'fieldset-legend' %>
    <%= f.password_field :password, autocomplete: "current-password",
                         class: 'input input-bordered w-full' %>
  </fieldset>

  <% if devise_mapping.rememberable? %>
    <div class="flex items-center gap-2 mb-3">
      <%= f.check_box :remember_me, class: 'checkbox' %>
      <label for="user_remember_me">Keep me signed in for two weeks</label>
    </div>
  <% end %>

  <div class="mb-3">
    <%= f.submit "Sign in", class: 'btn btn-primary' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>

<p class="text-sm text-base-content/60 mt-3">
  high five icon by Timofei Rostilov from the Noun Project
</p>
```

---

### app/views/devise/registrations/new.html.erb

```erb
<% content_for :title, 'Sign up' %>
<h2 class="text-2xl font-bold mb-4">Sign up</h2>

<%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>

  <fieldset class="fieldset mb-3">
    <%= f.label :email, class: 'fieldset-legend' %>
    <%= f.email_field :email, autofocus: true, autocomplete: "email",
                      class: 'input input-bordered w-full' %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :display_name, class: 'fieldset-legend' %>
    <%= f.text_field :display_name, autocomplete: 'username', autocapitalize: 'off',
                     class: 'input input-bordered w-full' %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :password, class: 'fieldset-legend' %>
    <%= f.password_field :password, autocomplete: "new-password",
                         class: 'input input-bordered w-full' %>
    <% if @minimum_password_length %>
      <p class="text-sm text-base-content/60">(<%= @minimum_password_length %> characters minimum)</p>
    <% end %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :password_confirmation, class: 'fieldset-legend' %>
    <%= f.password_field :password_confirmation, autocomplete: "new-password",
                         class: 'input input-bordered w-full' %>
  </fieldset>

  <div class="mb-3">
    <%= f.submit "Sign up", class: 'btn btn-primary' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

---

### app/views/devise/registrations/edit.html.erb

This view uses the default Devise scaffold with minimal styling. Apply the same fieldset/input
patterns:

```erb
<h2 class="text-2xl font-bold mb-4">Edit <%= resource_name.to_s.humanize %></h2>

<%= form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>

  <fieldset class="fieldset mb-3">
    <%= f.label :email, class: 'fieldset-legend' %>
    <%= f.email_field :email, autofocus: true, autocomplete: "email",
                      class: 'input input-bordered w-full' %>
  </fieldset>

  <% if devise_mapping.confirmable? && resource.pending_reconfirmation? %>
    <p class="mb-3 text-sm text-base-content/60">
      Currently waiting confirmation for: <%= resource.unconfirmed_email %>
    </p>
  <% end %>

  <fieldset class="fieldset mb-3">
    <%= f.label :password, class: 'fieldset-legend' %>
    <span class="text-sm text-base-content/60">(leave blank if you don't want to change it)</span>
    <%= f.password_field :password, autocomplete: "new-password",
                         class: 'input input-bordered w-full' %>
    <% if @minimum_password_length %>
      <p class="text-sm text-base-content/60"><%= @minimum_password_length %> characters minimum</p>
    <% end %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :password_confirmation, class: 'fieldset-legend' %>
    <%= f.password_field :password_confirmation, autocomplete: "new-password",
                         class: 'input input-bordered w-full' %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :current_password, class: 'fieldset-legend' %>
    <span class="text-sm text-base-content/60">(we need your current password to confirm your changes)</span>
    <%= f.password_field :current_password, autocomplete: "current-password",
                         class: 'input input-bordered w-full' %>
  </fieldset>

  <div class="mb-3">
    <%= f.submit "Update", class: 'btn btn-primary' %>
  </div>
<% end %>

<div class="divider my-6"></div>
<h3 class="text-lg font-semibold mb-2">Cancel my account</h3>
<p class="mb-3 text-base-content/70">
  Unhappy?
  <%= button_to "Cancel my account",
                registration_path(resource_name),
                data: { confirm: "Are you sure?" },
                method: :delete,
                class: 'btn btn-error btn-sm' %>
</p>

<%= link_to "Back", :back, class: 'btn btn-ghost btn-sm' %>
```

---

### app/views/devise/passwords/new.html.erb

```erb
<% content_for :title, 'Forgot your password?' %>
<h2 class="text-2xl font-bold mb-4">Forgot your password?</h2>

<%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>

  <fieldset class="fieldset mb-3">
    <%= f.label :email, class: 'fieldset-legend' %>
    <%= f.email_field :email, autofocus: true, autocomplete: 'email',
                      class: 'input input-bordered w-full' %>
  </fieldset>

  <div class="mb-3">
    <%= f.submit "Send me reset password instructions", class: 'btn btn-primary' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

---

### app/views/devise/passwords/edit.html.erb

```erb
<h2 class="text-2xl font-bold mb-4">Change your password</h2>

<%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put }) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>
  <%= f.hidden_field :reset_password_token %>

  <fieldset class="fieldset mb-3">
    <%= f.label :password, "New password", class: 'fieldset-legend' %>
    <% if @minimum_password_length %>
      <span class="text-sm text-base-content/60">(<%= @minimum_password_length %> characters minimum)</span>
    <% end %>
    <%= f.password_field :password, autofocus: true, autocomplete: "new-password",
                         class: 'input input-bordered w-full' %>
  </fieldset>

  <fieldset class="fieldset mb-3">
    <%= f.label :password_confirmation, "Confirm new password", class: 'fieldset-legend' %>
    <%= f.password_field :password_confirmation, autocomplete: "new-password",
                         class: 'input input-bordered w-full' %>
  </fieldset>

  <div class="mb-3">
    <%= f.submit "Change my password", class: 'btn btn-primary' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

---

### app/views/devise/confirmations/new.html.erb

```erb
<h2 class="text-2xl font-bold mb-4">Resend confirmation instructions</h2>

<%= form_for(resource, as: resource_name, url: confirmation_path(resource_name), html: { method: :post }) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>

  <fieldset class="fieldset mb-3">
    <%= f.label :email, class: 'fieldset-legend' %>
    <%= f.email_field :email, autofocus: true, autocomplete: "email",
                      value: (resource.pending_reconfirmation? ? resource.unconfirmed_email : resource.email),
                      class: 'input input-bordered w-full' %>
  </fieldset>

  <div class="mb-3">
    <%= f.submit "Resend confirmation instructions", class: 'btn btn-primary' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

---

### app/views/devise/unlocks/new.html.erb

```erb
<h2 class="text-2xl font-bold mb-4">Resend unlock instructions</h2>

<%= form_for(resource, as: resource_name, url: unlock_path(resource_name), html: { method: :post }) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>

  <fieldset class="fieldset mb-3">
    <%= f.label :email, class: 'fieldset-legend' %>
    <%= f.email_field :email, autofocus: true, autocomplete: "email",
                      class: 'input input-bordered w-full' %>
  </fieldset>

  <div class="mb-3">
    <%= f.submit "Resend unlock instructions", class: 'btn btn-primary' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

---

### app/views/devise/shared/_error_messages.html.erb

```erb
<% if resource.errors.any? %>
  <div role="alert" class="alert alert-error mb-4">
    <div>
      <p class="font-semibold">
        <%= I18n.t("errors.messages.not_saved",
                   count: resource.errors.count,
                   resource: resource.class.model_name.human.downcase) %>
      </p>
      <ul class="list-disc list-inside mt-1">
        <% resource.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  </div>
<% end %>
```

---

### app/views/devise/shared/_links.html.erb

```erb
<%- if controller_name != 'sessions' %>
  <div class="mt-2">
    <%= link_to "Sign in", new_session_path(resource_name), class: 'btn btn-ghost btn-sm mt-1' %>
  </div>
<% end %>

<%- if devise_mapping.registerable? && controller_name != 'registrations' %>
  <div class="mt-2">
    <%= link_to "Sign up", new_registration_path(resource_name), class: 'btn btn-ghost btn-sm mt-1' %>
  </div>
<% end %>

<%- if devise_mapping.recoverable? && controller_name != 'passwords' && controller_name != 'registrations' %>
  <div class="mt-2">
    <%= link_to "Forgot your password?", new_password_path(resource_name), class: 'btn btn-ghost btn-sm mt-1' %>
  </div>
<% end %>

<%- if devise_mapping.confirmable? && controller_name != 'confirmations' %>
  <div class="mt-2">
    <%= link_to "Didn't receive confirmation instructions?", new_confirmation_path(resource_name), class: 'link link-hover' %>
  </div>
<% end %>

<%- if devise_mapping.lockable? && resource_class.unlock_strategy_enabled?(:email) && controller_name != 'unlocks' %>
  <div class="mt-2">
    <%= link_to "Didn't receive unlock instructions?", new_unlock_path(resource_name), class: 'link link-hover' %>
  </div>
<% end %>

<%- if devise_mapping.omniauthable? %>
  <%- resource_class.omniauth_providers.each do |provider| %>
    <div class="mt-2">
      <%= link_to "Sign in with #{OmniAuth::Utils.camelize(provider)}", omniauth_authorize_path(resource_name, provider), class: 'btn btn-ghost btn-sm' %>
    </div>
  <% end %>
<% end %>
```

---

## Step 10: Bootstrap Icons

Bootstrap Icons are currently imported in SCSS but no `bi-*` icon classes appear in any
template. After deleting the SCSS files the import goes away automatically.

If any icon classes are discovered during implementation:
1. Search codebase: `grep -r "bi-" app/views app/javascript`
2. Replace with inline SVGs (preferred — no extra download) from https://icons.getbootstrap.com/
   or https://heroicons.com/

---

## Step 11: Update docs/assets.md

Update `docs/assets.md` to reflect the new pipeline:

- Replace all references to `cssbundling-rails` → `tailwindcss-rails`
- Update stylesheet tree: `app/assets/stylesheets/` → `app/assets/tailwind/`
- Update dev commands: `yarn watch:css` → `bin/rails tailwindcss:watch`
- Update build commands: `yarn build:css` → `bin/rails tailwindcss:build`
- Update npm packages table: remove Bootstrap/Sass entries, note DaisyUI is a committed vendor file

---

## Execution Order Checklist

```
[ ] 1. Update Gemfile: remove cssbundling-rails, add tailwindcss-rails
[ ] 2. bundle install
[ ] 3. bin/rails tailwindcss:install
[ ] 4. Download daisyui.mjs and daisyui-theme.mjs → app/assets/tailwind/
[ ] 5. Write app/assets/tailwind/application.css (as specified in Step 4)
[ ] 6. Update package.json: remove Bootstrap/Sass/PostCSS/nodemon/autoprefixer packages and scripts
[ ] 7. Switch from yarn to pnpm: rm yarn.lock && pnpm install
[ ] 8. Delete old SCSS files: application.bootstrap.scss, overrides.scss, custom.scss
[ ] 9. Remove Bootstrap JS pin from config/importmap.rb
[ ] 10. Verify Procfile.dev uses bin/rails tailwindcss:watch
[ ] 11. Update app/views/layouts/application.html.erb
[ ] 12. Update app/views/notes/ (index, show, edit, new, _form)
[ ] 13. Update app/views/devise/ (all views)
[ ] 14. Update app/views/devise/shared/ (_error_messages, _links)
[ ] 15. Run bin/dev, verify CSS builds and app renders correctly
[ ] 16. Update docs/assets.md
[ ] 17. Search for any remaining Bootstrap class names: grep -r "btn-light\|form-control\|navbar-" app/views
```

---

## Notes

### Tailwind Typography (prose classes)

The `prose` and `max-w-none` classes on `.rendered-markdown` use Tailwind's built-in typography
styles (available in Tailwind v4 without a separate plugin). If the prose styling is insufficient,
add custom CSS rules under `.rendered-markdown` in `application.css`.

### DaisyUI Fieldset Component

DaisyUI v5 uses `<fieldset class="fieldset">` with `<legend class="fieldset-legend">` for form
field groups, replacing Bootstrap's `<div class="form-group">`. This semantic structure also
improves accessibility.

### Tailwind Content Scanning

`tailwindcss-rails` with Tailwind v4 automatically detects and scans Rails template files
(`app/views/**/*.erb`, `app/javascript/**/*.js`) — no manual `content` configuration needed.

### Theme Switching

OS-level dark/light mode switching is handled automatically via the `--prefersdark` flag — no
JavaScript needed. If you want to offer a manual override toggle:

```javascript
document.documentElement.setAttribute('data-theme', 'dim');   // force dark
document.documentElement.setAttribute('data-theme', 'light'); // force light
document.documentElement.removeAttribute('data-theme');       // follow OS again
```

Setting `data-theme` on `<html>` takes precedence over the media query. Use `localStorage` to
persist the user's choice across page loads.
