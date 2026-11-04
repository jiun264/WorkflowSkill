---
name: registry-logon-audit
description: "Inspect Windows Registry logon autoruns for suspicious persistence. Use for registry Run/RunOnce or Winlogon audits, suspicious login entries, and defensive triage of Windows startup persistence."
argument-hint: "[optional host or registry scope]"
---

# Windows Registry Logon Audit

## Purpose and safety

Perform a read-only, evidence-based review of Windows Registry values that can launch programs at logon. Use only on a device the user owns or is authorized to inspect. Do not modify or delete registry values, terminate processes, quarantine files, or attempt remediation. Ask before saving collected data to a file or sending it elsewhere.

An indicator is not proof of malware. Use **suspicious** for an entry with unexplained risk signals, and reserve **unsafe/confirmed malicious** for evidence that directly demonstrates unauthorized or harmful behavior (for example, verified malicious payload or confirmed unauthorized persistence). Report the exact key, value name, command, indicator(s), and confidence; distinguish observed facts from hypotheses. Do not call an entry safe merely because no heuristic matched.

## Scope

Run [the read-only scanner](./scripts/scan-registry-logon.ps1) in PowerShell on the Windows host. It checks:

- `HKCU` and `HKLM` `Software\Microsoft\Windows\CurrentVersion\Run` and `RunOnce`
- `HKLM` `Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run` and `RunOnce`
- `HKCU` and `HKLM` `Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run`
- `HKLM` `Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run`
- `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon` values `Shell` and `Userinit`

The scanner reads the 64-bit registry view. Missing autorun keys are normal. Access and read errors must be reported; do not describe an incomplete scan as clean. This scope is not a complete audit of every Windows persistence mechanism.

## Suspicion criteria

Use the scanner's indicators as triage signals, not as a malware verdict:

| Priority | Evidence to consider |
|---|---|
| High | Unexpected `Winlogon\Shell` or `Userinit` command; PowerShell encoded command; script or executable launched from a remote URL; download/execute behavior; or multiple independent indicators such as hidden execution plus a user-writable payload path. |
| Medium | Entry launches from a user-writable location (`Temp`, `Downloads`, `Public`, or user profile), invokes a script host or proxy executable (`wscript`, `cscript`, `mshta`, `rundll32`, `regsvr32`), or uses hidden/non-interactive options. Treat any one of these alone as weak evidence. |
| Informational | No listed indicator matched. This means only that this heuristic scan did not identify a signal; it is not a clean bill of health. |

Increase confidence only when independent evidence corroborates the entry, for example a verified malicious hash or behavior, an unexpected signer or unsigned binary combined with other evidence, a file with a misleading name or location, a suspicious parent/child process, or a match to trusted threat intelligence. Verify publisher, full expanded path, file hash, file metadata, and whether the software is expected in this environment. A valid signature or common vendor name is useful context, not proof of safety.

Do not treat these as suspicious by themselves: an unfamiliar value name, a value under `AppData`, an unsigned file, an obfuscated-looking name, or a recent timestamp. Registry key last-write time applies to the key, not an individual value; do not claim it dates a specific entry.

Use **low confidence** for one weak heuristic, **medium** for multiple distinct signals or a validated but unexplained executable, and **high** only when direct verification or independent evidence strongly supports unauthorized behavior. Priority measures urgency to investigate; confidence measures how strongly the evidence supports the assessment.

## Procedure

1. Confirm the host is Windows and the user is authorized to inspect it. Do not elevate privileges unless the user specifically authorizes it and access is necessary.
2. Run the scanner without changing its read-only behavior:

   ```powershell
   .\scripts\scan-registry-logon.ps1
   ```

3. If the script reports an access/read error, include it and identify which locations were not assessed. Do not silently skip inaccessible keys.
4. For each non-informational result, assess whether the command is expected for the host, expand environment variables for analysis without changing the registry, and corroborate the executable through approved local tools. Never execute a discovered command or payload.
5. Present a concise report with scan scope, completion/errors, key and value, exact command, priority, matched indicators, confidence, benign explanations to verify, and safe next investigative steps. Separate observed facts from inference.
6. Do not make changes. Offer remediation only as a separate user-approved task, after identifying the exact value and preserving evidence.

## Interpreting results

The script assigns a review priority from simple string heuristics. It does not validate signatures, determine whether files are malicious, or establish that a startup entry is unauthorized. Use the criteria above to refine priority and confidence; explain any adjustment.
