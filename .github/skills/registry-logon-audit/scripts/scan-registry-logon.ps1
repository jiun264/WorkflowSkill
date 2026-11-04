$ErrorActionPreference = 'Stop'

if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'This scanner requires 64-bit Windows.'
}

$locations = @(
    @{ Hive = 'CurrentUser'; SubKey = 'Software\Microsoft\Windows\CurrentVersion\Run'; Display = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run' }
    @{ Hive = 'CurrentUser'; SubKey = 'Software\Microsoft\Windows\CurrentVersion\RunOnce'; Display = 'HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce' }
    @{ Hive = 'LocalMachine'; SubKey = 'Software\Microsoft\Windows\CurrentVersion\Run'; Display = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Run' }
    @{ Hive = 'LocalMachine'; SubKey = 'Software\Microsoft\Windows\CurrentVersion\RunOnce'; Display = 'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce' }
    @{ Hive = 'LocalMachine'; SubKey = 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; Display = 'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' }
    @{ Hive = 'LocalMachine'; SubKey = 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce'; Display = 'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce' }
    @{ Hive = 'CurrentUser'; SubKey = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run'; Display = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' }
    @{ Hive = 'LocalMachine'; SubKey = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run'; Display = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' }
    @{ Hive = 'LocalMachine'; SubKey = 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run'; Display = 'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' }
)

$results = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[string]]::new()
$registryView = [Microsoft.Win32.RegistryView]::Registry64

foreach ($location in $locations) {
    $baseKey = $null
    $key = $null
    try {
        $hive = [Enum]::Parse([Microsoft.Win32.RegistryHive], $location.Hive)
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, $registryView)
        $key = $baseKey.OpenSubKey($location.SubKey, $false)
        if ($null -eq $key) {
            continue
        }

        foreach ($valueName in $key.GetValueNames()) {
            $value = [string]$key.GetValue(
                $valueName,
                $null,
                [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
            )
            $signals = [System.Collections.Generic.List[string]]::new()

            if ($value -match '(?i)\b-(?:encodedcommand|enc)\b') {
                $signals.Add('PowerShell encoded-command option')
            }
            if ($value -match '(?i)\b(?:powershell|pwsh)\b.*(?:-windowstyle\s+hidden|-w\s+hidden|-noni\b|-nop\b)') {
                $signals.Add('PowerShell hidden or non-interactive option')
            }
            if ($value -match '(?i)\b(?:downloadstring|downloadfile|invoke-webrequest|start-bitstransfer)\b|https?://') {
                $signals.Add('URL or download-related command text')
            }
            if ($value -match '(?i)(\\temp\\|\\downloads\\|\\public\\|\\appdata\\|%temp%|%appdata%)') {
                $signals.Add('Command references a commonly user-writable location')
            }
            if ($value -match '(?i)\b(?:wscript|cscript|mshta|rundll32|regsvr32)\b') {
                $signals.Add('Command uses a script host or proxy executable')
            }

            $priority = 'Informational'
            if ($signals.Count -gt 0) {
                $priority = 'Medium'
            }
            $remoteExecution = (
                $value -match '(?i)\b(?:mshta|rundll32|regsvr32|wscript|cscript)\b.*https?://' -or
                (
                    $value -match '(?i)\bdownloadstring\b' -and
                    $value -match '(?i)\b(?:iex|invoke-expression)\b'
                )
            )
            if (($signals -match 'encoded-command').Count -gt 0 -or $remoteExecution) {
                $priority = 'High'
            } elseif (
                $signals.Count -ge 2 -and
                ($signals -match 'user-writable location').Count -gt 0 -and
                ($signals -match 'hidden or non-interactive|script host or proxy').Count -gt 0
            ) {
                $priority = 'High'
            }

            $results.Add([pscustomobject]@{
                Priority = $priority
                Key = $location.Display
                ValueName = $valueName
                Command = $value
                Indicators = ($signals -join '; ')
            })
        }
    } catch {
        $message = "Could not read $($location.Display): $($_.Exception.Message)"
        $errors.Add($message)
        Write-Error $message -ErrorAction Continue
    } finally {
        if ($null -ne $key) { $key.Dispose() }
        if ($null -ne $baseKey) { $baseKey.Dispose() }
    }
}

$winlogonBase = $null
$winlogonKey = $null
try {
    $winlogonBase = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::LocalMachine,
        $registryView
    )
    $winlogonKey = $winlogonBase.OpenSubKey(
        'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon',
        $false
    )
    if ($null -eq $winlogonKey) {
        $message = 'Could not read HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon: key is missing.'
        $errors.Add($message)
        Write-Error $message -ErrorAction Continue
    } else {
        foreach ($valueName in @('Shell', 'Userinit')) {
            if ($winlogonKey.GetValueNames() -contains $valueName) {
                $value = [string]$winlogonKey.GetValue(
                    $valueName,
                    $null,
                    [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
                )
                $signals = [System.Collections.Generic.List[string]]::new()
                if ($valueName -eq 'Shell' -and $value.Trim().Trim('"') -notmatch '^(?i)explorer\.exe$') {
                    $signals.Add('Winlogon Shell differs from the usual explorer.exe value')
                }
                if ($valueName -eq 'Userinit' -and $value -notmatch '^(?i)(%SystemRoot%|[A-Z]:\\Windows)\\system32\\userinit\.exe,?$') {
                    $signals.Add('Winlogon Userinit differs from the usual system userinit.exe value')
                }
                $results.Add([pscustomobject]@{
                    Priority = $(if ($signals.Count -gt 0) { 'High' } else { 'Informational' })
                    Key = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
                    ValueName = $valueName
                    Command = $value
                    Indicators = ($signals -join '; ')
                })
            }
        }
    }
} catch {
    $message = "Could not read HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon: $($_.Exception.Message)"
    $errors.Add($message)
    Write-Error $message -ErrorAction Continue
} finally {
    if ($null -ne $winlogonKey) { $winlogonKey.Dispose() }
    if ($null -ne $winlogonBase) { $winlogonBase.Dispose() }
}

if ($results.Count -eq 0) {
    Write-Output 'No values were found in the accessible locations.'
} else {
    $results | Sort-Object @{ Expression = { switch ($_.Priority) { 'High' { 0 } 'Medium' { 1 } default { 2 } } } }, Key, ValueName |
        Format-Table -Wrap -AutoSize
}

if ($errors.Count -gt 0) {
    Write-Warning "Scan incomplete: $($errors.Count) location(s) could not be assessed."
}
