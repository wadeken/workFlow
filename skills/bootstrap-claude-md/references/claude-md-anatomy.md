# Anatomy of a good CLAUDE.md

CLAUDE.md is loaded at the start of every session in the repo. Two consequences:

1. Every line costs context on every task. Short wins.
2. Anything wrong in it will be acted on, repeatedly, without anyone noticing. Specific wins.

So the file should contain only things that are (a) true for this project specifically,
(b) not obvious from looking at the code, and (c) likely to change what Claude does.
Framework documentation fails (b). "Write clean code" fails (a) and (c).

## The eight sections

### 1. 專案是什麼 (What this is)

Two or three sentences. Name the thing, who uses it, what stage it is at.

Good:
> 內部用的廠商發票審核工具，給 ops 團隊五個人用。目前是 prototype，還沒上線，資料用假資料。

Bad:
> 這是一個現代化、可擴展的企業級解決方案，用於簡化發票處理流程。

The bad one tells Claude nothing it can act on. The good one tells it to prefer speed over
polish, that there are no real users to protect yet, and that fixtures are fine.

### 2. 技術棧 (Stack)

One line per item: language and version, framework, package manager, test runner, linter.
Versions matter because Claude's defaults may be a major version behind.

Good:
> - TypeScript 5.x, Node 22
> - Next.js 15, App Router
> - pnpm
> - Vitest for tests, Biome for lint and format

Bad:
> - 使用最新的 JavaScript 技術

### 3. 常用指令 (Commands)

A fenced block of commands Claude will actually run: install, dev, test, lint, build.
Each line runs as-is. A trailing comment says what it does. If the project is empty, these
are the commands that will work once the planned layout exists; say so above the block.

Good:
```bash
pnpm install          # 安裝依賴
pnpm dev              # 開發伺服器 http://localhost:3000
pnpm test             # Vitest，一次性執行
pnpm lint             # Biome check
pnpm build            # 正式 build，commit 前要過
```

Bad:
> 用 npm 或 pnpm 跑測試和 lint。

The bad one makes Claude guess the script name every time.

### 4. 目錄結構 (Layout)

A tree of the top level, with one comment per entry. Mark planned entries with "(planned)"
when the folder is empty. Keep it to the directories that decide where new code goes.

Good:
```
src/
  app/        # Next.js routes，只放 page/layout/route，不放邏輯
  server/     # 資料庫存取與商業邏輯，app/ 只能呼叫這裡
  components/ # 共用 UI
tests/        # Vitest，鏡像 src/ 的結構
```

Bad: a 60-line tree listing every file. Claude can run `ls`.

### 5. 工作方式 (How we work)

Branching, commit message format, how large a change gets before it is split, when a PR is
opened. Only what the user actually wants; the stack reference supplies defaults if they
do not care.

Good:
> - 功能分支開發，不直接推 main。
> - Commit message 用 conventional commits，繁體中文描述。
> - 一個 commit 只做一件事。超過 300 行的改動先拆。

### 6. 測試要求 (Testing)

Which changes need tests, what green means, what to do when red.

Good:
> - 任何 `src/server/` 的改動都要有對應測試。
> - `pnpm test` 和 `pnpm lint` 都過才能 commit。
> - 測試失敗時先修測試對應的程式，不要改測試讓它過。

### 7. 不要做的事 (Never do this)

The user's own restrictions, one bullet each, with the reason when they gave one.
This section is the one Claude is most likely to violate without it, and the one most
often left empty by generic templates. Never pad it. If the user named nothing, write
exactly that: "目前沒有特別限制。"

Good:
> - 不要修改 `infra/` 底下的任何檔案，那是 Terraform 管的。
> - 不要執行 `pnpm deploy`，部署只能從 CI 跑。
> - 不要加新的 UI 套件，只用 shadcn/ui 現有的元件。

Bad:
> - 不要寫有 bug 的程式碼。
> - 遵循最佳實踐。

### 8. 待決事項 (Open questions)

Everything the user said is undecided, plus every assumption Claude made because it could
not ask. One bullet each. Write "無" when the list is empty.

This section is what keeps the rest honest. A later session reading "stack: Go, chosen by
recommendation, not yet confirmed" knows to check before building on it.

## Length

150 lines maximum. Most good ones are 60 to 100. When a section wants more, write one line
pointing to `docs/<topic>.md` and put the detail there. CLAUDE.md is the index, not the book.

## What to leave out

- Anything the framework's own docs cover.
- Anything Claude can learn by running `ls` or reading `package.json`.
- Motivational or stylistic advice with no project-specific content.
- Long explanations of why. One clause of reason per rule is plenty.
- Secrets, tokens, internal hostnames. The file is committed.

## Headings in other languages

When the user chose English, use: What this is, Stack, Commands, Layout, How we work,
Testing, Never do this, Open questions. Keep the same order.
