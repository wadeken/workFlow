# workFlow 規格 v0.1

狀態：v0.1 實作中
最後更新：2026-11-05

## 1. 一句話說明

一個 Claude Code plugin，內含 `bootstrap-claude-md` skill。
當使用者要開新專案時，skill 會先訪談、再偵測目前資料夾的狀態，最後產出一份針對該專案量身訂做的 CLAUDE.md。

## 2. 背景與動機

每個新專案的 CLAUDE.md 都要從頭想一次：用什麼語言、測試怎麼跑、commit 怎麼寫、哪些事不准做。
現有的 skill pack（Pocock、Osmani、pstack）提供通用的工程流程，但都假設 CLAUDE.md 已經存在，
沒有一個負責「第一份 CLAUDE.md 該長什麼樣」。這個 skill 補的就是這一塊。

## 3. 使用者與情境

主要使用者是 repo 擁有者本人，次要使用者是任何裝了這個 plugin 的 Claude Code 使用者。

典型情境：

- **從零開始**：空資料夾，使用者說「我想做一個 X」。skill 訪談後產出 CLAUDE.md 和骨架建議。
- **既有專案補 CLAUDE.md**：資料夾裡已經有 code 但沒有 CLAUDE.md。skill 先讀專案再訪談，問題會少很多。
- **重寫過時的 CLAUDE.md**：已有 CLAUDE.md 但專案已經長得不一樣。skill 比對現況與文件，提出修改版。

v0.1 先做第一種，第二、三種列為後續版本。

## 4. 範圍

### v0.1 要做

- 一個 skill：`bootstrap-claude-md`。
- 訪談流程：固定的核心問題加上依回答追問，直到足以填滿 CLAUDE.md 的每個區塊。
- 專案偵測：用 shell script 檢查資料夾是否為空、是否已有 git、是否有語言設定檔。
- 技術棧參考：至少涵蓋 TypeScript/Node、Python、Go 三種，各自一個 reference 檔。
- 產出：一份 CLAUDE.md，寫入目前資料夾。若已存在則先備份再詢問是否覆蓋。
- 產出的語言由使用者在訪談時選擇，預設繁體中文。
- plugin 包裝：`.claude-plugin/plugin.json` 與 `marketplace.json`，可用 `/plugin marketplace add` 安裝。
- 四個 eval 案例。

### v0.1 不做

- 不產生應用程式碼，只產生 CLAUDE.md 和一段「建議的第一步」文字。
- 不自動安裝 Pocock、Osmani 或任何第三方 skill pack，只在產出中建議。
- 不處理 monorepo 或多語言專案。
- 不做既有專案的 CLAUDE.md 更新。
- 不做 Claude Code 以外的 agent 支援（Codex、Cursor 等）。

## 5. 技術決策

| 項目 | 決定 | 理由 |
|---|---|---|
| 實作形式 | Claude Code skill，純 Markdown | 使用者就是 Claude Code，skill 是原生格式，不需額外 runtime |
| 安裝名稱 | plugin `workflow`，marketplace `wadeken-workflow`，skill 呼叫為 `/workflow:bootstrap-claude-md` | 與 repo 名對齊，日後可在同一 marketplace 加其他 plugin |
| 發布方式 | plugin marketplace | 一行指令安裝、自動更新，和 Pocock、Osmani 的做法一致 |
| 確定性邏輯 | bash script | 偵測檔案存在這類事交給 script，省 token 也不會判斷錯 |
| 指令語言 | 英文 | 給模型讀的指令英文最穩定；面向人的文件用繁體中文 |
| 測試 | `claude plugin eval` 格式 | 本機和 CI 都能跑，不用自己寫測試框架 |

## 6. 運作流程

```
使用者：「幫我開一個新專案」或「幫我寫這個專案的 CLAUDE.md」
   │
   ▼
① 偵測  scripts/detect.sh
   讀取：資料夾是否為空、.git 是否存在、package.json / pyproject.toml / go.mod / Cargo.toml 等
   輸出：一段簡短的事實清單，不做判斷
   │
   ▼
② 訪談  references/interview.md
   核心問題（每題必問）：
     1. 這個專案做什麼、給誰用
     2. 語言與框架（若偵測到則確認即可）
     3. 執行形式：web、CLI、函式庫、服務
     4. 測試與 lint 指令（沒有的話問要不要建）
     5. 絕對不能做的事（例如不准碰 prod 設定、不准改某個目錄）
     6. CLAUDE.md 要用什麼語言寫
   追問規則：某一題答案模糊到無法寫進 CLAUDE.md 時才追問，一次只問一題
   │
   ▼
③ 載入技術棧參考  references/stacks/<stack>.md
   只載入一個。檔案內是該技術棧的慣例：目錄結構、測試指令、常見陷阱
   │
   ▼
④ 產出  assets/CLAUDE.md.template
   依範本填入訪談結果，寫到 ./CLAUDE.md
   若已存在：複製為 CLAUDE.md.bak 後詢問是否覆蓋
   │
   ▼
⑤ 收尾
   列出「建議的第一步」：要不要裝 Pocock skills、第一個要建的檔案、第一個要跑的指令
```

## 7. 產出的 CLAUDE.md 規格

產出必須包含以下區塊，順序固定。每個區塊都要有專案專屬的內容，不能是佔位文字。

1. **專案是什麼**：兩到三句，含使用者是誰。
2. **技術棧**：語言、框架、套件管理工具、版本。
3. **常用指令**：安裝、開發、測試、lint、build。每個指令一行，可直接複製執行。
4. **目錄結構**：目前或預計的結構，附一行說明。
5. **工作方式**：怎麼開分支、commit message 格式、改動多大要拆 PR。
6. **測試要求**：什麼改動一定要附測試、測試跑不過不准 commit。
7. **不要做的事**：訪談第 5 題的答案，逐條列出。
8. **待決事項**：訪談中使用者說「還沒決定」的項目，列出來避免 Claude 自己猜。

長度上限 150 行。超過代表內容該拆到 docs/ 裡。

## 8. 專案結構

見 `CLAUDE.md` 的目錄結構一節。本節不重複。

## 9. 驗收標準

v0.1 完成的定義：

- [ ] 在空資料夾執行 skill，不先問問題就直接產出 CLAUDE.md 視為失敗。
- [ ] 訪談六題核心問題都問到，而且不會問偵測已經知道答案的問題。
- [ ] 產出的 CLAUDE.md 八個區塊齊全，沒有「TODO」或「請填入」之類的佔位文字。
- [ ] 常用指令區塊的每一行都能在該技術棧下實際執行。
- [ ] 資料夾已有 CLAUDE.md 時會先備份再詢問。
- [ ] 四個 eval 案例在 `claude plugin eval` 下通過。
- [ ] `/plugin marketplace add wadeken/workFlow` 可以成功安裝。

## 10. Eval 案例

eval 在無人回答的環境下執行，所以需要完整產出的案例都在 prompt 裡講明「不用問我」。
訪談行為由第四個案例單獨驗證。

| 案例名稱 | 情境 | 主要檢查點 |
|---|---|---|
| `empty-folder-nextjs-saas` | 空資料夾，使用者一次講完所有資訊並要求直接寫 | 不多問、跑過 detect、三條禁令逐字寫入、全用 pnpm、無佔位文字 |
| `python-cli-with-existing-git` | 已 git init 與 .gitignore，沒有程式碼，Python CLI | 不重跑 git init、選 Python 參考檔、uv 指令、不捏造禁令 |
| `undecided-stack` | 「想做工作流自動化，還沒決定語言，不用問我」 | 只推薦一個技術棧並說理由、待決事項記錄假設、不卡住 |
| `asks-before-writing-when-vague` | 空資料夾，只說「幫我開一個新專案」 | 不寫檔、跑過 detect、只問一題、用繁體中文問 |

## 11. 開放問題

- 訪談要一次問完六題，還是一題一題問？v0.1 採一題一題，理由寫在 `references/interview.md`。eval 後再決定是否改。
- 使用者說「不用問我」或在無法回答的環境下執行時，skill 會自行假設並全部列進待決事項。這個行為是否該有開關？
- `references/stacks/` 要不要包含 Rust 和 Java？先看前三個穩定後再加。
- 產出後要不要主動建議裝 Pocock skills？目前傾向建議但不自動安裝，由使用者決定。
- 是否要支援產出 `.claude/settings.json` 的 permissions 建議？可能是 v0.2 的範圍。

## 12. 里程碑

| 版本 | 內容 |
|---|---|
| v0.1 | 本文件描述的範圍。空資料夾情境、三種技術棧、三個 eval |
| v0.2 | 既有專案補 CLAUDE.md、settings.json 建議、更多技術棧 |
| v0.3 | 過時 CLAUDE.md 的比對更新、monorepo |

## 13. 進度

- [x] `.claude-plugin/plugin.json` 與 `marketplace.json`。plugin 名稱 `workflow`，marketplace 名稱 `wadeken-workflow`。
- [x] `SKILL.md` 第一版，含五步流程、三個範例、反模式清單。
- [x] `references/interview.md`、`references/claude-md-anatomy.md`、三個 `stacks/` 檔、`assets/CLAUDE.md.template`、`scripts/detect.sh`。
- [x] 四個 eval 案例的 prompt、case.yaml、graders。
- [ ] 第一輪 eval 結果與修正（見 `docs/eval-log.md`）。
- [ ] 用 `/plugin marketplace add wadeken/workFlow` 實際安裝一次確認可用。
