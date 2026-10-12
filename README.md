# Hotwire Workshop

A Rails 8.1 app for the BC Bootcamp Hotwire workshop, using Turbo and Stimulus.

## Stack

| Part       | Tool                                   |
| ---------- | -------------------------------------- |
| Ruby       | 4.0.7 (see `.ruby-version`)            |
| Node       | 26.8.1 (see `.node-version`), Yarn 1.x |
| Framework  | Rails 8.1                              |
| Database   | SQLite                                 |
| Frontend   | Turbo, Stimulus, esbuild |
| Background | Solid Queue, Solid Cache, Solid Cable  |

## Getting started

You can run the app with Docker or on your machine.

### Option 1: Docker (recommended)

You only need Docker installed.

```sh
docker compose up --build
```

Open http://localhost:3000.

This starts two services:

- `web` – the Rails server (it also runs `db:prepare`)
- `js` – esbuild in watch mode

Useful commands:

```sh
docker compose run --rm web bin/rails console
docker compose run --rm web bin/rails test
```

After you change `Gemfile` or `package.json`, install the new dependencies:

```sh
docker compose run --rm web bundle install
docker compose run --rm web yarn install
```

### Option 2: Local

Install Ruby, Node, and Yarn at the versions above, then run:

```sh
bin/setup
```

This installs gems and JS packages, prepares the database, and starts the server.

To start the app later:

```sh
bin/dev
```

`bin/dev` runs the Rails server and esbuild together (see `Procfile.dev`). Open http://localhost:3000.

## Tests and checks

```sh
bin/rails test          # unit and integration tests
bin/rails test:system   # system tests (needs Chrome)
bin/ci                  # full CI: RuboCop, security audits, Brakeman, tests
```

## Project layout

- `app/javascript/` – JS entry point and Stimulus controllers
- `app/assets/stylesheets/` – application stylesheets
- `app/assets/builds/` – compiled JS (generated, do not edit)

## Deployment

The production `Dockerfile` is meant for [Kamal](https://kamal-deploy.org) (`config/deploy.yml`).

```sh
bin/kamal setup    # first deploy
bin/kamal deploy   # later deploys
```

The app needs `RAILS_MASTER_KEY` at runtime. Pass it through `.kamal/secrets` or your secrets manager. Never commit `config/master.key` or put the key in code.
