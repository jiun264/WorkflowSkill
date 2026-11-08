# 導入指南

可以安裝成個人 skill（所有 workspace 可用），或只加入特定 repo。此外，本專案提供完全離線的**本地打包**工具，方便團隊進行封裝散布與完整性校驗。以下命令使用 Windows PowerShell 和 Git for Windows。

---

## 1. 本地打包方法 (Local Packaging)

本專案支援將 Skills 本機封裝為標準 zip 套件，並自動產出 `manifest.json` 與 SHA-256 校驗碼。

### 打包所有 Skills
在專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package-skills.ps1 -SkillName "all" -OutputDir "dist"
```

### 打包單一 Skill (例如 doc-writer)
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package-skills.ps1 -SkillName "doc-writer" -OutputDir "dist"
```

### 打包產物結構
打包完成後於 `dist/` 資料夾下會產生：
```text
dist/
├── doc-writer-v1.0.0.zip
├── doc-writer-manifest.json
├── doc-writer.sha256
├── git-workflow-v1.0.0.zip
...
```

### 驗證打包產物完整性
部署前可比對 SHA-256 雜湊值：
```powershell
Get-FileHash -Path ".\dist\doc-writer-v1.0.0.zip" -Algorithm SHA256
```

---

## 2. 個人安裝（建議）

將所有 skills 安裝至個人設定檔目錄 `$HOME\.copilot\skills\`，可在所有 workspace 使用。

### 方式 A：從原始碼直接安裝
在專案根目錄執行：

```powershell
$sourceRoot = (Resolve-Path ".github\skills").Path
$destinationRoot = Join-Path $HOME ".copilot\skills"
Get-ChildItem -LiteralPath $sourceRoot -Directory | ForEach-Object {
	$destination = Join-Path $destinationRoot $_.Name
	New-Item -ItemType Directory -Force $destination | Out-Null
	Get-ChildItem -LiteralPath $_.FullName -Force | Copy-Item -Destination $destination -Recurse -Force
}
```

### 方式 B：從本地打包套件安裝
解壓生成的 zip 套件至個人目錄：

```powershell
$distDir = Resolve-Path "dist"
Get-ChildItem -Path $distDir -Filter "*.zip" | ForEach-Object {
    $skillName = $_.BaseName -replace "-v[\d\.]+$", ""
    $dest = Join-Path $HOME ".copilot\skills\$skillName"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Expand-Archive -LiteralPath $_.FullName -DestinationPath $dest -Force
}
```

---

## 3. 導入單一 repo

在目標 repo 根目錄執行。將 `$sourceRoot` 改成本專案中 skill 資料夾的完整路徑：

```powershell
$sourceRoot = "C:\path\to\GitWorkflowSkill\.github\skills"
$destinationRoot = ".github\skills"
Get-ChildItem -LiteralPath $sourceRoot -Directory | ForEach-Object {
	$destination = Join-Path $destinationRoot $_.Name
	New-Item -ItemType Directory -Force $destination | Out-Null
	Get-ChildItem -LiteralPath $_.FullName -Force | Copy-Item -Destination $destination -Recurse -Force
}
```

此方式會把專案內所有 skills 放在目標 repo 的 `.github/skills/`，適合團隊共享並隨 repo 版本控制。

---

## 4. 確認安裝

1. 確認安裝位置存在 `SKILL.md`。目前包含：
   - `git-workflow`：Git 日常工作流與分支管理。
   - `commit-code-diet`：單一 commit 程式碼精簡與冗餘審查。
   - `doc-writer`：自動分析專案並產出五大章節技術文件。
   - `registry-logon-audit`：Windows 登錄檔啟動項目安全審查。
2. 在 VS Code 開啟已安裝的 workspace，打開 Copilot Chat。
3. 輸入 `/git-workflow`、`/commit-code-diet` 或 `/doc-writer`；若命令未出現，重新開啟 Copilot Chat，或執行 `Developer: Reload Window` 後再試。
4. 輸入「`/doc-writer` 產出本專案技術文件」確認 skill 正常運作。

個人安裝只影響目前 Windows 使用者；repo 安裝則隨 repo 分享。所有方式皆遵循唯讀審查與確認後執行的安全原則。
