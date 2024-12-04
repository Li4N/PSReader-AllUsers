param (
    [Parameter(Mandatory = $true)]
    [bool]$typeOutput
)

if ($PSBoundParameters.Count -eq 0) {
    Write-Host "Script Usage:" -ForegroundColor Yellow
    Write-Host "  Run this script with the mandatory parameter --typeOutput to control the type of output."
    Write-Host "  Example:"
    Write-Host "    & '.\PS-History_reader.ps1' -typeOutput $true"
    Write-Host "    & '.\PS-History_reader.ps1' -typeOutput $false"
    Exit
}

$usersPath = "C:\Users"
$users = Get-ChildItem -Path $usersPath -Directory
$relativePath = "\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine"
$results = @()

foreach ($user in $users) {
    $fullPath = Join-Path -Path $user.FullName -ChildPath $relativePath
    if (Test-Path -Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $results += [PSCustomObject]@{
                User      = $user.Name
                File      = $file.Name
                Path      = $file.FullName
                SizeKB    = [math]::Round($file.Length / 1KB, 2)
                LastMod   = $file.LastWriteTime
            }
            if ($typeOutput) {
                Write-Host "File content: $($file.FullName)" -ForegroundColor Cyan
                Get-Content -Path $file.FullName | ForEach-Object { Write-Host $_ }
                Write-Host "--------------------------------------------`n"
            }
        }
    }
}

if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
} else {
    Write-Host "No PSReadLine files were found in user profiles."
}
