# workFlow

一個 Claude Code plugin。核心是 `bootstrap-claude-md` 這個 skill：
當使用者要開一個新專案時，先訪談釐清專案性質，再產出一份針對該專案量身訂做的 CLAUDE.md，
以及一份最小可用的專案骨架建議。

這個 repo 本身沒有應用程式程式碼。所有產出都是 Markdown、YAML frontmatter 和少量 shell script。
不需要 build、不需要安裝依賴。

規格文件在 `docs/spec.md`，動手改 skill 之前先讀它。

## 目錄結構

```
workFlow/
├── CLAUDE.md                    # 本檔，給在這個 repo 工作的 Claude 看
├── README.md                    # 給人看的安裝與使用說明
├── docs/
│   └── spec.md                  # 規格，單一事實來源
├── .claude-plugin/
│   ├── plugin.json              # plugin 名稱、版本、描述
│   └── marketplace.json         # 讓使用者能用 /plugin marketplace add 安裝
└── skills/
    └── bootstrap-claude-md/
        ├── SKILL.md             # skill 主體，500 行以內
        ├── references/          # 需要時才載入的參考資料
        │   ├── claude-md-anatomy.md    # 一份好的 CLAUDE.md 該有哪些區塊、為什麼
        │   ├── interview.md            # 訪談題庫與追問邏輯
        │   └── stacks/                 # 各技術棧的慣例，一個檔案一個棧
        ├── assets/
        │   └── CLAUDE.md.template      # 產出用的範本
        ├── scripts/
        │   └── detect.sh               # 偵測資料夾狀態，只印事實不做判斷
        └── evals/                      # 測試案例，一個資料夾一個案例
```

## 技術決策

- **純 Markdown skill，不寫應用程式。** 這個工具的使用者就是 Claude Code 本身，skill 是它原生支援的擴充格式。
  寫成 CLI 或 web app 只會多一層不必要的東西。
- **以 plugin 形式發布。** 使用者執行 `/plugin marketplace add wadeken/workFlow` 就能裝，更新也走同一條路。
  個人本機測試用 `claude --plugin-dir /path/to/workFlow`。
- **skill 指令本文用英文，面向人的文件用繁體中文。** SKILL.md 和 references 是給模型讀的指令，英文版本在各種模型上表現最穩定。
  README、spec、commit message 用繁體中文，因為讀者是人。產出的 CLAUDE.md 語言由訪談時詢問使用者決定。
- **shell script 只做確定性的事。** 例如偵測 package.json、go.mod、pyproject.toml 是否存在。
  任何需要判斷的事都留給 SKILL.md 的指令，不要寫進 script。

## 撰寫 skill 的規範

- SKILL.md 保持在 500 行以內。超過就拆進 `references/`，並在 SKILL.md 明確寫出「什麼情況下去讀哪個檔案」。
- 用祈使句寫指令，並說明為什麼。模型理解理由之後的表現，比死守全大寫的 MUST 好。
- frontmatter 的 `description` 是觸發的唯一依據。要同時寫「做什麼」和「什麼情境下該用」，語氣可以稍微積極，
  因為目前模型傾向少觸發而不是多觸發。
- 範例要有代表性，不要只針對 evals 裡的案例調整。這個 skill 會被用在我們沒看過的專案上。
- `references/stacks/` 裡的每個檔案獨立成立。模型只會載入當前專案用到的那一個。

## 測試

- 每個測試案例是 `skills/bootstrap-claude-md/evals/<case-name>/` 底下的一個資料夾，含 `prompt.md`、`case.yaml`
  與 `graders/`（一個檔案一條可驗證的敘述）。需要預先放檔案或 git init 的案例加 `place-files.sh`。
  案例名稱用小寫加連字號，說明它在測什麼，例如 `nextjs-saas-from-scratch`。
- 跑測試：`claude plugin eval` 會讀取上述格式。手動測試則開一個空資料夾，用 `claude --plugin-dir` 載入本 repo，
  輸入 prompt.md 的內容，檢查產出的 CLAUDE.md。
- 改動 SKILL.md 之後，至少跑一個 eval 確認沒退步，再 commit。

## Git 規範

- 在指定的功能分支上開發，不直接推 main。
- 每個 commit 只做一件事。commit message 用繁體中文，第一行 50 字以內說明「改了什麼」，
  需要時在本文說明「為什麼」。
- spec 有變動時，同一個 commit 一起更新 `docs/spec.md`，避免規格與實作分叉。

## 不要做的事

- 不要在這個 repo 加入 Node、Python 或任何語言的專案設定檔。它是 plugin，不是應用程式。
- 不要為了讓某個 eval 通過而在 SKILL.md 加入只對該案例有效的特例。
- 不要把產出的 CLAUDE.md 寫成通用模板直接貼上。整個 skill 的價值就在於針對專案客製，
  沒有訪談或沒有偵測專案狀態就直接產出，等於沒做事。
