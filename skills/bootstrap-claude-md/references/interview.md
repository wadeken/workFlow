# Interview guide

The interview exists to collect exactly what the CLAUDE.md template needs and nothing more.
Six core questions, asked one at a time, skipping any whose answer you already have.

## Before you ask anything

Check three sources, in this order:

1. **detect.sh output.** Language markers, lockfiles, git state, installed toolchains.
2. **The user's opening message.** People often answer three questions in their first sentence.
3. **Files in the folder.** README, package.json description, existing docs.

Anything found there becomes a one-line confirmation, not a question.

## The six core questions

### Q1. What is it and who is it for?

Fills: 專案是什麼.
Writable answer: one or two sentences naming the thing, its users, and its stage
(prototype, internal tool, product).
Follow up if: the answer is a category ("a web app", "a tool") rather than a description.
Ask: "What will someone do with it on day one?"

### Q2. Language and framework

Fills: 技術棧, and decides which stacks/ reference to load.
Writable answer: language, framework if any, package manager.
Skip if: detect found markers. Confirm instead: "pyproject.toml with uv, so Python with uv?"
Follow up if: the user names a language but no framework and the project obviously needs one
(a web app with no framework named). Offer the conventional choice and ask yes/no.
If undecided: do not push. Say you will recommend one and record it as unconfirmed.

### Q3. Execution form

Fills: 技術棧, 目錄結構, parts of 常用指令.
Writable answer: one of web app with UI, API or background service, CLI, library/package,
mobile, desktop. Plus where it runs if they know (Vercel, a VPS, local only).
Follow up if: they say "both" or "not sure". Ask which one they would build first.

### Q4. Test, lint, build commands

Fills: 常用指令, 測試要求.
Writable answer: the exact commands, or "none yet, please propose".
Skip if: package.json scripts or a Makefile already define them.
If "none yet": take the defaults from the stack reference and say you did so.
Follow up if: they name a tool but not the command. Propose the command and confirm.

### Q5. Things Claude must never do here

Fills: 不要做的事.
Writable answer: concrete restrictions. Directories not to touch, files not to edit,
commands not to run, services not to call, patterns the user hates.
This is the question users most often have not thought about. Give two examples to prime
them: "For example: never edit the migrations folder, never run the deploy script."
If they say "nothing comes to mind": write "目前沒有特別限制" in the section. Do not invent any.

### Q6. Output language

Fills: the language of the whole CLAUDE.md.
Ask only if the user's messages do not make it obvious. Someone writing to you in Traditional
Chinese almost certainly wants Traditional Chinese. Someone writing in English wants English.
When genuinely unclear, ask. Default when you cannot ask: Traditional Chinese.

## Follow-up rules

- One follow-up per question at most. If the second answer is still vague, write what you have
  and note the gap in 待決事項.
- A follow-up is for turning an unwritable answer into a writable one. It is not for curiosity.
- Never ask two questions in one message. The second one gets a worse answer.
- Keep each question under three sentences. Say why you are asking when it is not obvious:
  "I'm asking about restrictions because they go in a section Claude reads every session."

## When to stop

Stop as soon as every template section can be filled without placeholders. That is usually
after four or five exchanges, sometimes two. Asking a sixth question when five sections are
already full is wasting the user's time.

## When the user cannot or will not answer

Three situations:

- **"Don't ask me, just do it."** Respect it fully. Make the most conventional choice for each
  gap, write the file, list every choice under 待決事項.
- **Non-interactive run** (no reply comes back, or the environment has no way to ask). Same as
  above. Do not end your turn with a question and no file; that leaves the user with nothing.
- **Partial refusal** ("I don't care about commit style"). Pick the convention from the stack
  reference and note it as an assumption.

In all three cases the 待決事項 section is where the honesty lives. A reader must be able to
tell what the user decided and what Claude assumed.

## Tone

You are a colleague setting up a repo with them, not a form. Short questions, one at a time,
acknowledge the answer in a few words before the next question. Do not summarise the whole
conversation back to them; the CLAUDE.md is the summary.
