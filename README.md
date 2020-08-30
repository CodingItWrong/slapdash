# Slapdash

An application for creating public Markdown-based notes.

Notes are available at the path `/username/notename`. Markdown is parsed with [kramdown](https://github.com/gettalong/kramdown). Code blocks are syntax-highlighted with [Prism](https://prismjs.com/).

## Getting Started

### Requirements

1. Ruby
1. PostgreSQL (e.g. [Postgres.app][postgres-app])

### Testing

```sh
$ bin/rspec
```

### Running

```sh
$ bin/rails server
```

[postgres-app]: http://postgresapp.com
