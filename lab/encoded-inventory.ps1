$out = 'C:\ProgramData\MohamedLab\PowerShell'
New-Item -ItemType Directory -Path $out -Force | Out-Null
[pscustomobject]@{
    utc = (Get-Date).ToUniversalTime().ToString('o')
    computer = $env:COMPUTERNAME
    user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    process_count = @(Get-Process).Count
} | ConvertTo-Json | Set-Content "$out\encoded-inventory.json" -Encoding UTF8
