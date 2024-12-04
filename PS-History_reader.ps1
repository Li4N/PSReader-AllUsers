$usersPath = "C:\Users"
$users = Get-ChildItem -Path $usersPath -Directory
$relativePath = "\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine"
$resultados = @()

foreach ($user in $users) {
    $fullPath = Join-Path -Path $user.FullName -ChildPath $relativePath
    if (Test-Path -Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $resultados += [PSCustomObject]@{
                Usuario   = $user.Name
                Archivo   = $file.Name
                Ruta      = $file.FullName
                TamañoKB  = [math]::Round($file.Length / 1KB, 2)
                FechaMod  = $file.LastWriteTime
            }
            Write-Host "Contenido del archivo: $($file.FullName)" -ForegroundColor Cyan
            Get-Content -Path $file.FullName | ForEach-Object { Write-Host $_ }
            Write-Host "--------------------------------------------`n"
        }
    }
}

if ($resultados.Count -gt 0) {
    $resultados | Format-Table -AutoSize
} else {
    Write-Host "No se encontraron archivos PSReadLine en los perfiles de usuario."
}
