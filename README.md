# Workflow Skills Suite

供 VS Code Copilot Chat 使用的工程效能與自動化 Skills 套件，適用於多個本機 repo。協助盤點工作區、檢查變更、準備提交、審查單一 commit 冗餘代碼、自動撰寫符合工業級規範的五大章節技術文件，並提供本地離線打包機制。

## Skills 清單

- **文件撰寫 Skill**：[doc-writer](.github/skills/doc-writer/SKILL.md)  
  自動分析專案架構並產出具備**使用方法**、**安裝方法（本地打包）**、**技術細節**、**系統架構圖**與**代碼對應解釋**的標準化技術文檔。
- **Git 操作 Skill**：[git-workflow](.github/skills/git-workflow/SKILL.md)  
  加速 Git 日常工作：盤點工作區、差異審查、提交訊息建議、分支同步與衝突協助。
- **單一 Commit Code Diet Skill**：[commit-code-diet](.github/skills/commit-code-diet/SKILL.md)  
  針對指定 commit 審查冗餘條件、重複判斷、dead code 與 unused symbols。
- **登錄檔稽核 Skill**：[registry-logon-audit](.github/skills/registry-logon-audit/SKILL.md)  
  Windows 開機啟動項唯讀安全審查。

## 快速開始

- 閱讀 [使用指南](docs/USAGE.md) 了解可用指令、提問方式與文件生成指引。
- 閱讀 [導入指南](docs/INSTALLATION.md) 安裝到個人環境、導入特定 repo 或使用本地打包工具。
- 查閱 [技術設計文件範本](docs/TECHNICAL_DOCS.md) 瀏覽標準五大章節之完整實作範例。

## 本地打包快速指令

本專案內建本地打包工具，可完全離線產出包含校驗碼與 Manifest 的 ZIP 套件：

```powershell
# 本地打包所有 Skills 至 dist/
powershell -ExecutionPolicy Bypass -File .\scripts\package-skills.ps1 -SkillName "all"

# 單獨打包 doc-writer
powershell -ExecutionPolicy Bypass -File .\scripts\package-skills.ps1 -SkillName "doc-writer"
```

## 設計原則

- 先確認環境、repo、分支與工作區狀態，再採取下一步。
- 預設只檢查與報告；不自行 stage、commit、push、merge 或改寫歷史。
- 技術文件嚴格落實「使用方法、安裝/本地打包、技術細節、架構、代碼對應解釋」五大維度。
- 所有路徑與外部呼叫落實防禦性安全邊界，留意 Windows PowerShell 路徑空白字元與字元編碼。
