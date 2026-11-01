# 使用指南

## 開始使用

在 VS Code 開啟一個 Git repo，打開 Copilot Chat，建議使用 Agent 模式。可在聊天輸入 `/git-workflow` 呼叫 skill，或直接用自然語言描述 Git 任務；例如：

```text
/git-workflow 檢查目前 repo 的工作區，分開摘要 staged、unstaged 和 untracked，先不要修改。
```

```text
/git-workflow 檢查 staged diff，指出風險並建議一個 commit message，不要 stage 或 commit。
```

```text
/git-workflow 檢查目前分支和 upstream 的差異。若需要 fetch，先告訴我；不要 merge、rebase 或 push。
```

```text
/git-workflow 列出目前的衝突檔案，說明每個衝突的上下文，先不要選邊或完成 merge。
```

也可以直接描述需求，例如「看一下這個 repo 哪些變更還沒提交」或「幫我整理最近 10 個 commit」。

## 它會做什麼

- 先辨識 repo 根目錄、目前分支和工作區狀態。
- 依需求查看摘要或必要 diff，回覆建議和下一步。
- 只有在你明確授權後，才 stage、commit、fetch、merge、rebase 或 push。
- 對可能丟失資料或改寫共享歷史的命令，先列明影響並要求確認。

## 建議工作方式

1. 先叫它盤點工作區，確認 staged 與 unstaged 內容沒有混淆。
2. 準備提交時，要求它檢查 diff、建議測試與 commit message。
3. 明確指定要 stage 或 commit 的檔案和操作，再讓它執行。
4. 操作後要求它確認分支狀態與結果。

Skill 不會取代你對變更範圍的確認；尤其提交前仍應檢查 staged diff。
