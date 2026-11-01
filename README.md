# Git Workflow Skill

一個供 VS Code Copilot Chat 使用的 Git 工作流 skill，適用於多個本機 repo。它協助盤點工作區、檢查變更、準備提交、檢視分支差異、同步分支，以及整理衝突與提交歷史。

## 快速開始

- 閱讀 [使用指南](docs/USAGE.md) 了解可用流程與提問方式。
- 閱讀 [導入指南](docs/INSTALLATION.md) 安裝到個人環境，或加入特定 repo。
- Skill 原始檔位於 [.github/skills/git-workflow/SKILL.md](.github/skills/git-workflow/SKILL.md)。

## 設計原則

- 先確認 repo、分支和工作區狀態，再採取下一步。
- 預設只檢查與報告；不自行 stage、commit、push、merge 或 rebase。
- 可能丟失資料或改寫歷史的操作，先說明影響並取得明確同意。
- 使用 Git CLI，並留意 Windows PowerShell 路徑中的空白字元。
