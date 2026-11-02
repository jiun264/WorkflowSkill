# 導入指南

可以安裝成個人 skill（所有 workspace 可用），或只加入特定 repo。以下命令使用 Windows PowerShell 和 Git for Windows。

## 個人安裝（建議）

在 PowerShell 切換到本專案根目錄後執行：

```powershell
$sourceRoot = (Resolve-Path ".github\skills").Path
$destinationRoot = Join-Path $HOME ".copilot\skills"
Get-ChildItem -LiteralPath $sourceRoot -Directory | ForEach-Object {
	$destination = Join-Path $destinationRoot $_.Name
	New-Item -ItemType Directory -Force $destination | Out-Null
	Get-ChildItem -LiteralPath $_.FullName -Force | Copy-Item -Destination $destination -Recurse -Force
}
```

個人安裝會將專案內所有 skills 複製到 `$HOME\.copilot\skills\`，目前包括 `git-workflow` 和 `commit-code-diet`，可在不同 repo 使用。更新 skill 時重新執行上述命令；它會覆寫同名檔案，但不會刪除目的地的其他檔案。

## 導入單一 repo

在目標 repo 根目錄執行。將 `$source` 改成這個專案中 skill 資料夾的完整路徑：

```powershell
$sourceRoot = "C:\path\to\GitWorkflowSkill\.github\skills"
$destinationRoot = ".github\skills"
Get-ChildItem -LiteralPath $sourceRoot -Directory | ForEach-Object {
	$destination = Join-Path $destinationRoot $_.Name
	New-Item -ItemType Directory -Force $destination | Out-Null
	Get-ChildItem -LiteralPath $_.FullName -Force | Copy-Item -Destination $destination -Recurse -Force
}
```

此方式會把專案內所有 skills 放在目標 repo 的 `.github/skills/`，適合團隊共享並隨 repo 版本控制。更新來源後重新執行複製命令，會覆寫同名檔案，但不會刪除目的地的其他檔案。

## 確認安裝

1. 確認安裝位置存在 `SKILL.md`。
2. 在 VS Code 開啟已安裝的 workspace，打開 Copilot Chat。
3. 輸入 `/git-workflow` 或 `/commit-code-diet`；若命令未出現，重新開啟 Copilot Chat，或執行 `Developer: Reload Window` 後再試。
4. 分別用「檢查目前 repo 狀態，先不要修改」和「`/commit-code-diet HEAD` 先只審查，不要修改」確認 skills 可用。

個人安裝只影響目前 Windows 使用者；repo 安裝則隨 repo 分享。兩種方式都不會自動執行 Git 操作，仍依 skill 中的授權規則行事。
