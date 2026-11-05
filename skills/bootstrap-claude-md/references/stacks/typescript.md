# TypeScript / Node conventions

Load this when the project is TypeScript or JavaScript: Next.js, Hono, Express, React, a Node
or Bun CLI, a published npm package.

## Defaults to propose when the user has no preference

| Concern | Default | Why this one |
|---|---|---|
| Runtime | Node 22 LTS (Bun if the user already uses it) | LTS; Bun only when detect shows a bun lockfile |
| Package manager | pnpm | Fast, strict about phantom deps; use whatever lockfile detect found if one exists |
| Language | TypeScript, `strict: true` | Catches the class of bugs Claude most often introduces |
| Test runner | Vitest | Fast, TS-native, same API shape as Jest |
| Lint + format | Biome | One tool, one config, fast; ESLint + Prettier if the user already has them |
| Web framework | Next.js (App Router) for full-stack UI, Hono for API-only | Both are what the ecosystem defaults to in 2026 |
| DB access | Drizzle with Postgres | Type-safe, SQL-shaped, little magic |

Never propose a package manager different from the lockfile already in the folder.

## Commands that actually run

Adjust `pnpm` to `npm run` / `bun` / `yarn` to match the lockfile.

```bash
pnpm install           # install deps
pnpm dev               # dev server (Next: http://localhost:3000)
pnpm test              # vitest run, one-shot
pnpm test:watch        # vitest, watch mode
pnpm lint              # biome check .
pnpm format            # biome format --write .
pnpm typecheck         # tsc --noEmit
pnpm build             # production build; must pass before commit
```

These assume matching `scripts` in package.json. When the folder is empty, say in the
CLAUDE.md that the scripts need to be created, and list the exact `scripts` block in 待決事項
or in the first-steps suggestions.

## Starting layouts

Next.js app:
```
src/
  app/          # routes only: page.tsx, layout.tsx, route.ts. No business logic.
  server/       # db access, services. app/ calls this, never the reverse.
  components/   # shared UI
  lib/          # pure helpers, no I/O
tests/          # mirrors src/
```

Hono / Express API:
```
src/
  index.ts      # server entry
  routes/       # one file per resource
  services/     # business logic, no HTTP types
  db/           # schema, migrations, client
tests/
```

Node CLI:
```
src/
  cli.ts        # arg parsing only (commander or citty)
  commands/     # one file per subcommand
  lib/          # logic, testable without the CLI
tests/
bin/            # built entry, from package.json "bin"
```

Library:
```
src/index.ts    # public API, re-exports only
src/            # implementation
tests/
```

## Mistakes Claude commonly makes in this stack

Write the ones relevant to the project into 工作方式 or 不要做的事 only if the user agrees;
otherwise keep them in mind while writing commands and layout.

- Mixing package managers (running `npm install` in a pnpm repo creates a second lockfile).
- Using Pages Router APIs (`getServerSideProps`) in an App Router project.
- Putting database calls inside `app/` route files instead of `server/`.
- `any` to silence type errors. Suggest `strict: true` and a rule against `any` in 測試要求
  or 工作方式 if the user cares.
- Forgetting `"type": "module"` and then fighting CommonJS/ESM errors.
- Writing Jest-style `jest.fn()` in a Vitest project (`vi.fn()`).

## Testing conventions worth stating

- Unit tests next to or mirroring `src/`, named `*.test.ts`.
- `pnpm test` and `pnpm typecheck` both green before commit.
- For Next.js, prefer testing `server/` functions directly over rendering pages.
