---
tags: [bootstrap-claude-md]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, AskUserQuestion]
---

我想在這個空資料夾開一個新專案，幫我寫 CLAUDE.md。

專案是給我們 ops 團隊五個人用的內部工具，審核廠商發票：上傳 PDF、填金額、主管按核准或退回。目前是 prototype，還沒有真實資料。
技術用 Next.js 15 App Router 加 Postgres，ORM 用 Drizzle，套件管理用 pnpm，部署在 Vercel。測試用 Vitest，lint 用 Biome。
規矩：不要動 infra/ 底下的東西，那是 Terraform 管的；不要自己跑部署，部署只能走 CI；UI 只用 shadcn/ui 現有的元件，不要加新的 UI 套件。
CLAUDE.md 用繁體中文寫。我已經把需要的都講了，不用再問我，直接寫。
