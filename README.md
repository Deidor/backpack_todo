# La Mochila del Peregrino: "¿Lo llevo todo?"

Technical test. A Flutter app for pilgrims on the Camino de Santiago with a
packing checklist ("¿Lo llevo todo?"), backed by a NestJS REST API and a
PostgreSQL database.

The checklist lets you list, add, tick and delete items. Each item has two
independent checkboxes, "Lo llevo" and "Comprar". Everything is stored in the
backend, so the list is restored when the app is reopened.

## Repository structure

```
.
├── api/                 NestJS REST API
│   └── src/
│       ├── database/    TypeORM data source and migrations
│       └── items/       entity, DTOs, service, controller, tests
├── app/                 Flutter app
│   ├── assets/          artwork and fonts
│   ├── lib/
│   │   ├── core/        configuration and theme
│   │   └── features/
│   │       ├── backpack/    home screen and tool preview
│   │       └── checklist/   data, domain and presentation layers
│   └── test/            unit and widget tests, mirroring lib/
└── docker-compose.yml   local PostgreSQL
```

## Requirements

| Tool | Version used |
|---|---|
| Flutter | 3.47 (stable), Dart 3.13 |
| Node.js | 24 (only for option 3 below) |
| npm | 12 (only for option 3 below) |
| Docker | 29, with Docker Compose (options 2 and 3) |
| Android device or emulator | Tested on a physical Android phone |

## Quick start

The app needs an API to talk to. There are three ways to get one, from the
least to the most setup.

### Option 1: use the deployed API

Nothing to start. The API is deployed on Render from `api/Dockerfile`, with a
Supabase project as its database:

```
https://backpack-todo.onrender.com
```

Run the app against it:

```bash
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://backpack-todo.onrender.com
```

It runs on Render's free plan, which stops the service after 15 minutes
without traffic. The first request afterwards can take about a minute, longer
than the app's 10 second timeout, so the app may show its error screen once;
"Reintentar" works as soon as the service is awake. Opening
`https://backpack-todo.onrender.com/items` in a browser first wakes it up.

### Option 2: run everything with Docker

Only Docker is needed. From the repository root:

```bash
docker compose --profile api up -d --build
```

This starts PostgreSQL 17 and the API. On startup the API applies any pending
migrations, which creates the `items` table and inserts the six initial
items. It listens on `http://localhost:3000`.

Then run the app as described in [Running the app](#running-the-app).

### Option 3: run the API with Node, for development

Start only the database:

```bash
docker compose up -d
```

PostgreSQL listens on `localhost:5432` with user, password and database all
set to `backpack`. These are throwaway local credentials.

Then start the API with live reload:

```bash
cd api
npm install
cp .env.example .env
npm run start:dev
```

It applies the migrations and listens on `http://localhost:3000`, exactly as
in option 2. Do not combine it with `--profile api`: both would try to use
port 3000.

### Running the app

```bash
cd app
flutter pub get
flutter run
```

The app reads the API address from `API_BASE_URL`. The default,
`http://10.0.2.2:3000`, reaches the host machine from the Android emulator,
so it works with options 2 and 3 as is.

On a physical Android device connected over USB, forward the port and point
the app at `localhost`:

```bash
adb reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

`adb reverse` has to be repeated whenever the device is reconnected.

To build an installable APK instead:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://backpack-todo.onrender.com
```

## Database and seed data

The seed data is the six items suggested in the brief. Both the schema and
the seed are versioned as TypeORM migrations in `api/src/database/migrations`,
so there is no separate seed command:

| Migration | What it does |
|---|---|
| `CreateItems` | Creates the `items` table |
| `SeedItems` | Inserts Palos, Crema solar, Compostela, Gorro, Chubasquero and Chanclas |

The API runs pending migrations every time it starts, so a fresh database is
built just by starting it. They can also be applied by hand:

```bash
cd api
npm run migration:run
```

Either way it is safe to repeat: TypeORM records applied migrations in a
`migrations` table and skips them.

To restore the initial six items after testing:

```bash
npm run migration:revert   # removes the seed rows
npm run migration:run      # inserts them again
```

To start from an empty database, remove the Docker volume and repeat the
steps above:

```bash
docker compose down -v
```

### Table

| Column | Type | Notes |
|---|---|---|
| `id` | `serial` | Primary key. Also gives the list a stable order |
| `name` | `varchar(60)` | |
| `packed` | `boolean` | "Lo llevo". Defaults to `false` |
| `to_buy` | `boolean` | "Comprar". Defaults to `false` |
| `created_at` | `timestamptz` | |
| `updated_at` | `timestamptz` | |

## Environment variables

### API (`api/.env`)

| Variable | Required | Default | Description |
|---|---|---|---|
| `PORT` | No | `3000` | Port the API listens on |
| `DATABASE_URL` | Yes | | PostgreSQL connection string |
| `DATABASE_SSL` | No | `false` | Set to `true` for hosted databases such as Supabase |

The API validates these on startup and refuses to start if `DATABASE_URL` is
missing. `api/.env.example` contains no real credentials.

### App (compile time, via `--dart-define`)

| Variable | Default | Description |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:3000` | Address of the API |
| `EXCLUSIVE_CHECKBOXES` | `false` | Alternative checkbox behaviour, see below |

### Connecting the API to your own Supabase project

The deployed API (option 1) already uses Supabase. Options 2 and 3 use the
local Docker database by default, because the Supabase credentials are not in
the repository.

Supabase databases are PostgreSQL, so the API connects to one without code
changes. To point a local API at your own project, set these in `api/.env`,
using the project's "Session pooler" connection string:

```
DATABASE_URL=postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres
DATABASE_SSL=true
```

Start the API and it creates the table and the seed data there.

## API

| Method | Path | Body | Response |
|---|---|---|---|
| `GET` | `/items` | | `200` with the list, ordered by `id` |
| `POST` | `/items` | `{ "name": "Botas" }` | `201` with the created item |
| `PATCH` | `/items/:id` | `{ "packed": true }` and/or `{ "toBuy": true }` | `200` with the updated item |
| `POST` | `/items/bulk-delete` | `{ "ids": [1, 2] }` | `204` |

Errors use the standard NestJS shape. Invalid bodies return `400`, including
empty or whitespace-only names and unknown fields. An unknown `id` on `PATCH`
returns `404`.

## Tests

```bash
cd api && npm test        # 5 unit tests for the items service
cd app && flutter test    # 39 unit and widget tests
```

The Flutter tests cover the repository (with a mocked HTTP client), the
controllers, and every screen: loading, empty and error states, ticking
checkboxes with rollback on failure, adding items, edit mode and navigation.

## Third-party libraries

### App

| Package | Why |
|---|---|
| `flutter_riverpod` | State management |
| `http` | HTTP client. Its `MockClient` is used in the repository tests |
| `animate_do` | Ready-made entrance animations for the backpack, the tool preview and the list rows |
| `flutter_launcher_icons` (dev) | Generates the launcher icon in every size Android and iOS need |

Fonts: Special Elite (Apache 2.0) and Fredoka (SIL Open Font License), both
from Google Fonts.

### API

| Package | Why |
|---|---|
| `@nestjs/config`, `joi` | Loading and validating environment variables |
| `class-validator`, `class-transformer` | Validating and normalising request bodies |
| `typeorm`, `@nestjs/typeorm`, `pg` | ORM, NestJS integration and PostgreSQL driver |
| `dotenv` | Loading `.env` for the migration commands, which run outside NestJS |

## Technical decisions

- **Monorepo.** One repository with `api/` and `app/`, so a single clone
  contains everything needed to run the project.
- **Conventional Commits.** Commit messages follow the
  [Conventional Commits](https://www.conventionalcommits.org) format, such as
  `feat(app): ...` or `fix(api): ...`, with the scope naming the folder they
  touch.
- **NestJS with TypeORM on PostgreSQL.** The preferred stack in the brief.
  TypeORM integrates with NestJS through `@nestjs/typeorm`, and its migrations
  make the database reproducible. `synchronize` is disabled: only migrations
  change the schema.
- **Seed as a migration, applied on startup.** Schema and initial data are
  created together, with no manual step, which is also what makes the API
  deployable as a plain container.
- **Bulk delete endpoint.** In edit mode, deletions are only applied on
  "Guardar cambios". Sending every id in one request makes that save a single
  operation.
- **Riverpod for state.** The list is an `AsyncNotifier`, whose `AsyncValue`
  maps directly to the loading, data and error states the brief asks for.
  Pending deletions live in a separate notifier because they are a local draft,
  not server state.
- **Feature-first folders** in the app, each split into `data`, `domain` and
  `presentation`. The UI talks to a repository and knows nothing about HTTP.
- **Optimistic checkbox updates.** A checkbox changes immediately and reverts,
  with a message, if the request fails.
- **Independent checkboxes, with an alternative mode.** RF-04 states that
  "Comprar" works independently of "Lo llevo", so that is the default. The
  reference screens suggest the two might be alternatives, so that behaviour
  is available with `--dart-define=EXCLUSIVE_CHECKBOXES=true`: ticking one box
  clears the other, "Comprar" gets its own mark and its column comes first.
- **Layout by fractions.** Content is positioned as fractions of the notebook
  and backpack artwork, so it lines up on any screen size.
- **Bundled fonts.** Font files ship with the app instead of being downloaded
  at runtime, so it works offline and tests are deterministic.

The assumptions made where the brief was unclear are explained in the final
report.

## Scope and pending work

Done:

- The checklist, covering RF-01 to RF-07.
- The backpack home screen with an intermediate preview of each tool.
- Extras: a Dockerfile for the API, Docker Compose for the database and the
  API, a deployed backend (Render and Supabase), animations and a launcher
  icon.

Not done:

- The optional diary ("Libro") and stamps ("Sellos") modules. Their objects
  in the backpack show "Próximamente".
- Authentication, offline mode and CI.
- iOS was not tested, as development was done on Windows.

