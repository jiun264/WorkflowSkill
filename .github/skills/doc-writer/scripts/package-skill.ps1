<#
.SYNOPSIS
    Package a skill directory into a distributable zip archive with SHA256 checksum and manifest.

.DESCRIPTION
    Packages one or all skills under .github/skills into standalone zip files,
    generating a manifest.json and a sha256 checksum for local packaging and offline distribution.

.PARAMETER SkillName
    The name of the skill to package (e.g. 'doc-writer', 'git-workflow', 'commit-code-diet'), or 'all'.

.PARAMETER SourceRoot
    Root folder containing skills. Defaults to .github/skills.

.PARAMETER OutputDir
    Destination folder for packages. Defaults to 'dist'.

.PARAMETER Version
    Package version string. Defaults to '1.0.0'.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$SkillName = "doc-writer",

    [Parameter()]
    [string]$SourceRoot = "",

    [Parameter()]
    [string]$OutputDir = "dist",

    [Parameter()]
    [string]$Version = "1.0.0"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Auto-detect skills root folder
if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRootCandidate = Resolve-Path (Join-Path $scriptDir "..\..\..") -ErrorAction SilentlyContinue
    if ($repoRootCandidate -and (Test-Path (Join-Path $repoRootCandidate.Path ".github\skills"))) {
        $SourceRoot = Join-Path $repoRootCandidate.Path ".github\skills"
    } else {
        $SourceRoot = (Resolve-Path ".github\skills").Path
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    Write-Error "Skills root directory not found: $SourceRoot"
    return
}

# Ensure output directory exists
$resolvedOutputDir = [System.IO.Path]::GetFullPath($OutputDir)
if (-not (Test-Path -LiteralPath $resolvedOutputDir)) {
    New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null
}

Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue

function Package-SingleSkill {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$SkillDir,
        [Parameter(Mandatory = $true)]
        [string]$TargetDir,
        [Parameter(Mandatory = $true)]
        [string]$PkgVersion
    )

    $name = $SkillDir.Name
    $zipFileName = "$name-v$PkgVersion.zip"
    $zipFilePath = Join-Path $TargetDir $zipFileName
    $manifestPath = Join-Path $TargetDir "$name-manifest.json"
    $checksumPath = Join-Path $TargetDir "$name.sha256"

    Write-Host "[*] Packaging Skill: $name ..." -ForegroundColor Cyan

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    try {
        $destSkillDir = Join-Path $tempDir $name
        New-Item -ItemType Directory -Force -Path $destSkillDir | Out-Null

        $files = @(Get-ChildItem -LiteralPath $SkillDir.FullName -Recurse -File | Where-Object {
            $_.FullName -notmatch '\\\.git\\' -and
            $_.FullName -notmatch '\\dist\\' -and
            $_.Extension -ne '.tmp'
        })

        $fileManifest = @()
        foreach ($file in $files) {
            $relPath = $file.FullName.Substring($SkillDir.FullName.Length).TrimStart('\', '/')
            $targetFilePath = Join-Path $destSkillDir $relPath
            $targetSubDir = Split-Path -Parent $targetFilePath
            if (-not (Test-Path -LiteralPath $targetSubDir)) {
                New-Item -ItemType Directory -Force -Path $targetSubDir | Out-Null
            }
            Copy-Item -LiteralPath $file.FullName -Destination $targetFilePath -Force

            $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            $fileManifest += [PSCustomObject]@{
                Path   = $relPath -replace '\\', '/'
                Size   = $file.Length
                SHA256 = $hash
            }
        }

        # Compress to zip
        if (Test-Path -LiteralPath $zipFilePath) {
            Remove-Item -LiteralPath $zipFilePath -Force
        }
        [System.IO.Compression.ZipFile]::CreateFromDirectory($destSkillDir, $zipFilePath)

        # Compute Zip hash
        $zipHash = (Get-FileHash -LiteralPath $zipFilePath -Algorithm SHA256).Hash

        # Create Manifest
        $manifestObj = [PSCustomObject]@{
            Name        = $name
            Version     = $PkgVersion
            PackedAt    = (Get-Date).ToString("o")
            ZipFileName = $zipFileName
            ZipSHA256   = $zipHash
            TotalFiles  = $files.Count
            Files       = $fileManifest
        }
        $manifestJson = $manifestObj | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($manifestPath, $manifestJson, [System.Text.Encoding]::UTF8)

        # Write sha256 checksum file
        $checksumLine = "$zipHash  $zipFileName"
        [System.IO.File]::WriteAllText($checksumPath, $checksumLine, [System.Text.Encoding]::UTF8)

        Write-Host "    [+] Package: $zipFilePath" -ForegroundColor Green
        Write-Host "    [+] SHA256:  $zipHash" -ForegroundColor Gray
        Write-Host "    [+] Manifest: $manifestPath" -ForegroundColor Gray
    }
    finally {
        if (Test-Path -LiteralPath $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($SkillName -eq "all") {
    $skills = Get-ChildItem -LiteralPath $SourceRoot -Directory
    foreach ($sk in $skills) {
        Package-SingleSkill -SkillDir $sk -TargetDir $resolvedOutputDir -PkgVersion $Version
    }
} else {
    $targetPath = Join-Path $SourceRoot $SkillName
    if (-not (Test-Path -LiteralPath $targetPath)) {
        Write-Error "Skill directory '$SkillName' not found at: $targetPath"
        return
    }
    $skDir = Get-Item -LiteralPath $targetPath
    Package-SingleSkill -SkillDir $skDir -TargetDir $resolvedOutputDir -PkgVersion $Version
}

Write-Host "`n[v] Local packaging completed successfully! Output: $resolvedOutputDir" -ForegroundColor Green
