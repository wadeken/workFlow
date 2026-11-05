# Eval 紀錄

每一輪 eval 的結果與據此對 skill 做的修改。案例定義在 `skills/bootstrap-claude-md/evals/`。

## 第 1 輪，2026-11-05

執行方式：在隔離的空資料夾中由 subagent 載入 skill 執行 prompt，無人回答問題。
沒有跑 baseline（無 skill）對照，因為第一輪的目的是確認 skill 本身行為正確。

| 案例 | 通過 / 總數 | 產出行數 | 耗時 | token |
|---|---|---|---|---|
| `empty-folder-nextjs-saas` | 5 / 5 | 86 | 84 秒 | 68k |
| `python-cli-with-existing-git` | 5 / 5 | 76 | 85 秒 | 68k |
| `undecided-stack` | 4 / 4 | 87 | 108 秒 | 69k |
| `asks-before-writing-when-vague` | 3 / 3 | 未寫檔 | 38 秒 | 60k |

### 觀察

- 四個案例都先跑了 `detect.sh`，而且都依 SKILL.md 的順序讀 interview、stack、anatomy、template，沒有漏讀也沒有多讀。
- 需要完整產出的三個案例，產出都在 76 到 87 行之間，遠低於 150 行上限。八個區塊順序正確，沒有佔位文字。
- `python-cli-with-existing-git` 正確辨識 git 已初始化，沒有重跑 `git init`，也沒有動 `.gitignore`。
- `undecided-stack` 選了 Python，理由引用任務性質與 detect 找到的 uv，並在待決事項第一條標明未經確認。
- `asks-before-writing-when-vague` 只問了第一題，用繁體中文，沒有寫檔。
- 三個完整產出案例的最後訊息都列出假設並給三個建議步驟，沒有執行安裝或 scaffold。

### 值得留意但這輪不改

- 產出的 `測試要求` 與 `工作方式` 會帶入 stack 參考檔裡的慣例（例如「不要用 `any`」、「超過 300 行先拆」），
  這些不是使用者說的。目前都正確標記為假設，但如果使用者反映太多，可考慮在 SKILL.md 要求這兩節更精簡。
- 每次執行約 60k 到 69k token，主要花在讀四份參考檔。若要降成本，可把 anatomy 的範例縮短。
- 本輪 prompt 都寫得很完整。還沒測過「資訊給一半」的情境，例如只講了技術棧沒講禁區，
  預期行為是只追問缺的那題。下一輪可加一個這樣的案例。

### 修改

無。第一版 SKILL.md 四案例全過，不做改動。
