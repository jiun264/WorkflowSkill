<#
.SYNOPSIS
    將專案內的所有或指定 Skills 進行本地打包 (封裝為 zip、計算 SHA256 與 Manifest)。

.DESCRIPTION
    此腳本為本地打包與離線發行工具。可將 .github/skills 下的各個 skill 模組
    打包成可離線散布的 zip 封裝檔，並自動計算 SHA-256 雜湊與產生 manifest.json。

.PARAMETER SkillName
    指定要打包的 skill 名稱（例如 "doc-writer"、"git-workflow"、"commit-code-diet"、"registry-logon-audit"），
    若填入 "all"（預設），則一次打包全部 skills。

.PARAMETER OutputDir
    打包產物輸出資料夾，預設為 "dist"。

.PARAMETER Version
    套件版本編號，預設為 "1.0.0"。

.EXAMPLE
    .\scripts\package-skills.ps1
    .\scripts\package-skills.ps1 -SkillName "doc-writer"
    .\scripts\package-skills.ps1 -SkillName "all" -OutputDir ".\release" -Version "1.2.0"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$SkillName = "all",

    [Parameter(Position = 1)]
    [string]$OutputDir = "dist",

    [Parameter(Position = 2)]
    [string]$Version = "1.0.0"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$workerScript = Join-Path $projectRoot ".github\skills\doc-writer\scripts\package-skill.ps1"

if (-not (Test-Path -LiteralPath $workerScript)) {
    Write-Error "找不到打包核心腳本: $workerScript"
    return
}

& $workerScript -SkillName $SkillName -OutputDir $OutputDir -Version $Version
