# Python conventions

Load this when the project is Python: FastAPI, Django, Flask, a CLI, scripts, data or ML work.

## Defaults to propose when the user has no preference

| Concern | Default | Why this one |
|---|---|---|
| Version | Python 3.12 | Current stable with wide library support |
| Env + packages | uv | One tool for venv, lock, install, run; far faster than pip + venv |
| Project file | pyproject.toml | Standard; uv, ruff and pytest all read it |
| Test runner | pytest | De facto standard |
| Lint + format | ruff (`ruff check`, `ruff format`) | Replaces flake8, isort, black in one fast tool |
| Type check | mypy or pyright, only if the user wants types enforced | Optional; ask |
| Web framework | FastAPI for APIs, Django when the user needs admin/auth/ORM out of the box | |
| CLI framework | typer (built on click) | Type-hint driven, minimal boilerplate |

If detect found `requirements.txt` or `poetry.lock`, use that tooling instead of uv. Do not
migrate tooling unasked.

## Commands that actually run

With uv:
```bash
uv sync                      # create .venv and install from lock
uv run pytest                # tests
uv run pytest -x -q          # stop at first failure
uv run ruff check .          # lint
uv run ruff format .         # format
uv run python -m <pkg>       # run the package
uv run uvicorn app.main:app --reload   # FastAPI dev server
```

With pip + venv (when that is what the folder uses):
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pytest
ruff check .
```

## Starting layouts

Use the `src/` layout. It prevents the classic bug where tests import the working copy by
accident instead of the installed package.

FastAPI service:
```
src/<pkg>/
  main.py       # app factory, router includes only
  api/          # routers, one per resource; no business logic
  services/     # business logic, no HTTP types
  models.py     # pydantic schemas
  db/           # engine, session, migrations (alembic)
tests/
pyproject.toml
```

CLI:
```
src/<pkg>/
  __init__.py
  cli.py        # typer app, arg parsing only
  core.py       # logic, importable and testable without the CLI
tests/
pyproject.toml  # [project.scripts] <name> = "<pkg>.cli:app"
```

Scripts / data work:
```
src/<pkg>/      # reusable code
scripts/        # one-off entry points that import from src/
data/           # gitignored unless small fixtures
notebooks/      # if any; outputs stripped before commit
tests/
```

## Mistakes Claude commonly makes in this stack

- Running `pip install` inside a uv project, or `uv add` inside a pip project.
- Forgetting the `src/` layout and then hitting `ModuleNotFoundError` in tests.
- Putting logic in `cli.py` so it cannot be tested without invoking the CLI.
- Catching bare `except:`; suggest ruff's default rules, which flag it.
- Mutable default arguments.
- Mixing sync and async in FastAPI (blocking calls inside `async def`).

## Testing conventions worth stating

- `tests/` mirrors `src/<pkg>/`, files named `test_*.py`.
- `uv run pytest` and `uv run ruff check .` both green before commit.
- Fixtures in `tests/conftest.py`; no network in unit tests.
