#!/usr/bin/env bash
# Print plain facts about the current directory. No judgement, no recommendations.
# The skill reads this output to skip interview questions that are already answered.
set -u
cd "${1:-.}" || exit 1

echo "cwd: $(pwd)"

count=$(find . -mindepth 1 -maxdepth 1 ! -name '.git' | wc -l | tr -d ' ')
if [ "$count" -eq 0 ]; then echo "folder: empty (ignoring .git)"; else echo "folder: $count top-level entries"; fi

if [ -d .git ]; then
  echo "git: initialised"
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "unborn")
  echo "git_branch: $branch"
  commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
  echo "git_commits: $commits"
  remote=$(git remote get-url origin 2>/dev/null || echo "none")
  echo "git_remote: $remote"
else
  echo "git: none"
fi

for f in CLAUDE.md README.md AGENTS.md .gitignore .editorconfig; do
  [ -e "$f" ] && echo "has: $f"
done

# language / tooling markers
[ -e package.json ]       && echo "marker: package.json (node)"
[ -e tsconfig.json ]      && echo "marker: tsconfig.json (typescript)"
[ -e pnpm-lock.yaml ]     && echo "marker: pnpm-lock.yaml (pnpm)"
[ -e yarn.lock ]          && echo "marker: yarn.lock (yarn)"
[ -e package-lock.json ]  && echo "marker: package-lock.json (npm)"
[ -e bun.lockb ] || [ -e bun.lock ] && echo "marker: bun lockfile (bun)"
[ -e pyproject.toml ]     && echo "marker: pyproject.toml (python)"
[ -e requirements.txt ]   && echo "marker: requirements.txt (python/pip)"
[ -e uv.lock ]            && echo "marker: uv.lock (uv)"
[ -e poetry.lock ]        && echo "marker: poetry.lock (poetry)"
[ -e go.mod ]             && echo "marker: go.mod (go)"
[ -e Cargo.toml ]         && echo "marker: Cargo.toml (rust)"
[ -e Gemfile ]            && echo "marker: Gemfile (ruby)"
[ -e pom.xml ]            && echo "marker: pom.xml (java/maven)"
[ -e build.gradle ] || [ -e build.gradle.kts ] && echo "marker: gradle (java/kotlin)"
[ -e Dockerfile ]         && echo "marker: Dockerfile"
[ -e docker-compose.yml ] || [ -e compose.yaml ] && echo "marker: docker compose"
[ -d .github/workflows ]  && echo "marker: .github/workflows (github actions)"

if [ -e package.json ] && command -v node >/dev/null 2>&1; then
  node -e 'const p=require("./package.json");console.log("package_name:",p.name||"(none)");console.log("package_scripts:",Object.keys(p.scripts||{}).join(", ")||"(none)")' 2>/dev/null
fi

# toolchains available on this machine
for t in node pnpm npm bun python3 uv go cargo docker; do
  if command -v "$t" >/dev/null 2>&1; then
    if [ "$t" = go ]; then v=$(go version 2>/dev/null); else v=$("$t" --version 2>/dev/null | head -1); fi
    echo "tool: $t ($v)"
  fi
done
