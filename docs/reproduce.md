# Build and reproduce

Use an isolated Windows VM with Windows PowerShell 5.1 and Sysmon, plus a separate Splunk instance. Keep the HTTP service inside the lab.

## Telemetry

Apply [sysmon-projects.xml](../lab/sysmon-projects.xml) to the installed Sysmon service:

```powershell
C:\Lab\Sysmon64.exe -c .\lab\sysmon-projects.xml
auditpol /set /subcategory:"Process Creation" /success:enable
New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging EnableScriptBlockLogging 1
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit ProcessCreationIncludeCmdLine_Enabled 1
```

`-c` updates an installed Sysmon instance. On a new endpoint, install Sysmon first using its `-i` configuration option. Enable auditing before opening the PowerShell processes used for the cases.

## Run the cases

Copy the inventory files to `C:\Users\Public\Documents\MohamedLab\PowerShell`. Serve `lab/check.ps1` at `/powershell/check.ps1` from an internal HTTP server. For QEMU user networking the host service is `10.0.2.2`; use your own internal address if the topology differs.

```powershell
$root='C:\Users\Public\Documents\MohamedLab\PowerShell'
powershell.exe -NoProfile -File "$root\inventory.ps1"
$text=[IO.File]::ReadAllText("$root\encoded-inventory.ps1")
$encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($text))
powershell.exe -NoProfile -EncodedCommand $encoded
```

The download launch command and both decoded values are retained exactly in [run.json](../evidence/run.json). The download case caches `check.ps1` and starts it in a child PowerShell process. Keep the source text available for inspection before execution.

To inspect an encoded value without executing it:

```powershell
[Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encoded))
```

## Splunk

Install the contents of `splunk/app` as a local Splunk app. The configuration defines index `lab_powershell` and JSON sourcetype `soc:windows:event`. Import [events.jsonl](../evidence/events.jsonl) with that index and sourcetype after configuration is loaded. Open the included Splunk dashboards and run the saved SPL searches.

Compare indexed count with [selection.json](../evidence/selection.json), and verify `_time` against source `utc`. The included CSVs are exports from the recorded run. Repeating the cases produces new timestamps, record IDs, PIDs and ProcessGuids.

## Cleanup

Remove the case files under `C:\Users\Public\Documents\MohamedLab\PowerShell` and outputs under `C:\ProgramData\MohamedLab\PowerShell` when finished. Stop the internal HTTP server. These cases do not install persistence.

## Capture helper

`lab/export-events.ps1` exports original event XML and matching normalized JSONL for a UTC window. For example: `./lab/export-events.ps1 -StartUtc $start -EndUtc $end -Output C:\MohamedLab\Evidence`. Record the UTC boundaries around your cases, then scope the capture to their PIDs, descendants and source record IDs before importing. The published selection is documented in `evidence/selection.json`; a full rerun capture may include additional background records.
