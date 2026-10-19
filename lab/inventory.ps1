$ErrorActionPreference = 'Stop'
$out = 'C:\ProgramData\MohamedLab\PowerShell'
New-Item -ItemType Directory -Path $out -Force | Out-Null
[pscustomobject]@{
    utc = (Get-Date).ToUniversalTime().ToString('o')
    computer = $env:COMPUTERNAME
    user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    powershell_version = $PSVersionTable.PSVersion.ToString()
    process_count = @(Get-Process).Count
} | ConvertTo-Json | Set-Content "$out\inventory.json" -Encoding UTF8
