# Go conventions

Load this when the project is Go: an HTTP service, a CLI, a worker, a library.

## Defaults to propose when the user has no preference

| Concern | Default | Why this one |
|---|---|---|
| Version | Latest stable Go (1.23+), set in go.mod | Toolchain is managed by `go` itself |
| Modules | `go mod`, module path = repo URL | Standard |
| Test runner | `go test` | Built in; add testify only if the user wants assertions |
| Lint | `golangci-lint` with the default linter set, plus `gofmt`/`goimports` | Community standard |
| HTTP | `net/http` with Go 1.22+ routing; chi if the user wants middleware helpers | Stdlib is enough for most services now |
| CLI | cobra for multi-command, stdlib `flag` for single-command | |
| Config | env vars, parsed in `main`; no config framework by default | |
| Build | `go build ./...`; Makefile or Taskfile only if the user already uses one | |

## Commands that actually run

```bash
go mod tidy                          # sync go.mod/go.sum
go build ./...                       # compile everything
go test ./...                        # all tests
go test -race ./...                  # with race detector; run before merging concurrency changes
go vet ./...                         # static checks
gofmt -l .                           # list unformatted files (should print nothing)
golangci-lint run                    # lint, if installed
go run ./cmd/<name>                  # run a binary
```

Note `golangci-lint` is a separate install; detect does not check for it. Mention that in the
CLAUDE.md or 待決事項 if you list it.

## Starting layouts

Service:
```
cmd/<name>/main.go     # wiring only: config, deps, start server
internal/
  http/                # handlers, routing, middleware
  <domain>/            # business logic per domain, no HTTP types
  store/               # database access
go.mod
```

CLI:
```
cmd/<name>/main.go     # cobra root, or flag parsing
internal/
  <domain>/            # logic, testable without the CLI
go.mod
```

Library:
```
<pkg>.go               # public API at module root
<pkg>_test.go
internal/              # anything not for export
go.mod
```

Keep `internal/` for everything not meant to be imported by other modules. Avoid a `pkg/`
directory unless the project is explicitly a library with multiple public packages.

## Mistakes Claude commonly makes in this stack

- Ignoring returned errors or using `_` to silence them.
- Panicking in library code instead of returning an error.
- Putting business logic in handlers.
- Forgetting `go mod tidy` after adding an import, so the build breaks in CI.
- Creating a `utils` package. Suggest naming packages by what they provide.
- Goroutine leaks: starting goroutines without a way to stop them. `go test -race` catches
  some of this; say so in 測試要求.

## Testing conventions worth stating

- Table-driven tests, `_test.go` beside the code.
- `go test ./...` and `go vet ./...` green before commit; `-race` before merging anything
  with goroutines.
- No network or filesystem in unit tests; use interfaces and fakes in `internal/`.
