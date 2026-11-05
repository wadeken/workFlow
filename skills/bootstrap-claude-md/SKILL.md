---
name: bootstrap-claude-md
description: Write a project-specific CLAUDE.md for a new (greenfield) project by first inspecting the folder and then interviewing the user, then suggest the first concrete steps. Use this whenever the user wants to start a new project, set up a repo for Claude Code, asks for a CLAUDE.md, says things like "kick off", "bootstrap", "scaffold", "new project", "開新專案", "幫我寫 CLAUDE.md", "幫我建專案", or describes something they want to build while sitting in an empty or nearly empty folder, even if they never say the words CLAUDE.md. Do not use it to update an existing, up-to-date CLAUDE.md in a mature codebase.
---

# Bootstrap CLAUDE.md

You are about to write the first CLAUDE.md for a project. That file is read at the start of
every future Claude Code session in this repo, so a vague or wrong one costs the user on every
task for months. A good one is short, specific to this project, and contains nothing the user
would disagree with. Everything below exists to get you there.

The one thing that makes this skill worth running: **the output is tailored**. A CLAUDE.md you
could have written without looking at the folder or talking to the user is a failure, even if
it looks polished.

## Workflow

```
1. Detect   → run scripts/detect.sh, read the facts
2. Interview → references/interview.md, one question at a time, skip what detect answered
3. Pick stack → references/stacks/<stack>.md, load exactly one
4. Write    → assets/CLAUDE.md.template, 8 sections, ≤150 lines
5. Wrap up  → suggest first steps, do not install anything
```

### 1. Detect

Run the script from this skill's directory against the user's current folder:

```bash
bash <skill-dir>/scripts/detect.sh .
```

It prints plain facts: whether the folder is empty, whether git is initialised, which language
markers and lockfiles exist, which toolchains are installed on this machine. It never judges.
Read the output and remember it: every fact there is a question you no longer need to ask.
If the folder already has code, skim the top-level layout and any README before interviewing.
Asking "which language will you use?" when there is a `go.mod` in front of you is the fastest
way to lose the user's trust.

### 2. Interview

Read `references/interview.md` now. It holds the six core questions, the follow-up rules, and
what to do when the user cannot or will not answer.

The rules that matter most:

- **One question per turn.** Use the AskUserQuestion tool when it is available, otherwise ask in
  plain text and end your turn. Batching six questions produces six shallow answers.
- **Skip what you already know.** From detect output, from the user's opening message, from
  files in the folder. Confirm in one line instead of asking: "I see a pyproject.toml with uv,
  so Python with uv. Correct?"
- **Follow up only when the answer cannot be written into CLAUDE.md as-is.** "A web app" is not
  writable. "Next.js 15 App Router with Postgres via Drizzle" is. Stop following up the moment
  you have something writable.
- **Stop when every section of the template can be filled.** Do not ask for completeness' sake.
- **If the user says not to ask**, or the opening message already covers everything, or you are
  running non-interactively, skip the interview, make the most conventional assumption for each
  gap, and list every assumption in the 待決事項 section so nothing is silently decided.

### 3. Pick the stack reference

Load exactly one of these, based on the interview:

| Stack | File | Load when |
|---|---|---|
| TypeScript / Node | `references/stacks/typescript.md` | Next.js, Hono, Express, React, Node CLI, Bun |
| Python | `references/stacks/python.md` | FastAPI, Django, Flask, scripts, data work, Python CLI |
| Go | `references/stacks/go.md` | services, CLIs, anything the user calls "Go" |
| Other / undecided | none | see below |

Each file gives you the conventional tooling, the commands that actually run, a sensible
starting layout, and the mistakes Claude commonly makes in that stack. Use it to fill the
技術棧, 常用指令, 目錄結構 and 測試要求 sections with things that are true for that stack.

If the user has **not decided** on a stack, recommend one. Base the recommendation on what
they are building and what toolchains detect found installed, state the reason in one or two
sentences, write the CLAUDE.md for that stack, and record "stack chosen by recommendation, user
has not confirmed" in 待決事項. Do not stall the whole process on an undecided question.

If the stack is something else (Rust, Ruby, Java, Swift...), proceed without a reference file,
be more conservative about commands you are not sure of, and ask the user to confirm the test
and lint commands specifically.

### 4. Write the file

Read `references/claude-md-anatomy.md` once before writing. It explains what each of the eight
sections is for and shows a good and a bad example of each. Then fill `assets/CLAUDE.md.template`.

Hard requirements for the output:

- **Eight sections, in the template's order.** 專案是什麼, 技術棧, 常用指令, 目錄結構, 工作方式,
  測試要求, 不要做的事, 待決事項. Translate the headings if the user chose another language.
- **No placeholder text.** No "TODO", no "請填入", no "e.g.", no template comments left behind.
  If you do not know something, it belongs in 待決事項, not in a placeholder.
- **Every command in 常用指令 must run as-is.** If the project is empty, these are the commands
  that will work once the scaffold described in 目錄結構 exists. Check them against the stack
  reference.
- **At most 150 lines.** A longer CLAUDE.md gets skimmed, not read. If a section wants to grow,
  write one line pointing to a `docs/` file instead.
- **不要做的事 contains the user's answers, not yours.** Generic advice like "write clean code"
  has no place there. If the user gave no restrictions, write that explicitly.
- **Language as the user chose.** Default to Traditional Chinese when they did not say.

If `./CLAUDE.md` already exists: copy it to `./CLAUDE.md.bak` first, then show the user a short
summary of what would change and ask before overwriting. Never overwrite silently.

Write the file to `./CLAUDE.md` in the user's current folder.

### 5. Wrap up

After writing, reply with a short message, not a restatement of the file:

1. Where the file is and how many lines.
2. The assumptions you made, if any (same list as 待決事項).
3. **Suggested first steps**, three at most, concrete to this project. For example: the first
   scaffold command to run, the first file to create, whether a process skill pack such as
   mattpocock/skills would help once code exists. Suggest, do not install.

## Examples

**Example 1: empty folder, chatty opening message**

Input: "I want to build a small internal tool for our ops team to approve vendor invoices.
Next.js, Postgres, deploy on Vercel. We use pnpm. Please don't touch anything under infra/."

What to do: detect confirms empty folder and that pnpm is installed. Skip questions 1, 2, 3
and most of 5. Ask only about test/lint commands (question 4) and output language (question 6).
Load `stacks/typescript.md`. 不要做的事 gets "不要修改 infra/ 底下的任何檔案" verbatim.

**Example 2: git already initialised, nothing else**

Input: "Python CLI that renames photos by EXIF date."

What to do: detect shows `.git` with zero commits and `uv` installed. Do not ask about git.
Confirm "Python with uv?" in one line, then ask about test command, restrictions, and language.
Load `stacks/python.md`. 目錄結構 is planned, so mark entries with "(planned)".

**Example 3: user refuses the interview**

Input: "Workflow automation thing, haven't picked a language, just use your judgement and
don't ask me anything."

What to do: skip the interview. Recommend a stack from what detect found installed, explain why
in two sentences, write the file, and put every assumption (stack, test runner, commit style,
language of the file) under 待決事項.

## Anti-patterns

Each of these has happened. Each makes the output worse than no CLAUDE.md at all.

- Writing the file before asking anything, in an empty folder, with a vague opening message.
- Asking a question whose answer is sitting in detect output or in the user's first message.
- Filling 不要做的事 with generic engineering advice the user never said.
- Leaving template comments or "TODO" in the output.
- Producing a 300-line CLAUDE.md that documents the framework instead of the project.
- Installing a skill pack or running a scaffold generator without being asked. The job ends at
  CLAUDE.md plus suggestions.
