# 使用指南

## 開始使用

在 VS Code 開啟一個 Git repo，打開 Copilot Chat，建議使用 Agent 模式。可在聊天輸入技能名稱呼叫 skill，或直接用自然語言描述任務。

---

## 1. Git 工作流 (/git-workflow)

用於盤點工作區、檢查變更、準備提交與分支同步：

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

---

## 2. 單一 Commit Code Diet (/commit-code-diet)

在 Copilot Chat 指定一筆 commit，讓 skill 只檢查該提交相對於 parent 的變更：

```text
/commit-code-diet 3a1b2c7 檢查冗餘條件、dead code、unused 和 unreachable；先只報告，不修改。
```

```text
/commit-code-diet HEAD 做 Code Diet；只移除能證明不改變行為的重複判斷或不可達分支，完成後跑相關測試，不要 amend commit。
```

它會追查前面的 guard、狀態是否可能改變、控制流程和 symbol 引用。回報會區分已證實問題、可安全精簡候選與待確認項目；「搜尋不到引用」或「測試沒跑到」本身不作為刪除依據。預設只審查；只有明確要求套用精簡時才修改工作樹，不會自行 stage、commit 或改寫歷史。

---

## 3. 技術文件生成 (/doc-writer)

自動掃描與深入分析專案程式碼，產出包含五大必備核心章節的工業級技術文件：

```text
/doc-writer 為目前專案撰寫完整的技術文件，儲存至 docs/TECHNICAL_DOCS.md，需完整包含使用方法、安裝方法(含本地打包)、技術細節、架構與代碼對應解釋。
```

```text
/doc-writer 分析專案架構並產出 Mermaid 模組分層圖、流程循序圖與核心函式對照表。
```

也可以直接利用隨附之盤點腳本自動產生初稿架構：

```powershell
# 自動掃描當前專案並產出五大章節技術文件雛型
.\.github\skills\doc-writer\scripts\scaffold-doc.ps1 -TargetPath "." -OutputFile "docs\TECHNICAL_DOCS.md"
```

### 產出必備章節涵蓋範圍：
1. **使用方法 (Usage Guide)**：快速入門指南、CLI/API 參數規格表、典型使用場景與預期輸出。
2. **安裝方法與本地打包 (Installation & Local Packaging)**：環境需求、離線本地打包完整流程（含打包指令、產物目錄結構與 SHA-256 驗證）、本地安裝方式。
3. **技術細節 (Technical Details)**：設定參數與環境變數、核心演算法與資料結構、狀態轉換、安全防護與錯誤處理機制。
4. **系統架構 (System Architecture)**：Mermaid 模組分層圖、核心流程時序圖（Sequence Diagram）、模組責任矩陣。
5. **代碼對應解釋 (Code Map & Component Deep-Dive)**：目錄結構映射、關鍵函式/類別走讀對照表、核心代碼段落逐行拆解與業務邏輯對應。

---

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
