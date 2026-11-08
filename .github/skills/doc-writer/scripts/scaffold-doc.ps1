<#
.SYNOPSIS
    Scan project directory and scaffold a technical documentation file using standard templates.

.DESCRIPTION
    Scans the target directory files, identifies the project type, and produces a structured
    Markdown draft containing:
    1. Usage Guide (使用方法)
    2. Installation & Local Packaging (安裝方法與本地打包)
    3. Technical Details (技術細節)
    4. System Architecture (系統架構)
    5. Code Mapping & Deep-Dive (代碼對應解釋)

.PARAMETER TargetPath
    Target directory to scan. Defaults to '.'.

.PARAMETER OutputFile
    Target markdown output file. Defaults to 'docs/TECHNICAL_DOCS.md'.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetPath = ".",

    [Parameter(Position = 1)]
    [string]$OutputFile = "docs\TECHNICAL_DOCS.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$fullTargetPath = [System.IO.Path]::GetFullPath($TargetPath)
if (-not (Test-Path -LiteralPath $fullTargetPath)) {
    Write-Error "Target path not found: $fullTargetPath"
    return
}

$projectName = Split-Path -Leaf $fullTargetPath
if ([string]::IsNullOrWhiteSpace($projectName) -or $projectName -eq ".") {
    $projectName = "Project"
}

Write-Host "[*] Scanning project directory: $fullTargetPath ..." -ForegroundColor Cyan

# Locate template file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$templatePath = Join-Path $scriptDir "..\templates\TECHNICAL_DOCUMENTATION_TEMPLATE.md"
if (-not (Test-Path -LiteralPath $templatePath)) {
    $templatePath = Join-Path $scriptDir "..\..\..\.github\skills\doc-writer\templates\TECHNICAL_DOCUMENTATION_TEMPLATE.md"
}

if (-not (Test-Path -LiteralPath $templatePath)) {
    Write-Error "Template file not found at: $templatePath"
    return
}

$allFiles = @(Get-ChildItem -LiteralPath $fullTargetPath -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    $_.FullName -notmatch '\\node_modules\\' -and
    $_.FullName -notmatch '\\dist\\' -and
    $_.FullName -notmatch '\\bin\\' -and
    $_.FullName -notmatch '\\obj\\'
})

$projectTypes = @()
if (Test-Path (Join-Path $fullTargetPath "package.json")) {
    $projectTypes += "Node.js (npm/pnpm/yarn)"
}
if (@(Get-ChildItem -LiteralPath $fullTargetPath -Filter "*.csproj").Count -gt 0) {
    $projectTypes += ".NET (C#)"
}
if ((Test-Path (Join-Path $fullTargetPath "pyproject.toml")) -or (Test-Path (Join-Path $fullTargetPath "requirements.txt"))) {
    $projectTypes += "Python"
}
if (Test-Path (Join-Path $fullTargetPath "Cargo.toml")) {
    $projectTypes += "Rust (Cargo)"
}
if (Test-Path (Join-Path $fullTargetPath "go.mod")) {
    $projectTypes += "Go"
}
if (@(Get-ChildItem -LiteralPath $fullTargetPath -Filter "*.psd1").Count -gt 0 -or (Test-Path (Join-Path $fullTargetPath ".github\skills"))) {
    $projectTypes += "PowerShell / Copilot Skill"
}

$detectedType = if ($projectTypes.Count -gt 0) { $projectTypes -join ", " } else { "General Software Project" }

$treeList = @()
$relFiles = @($allFiles | ForEach-Object {
    $_.FullName.Substring($fullTargetPath.Length).TrimStart('\', '/')
} | Sort-Object)

$sample = $relFiles | Select-Object -First 30
foreach ($f in $sample) {
    $treeList += "- $f"
}
if ($relFiles.Count -gt 30) {
    $treeList += "- ... ($($relFiles.Count) files in total)"
}
$treeText = $treeList -join "`n"

# Read template in UTF-8
$templateRaw = [System.IO.File]::ReadAllText((Resolve-Path $templatePath).Path, [System.Text.Encoding]::UTF8)

# Replace placeholders
$docContent = $templateRaw.Replace("{{PROJECT_NAME}}", $projectName)
$docContent = $docContent.Replace("{{SKILL_NAME}}", $projectName)

# Output directory preparation
$outFullPath = [System.IO.Path]::GetFullPath($OutputFile)
$outParent = Split-Path -Parent $outFullPath
if (-not (Test-Path -LiteralPath $outParent)) {
    New-Item -ItemType Directory -Force -Path $outParent | Out-Null
}

[System.IO.File]::WriteAllText($outFullPath, $docContent, [System.Text.Encoding]::UTF8)
Write-Host "[v] Technical doc scaffold generated successfully: $outFullPath" -ForegroundColor Green
