# Slapdash

An application for creating public Markdown-based notes.

Notes are available at the path `/username/notename`. Markdown is parsed with [kramdown](https://github.com/gettalong/kramdown). Code blocks are syntax-highlighted with [Prism](https://prismjs.com/).

## Getting Started

### Requirements

1. Ruby
1. PostgreSQL (e.g. [Postgres.app][postgres-app])
1. pnpm

### Running

```sh
bin/dev
```

This starts the Rails server and the Tailwind CSS watcher together via Foreman.

### Testing

```sh
bin/rspec
```

### Linting & Formatting

```sh
pnpm run lint        # run ESLint + Prettier check
pnpm run format      # auto-format CSS and JS files
```

## Stack

| Layer | Technology |
|-------|-----------|
| CSS framework | [Tailwind CSS v4](https://tailwindcss.com) via `tailwindcss-rails` gem |
| UI components | [DaisyUI v5](https://daisyui.com) (vendored `.mjs` files in `app/assets/tailwind/vendor/`) |
| JavaScript | [Stimulus](https://stimulus.hotwired.dev) via importmap (no bundler) |
| Navigation | [Turbo](https://turbo.hotwired.dev) |
| Auth | [Devise](https://github.com/heartcombo/devise) |
| Authorization | [Pundit](https://github.com/varvet/pundit) |

## CSS

Tailwind CSS is compiled by the `tailwindcss-rails` gem's bundled binary — no Node.js involvement for CSS. DaisyUI is loaded as a Tailwind plugin from committed vendor files.

Themes: `light` (default) and `dim` (dark, activated automatically via `prefers-color-scheme: dark`).

To manually build CSS once:

```sh
bin/rails tailwindcss:build
```

[postgres-app]: http://postgresapp.com
