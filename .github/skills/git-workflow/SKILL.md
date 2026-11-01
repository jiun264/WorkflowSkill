---
name: git-workflow
description: '加速 Git 日常工作：檢查工作區與 diff、準備 commit、檢視分支、同步分支、處理衝突或查詢提交歷史。當使用者提到 Git、status、commit、branch、merge、rebase、push、衝突或工作區狀態時使用。'
user-invocable: true
---

# Git Workflow

協助使用者快速理解 Git repo 的狀態並完成明確要求的操作。優先用短摘要和可執行的下一步，不要 dump 大段 diff 或 log。

## 共通流程

1. 從目前工作目錄確認 repo：`git rev-parse --show-toplevel`。若不在 repo，說明結果並停止 Git 操作。
2. 先執行 `git status --short --branch`，辨識目前分支、upstream（若有）、staged、unstaged、untracked 和衝突檔案。
3. 只讀取完成使用者要求所需的 diff 或歷史；不要掃描無關目錄。
4. 先用一句話說明將檢查或執行什麼。執行結果需指出受影響檔案、操作結果和剩餘風險。
5. 路徑可能含空白時加引號。若發現疑似憑證、私鑰或個人資料，不要在回覆中重複其內容，也不要建議提交。

## 工作流程

### 檢查工作區

- 使用 `git status --short --branch`、`git diff --stat`、`git diff --cached --stat` 和 `git diff --check`。
- 摘要 staged、unstaged、untracked、分支及 upstream 狀態；`git diff --check` 有問題時指出檔案與行號。
- 除非使用者要求檢視內容，否則不要輸出完整 diff。

### 準備提交

- 檢查 staged 和相關 unstaged diff，指出變更目的、可能遺漏及建議測試；依 repo 文件選擇適當測試，不要猜測不存在的命令。
- 提供一個精簡 commit message；若 repo 有既定格式，遵循該格式。
- 不自行 stage 檔案。先列出建議納入的檔案，僅在使用者明確同意範圍或指定檔案後執行 `git add`。
- 僅在使用者明確要求 commit 時建立提交；提交前再次確認 staged diff 符合指定範圍。

### 檢視分支或同步

- 先檢查目前分支、upstream、工作區是否乾淨，以及本地與遠端的差異。若需要遠端資訊，且使用者要求同步或查遠端，才執行 `git fetch`。
- 檢視變更時以使用者指定的 base 為準；未指定且無法可靠判定時，先詢問，不要猜測。
- 回報 ahead/behind 和可能的衝突，提出 merge 或 rebase 建議；不要自行 pull、merge、rebase 或 push。
- 使用者明確要求某項一般操作時可執行該操作；force push 或改寫已分享歷史前，必須先列出影響並取得明確確認。

### 處理衝突或查歷史

- 衝突時先列出衝突檔案及 Git 操作狀態，再逐一檢視必要上下文。不要以其中一側內容直接覆蓋另一側。
- 完成使用者要求的衝突處理後，檢查 `git diff --check` 和相關測試；不要自行完成 merge/rebase，除非使用者明確要求。
- 查歷史時優先用精簡 `git log --oneline`；需要追溯單一檔案或行為時再用 `git show` 或 `git blame`。

## 安全界線

- 不推測使用者想丟棄哪些變更；任何操作都保留未提交工作。
- `reset --hard`、`clean`、`restore`、`checkout` 覆蓋檔案、`stash pop`、force push 和改寫共享歷史都可能造成資料遺失。執行前說明具體影響、對象與替代方案，並取得明確確認。
- 不因「整理一下」「同步一下」等含糊要求就自行 stage、commit、push、合併或重設分支；先盤點並釐清必要範圍。
