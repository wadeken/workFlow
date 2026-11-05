# workFlow

一個 Claude Code plugin。核心是 `bootstrap-claude-md` skill：開新專案時，先偵測資料夾狀態、再訪談釐清需求，
最後產出一份針對該專案量身訂做的 CLAUDE.md，並建議第一步該做什麼。

它不產生應用程式碼，也不替你選好所有東西。它負責的是「第一份 CLAUDE.md 該長什麼樣」這件事，
讓之後的 Pocock、Osmani 等工程流程 skill 有一個正確的起點。

## 安裝

在 Claude Code 裡執行：

```
/plugin marketplace add wadeken/workFlow
/plugin install workflow@wadeken-workflow
```

更新：

```
claude plugin update workflow@wadeken-workflow
```

## 使用

進到新專案的資料夾（可以是空的），啟動 Claude Code，然後說：

- 「幫我開一個新專案，做 X」
- 「幫我寫這個專案的 CLAUDE.md」
- 或直接呼叫 `/workflow:bootstrap-claude-md`

Claude 會先看資料夾裡有什麼，再一題一題問你專案的目標、技術棧、執行形式、測試指令、禁區，
以及 CLAUDE.md 要用什麼語言寫。問完就寫出 `./CLAUDE.md`，並列出建議的第一步。
資料夾裡已經有 CLAUDE.md 的話，會先備份成 `CLAUDE.md.bak` 再問你要不要覆蓋。

如果你不想被問，直接在第一句話把資訊講完，或說「不用問我，照你建議」。
沒講到的部分會被列在 CLAUDE.md 的「待決事項」裡，不會被偷偷猜掉。

## 本機開發與測試

```
git clone https://github.com/wadeken/workFlow
mkdir /tmp/try && cd /tmp/try
claude --plugin-dir /path/to/workFlow
```

eval 案例在 `skills/bootstrap-claude-md/evals/`。有 Claude Code v2.1.269 以上可以直接跑：

```
cd skills/bootstrap-claude-md
claude plugin eval . --allow-tools Write,Edit,Bash --scaffold
```

規格在 `docs/spec.md`，在這個 repo 工作的規則在 `CLAUDE.md`。
