# 導入指南

可以安裝成個人 skill（所有 workspace 可用），或只加入特定 repo。以下命令使用 Windows PowerShell 和 Git for Windows。

## 個人安裝（建議）

在 PowerShell 切換到本專案根目錄後執行：

```powershell
$source = (Resolve-Path ".github\skills\git-workflow").Path
$destination = Join-Path $HOME ".copilot\skills\git-workflow"
New-Item -ItemType Directory -Force $destination | Out-Null
Get-ChildItem -LiteralPath $source -Force | Copy-Item -Destination $destination -Recurse -Force
```

個人安裝位置為 `$HOME\.copilot\skills\git-workflow\SKILL.md`，可在不同 repo 使用。更新 skill 時重新執行上述複製命令。

## 導入單一 repo

在目標 repo 根目錄執行。將 `$source` 改成這個專案中 skill 資料夾的完整路徑：

```powershell
$source = "C:\path\to\GitWorkflowSkill\.github\skills\git-workflow"
$destination = ".github\skills\git-workflow"
New-Item -ItemType Directory -Force $destination | Out-Null
Get-ChildItem -LiteralPath $source -Force | Copy-Item -Destination $destination -Recurse -Force
```

此方式會把 skill 放在目標 repo 的 `.github/skills/git-workflow/`，適合團隊共享並隨 repo 版本控制。更新來源後重新執行複製命令，會覆寫同名檔案，但不會刪除目的地的其他檔案。

## 確認安裝

1. 確認安裝位置存在 `SKILL.md`。
2. 在 VS Code 開啟已安裝的 workspace，打開 Copilot Chat。
3. 輸入 `/git-workflow`；若命令未出現，重新開啟 Copilot Chat，或執行 `Developer: Reload Window` 後再試。
4. 用「檢查目前 repo 狀態，先不要修改」測試它是否先盤點再回報。

個人安裝只影響目前 Windows 使用者；repo 安裝則隨 repo 分享。兩種方式都不會自動執行 Git 操作，仍依 skill 中的授權規則行事。
