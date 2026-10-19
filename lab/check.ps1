$ErrorActionPreference = 'Stop'
$out = 'C:\ProgramData\MohamedLab\PowerShell'
New-Item -ItemType Directory -Path $out -Force | Out-Null
[pscustomobject]@{
    utc = (Get-Date).ToUniversalTime().ToString('o')
    computer = $env:COMPUTERNAME
    user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    pid = $PID
    result = 'Local training marker written'
} | ConvertTo-Json | Set-Content "$out\download-execution.json" -Encoding UTF8
