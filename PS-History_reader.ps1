# Script para detectar archivos PSReadLine en todas las cuentas de usuario de la máquina y mostrar su contenido

# Obtener la lista de carpetas de usuarios en C:\Users
$usersPath = "C:\Users"
$users = Get-ChildItem -Path $usersPath -Directory

# Ruta relativa dentro de cada perfil de usuario
$relativePath = "\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine"

# Crear una lista para almacenar los resultados
$resultados = @()

# Iterar sobre cada usuario
foreach ($user in $users) {
    # Construir la ruta completa
    $fullPath = Join-Path -Path $user.FullName -ChildPath $relativePath

    # Verificar si la carpeta existe
    if (Test-Path -Path $fullPath) {
        # Obtener los archivos en la carpeta
        $files = Get-ChildItem -Path $fullPath -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            # Añadir información a los resultados
            $resultados += [PSCustomObject]@{
                Usuario   = $user.Name
                Archivo   = $file.Name
                Ruta      = $file.FullName
                TamañoKB  = [math]::Round($file.Length / 1KB, 2)
                FechaMod  = $file.LastWriteTime
            }
            
            # Mostrar el contenido del archivo
            Write-Host "Contenido del archivo: $($file.FullName)" -ForegroundColor Cyan
            Get-Content -Path $file.FullName | ForEach-Object { Write-Host $_ }
            Write-Host "--------------------------------------------`n"
        }
    }
}

# Mostrar los resultados
if ($resultados.Count -gt 0) {
    $resultados | Format-Table -AutoSize
} else {
    Write-Host "No se encontraron archivos PSReadLine en los perfiles de usuario."
}

# Exportar resultados a un archivo CSV (opcional)
# $resultados | Export-Csv -Path "PSReadLineFiles.csv" -NoTypeInformation -Encoding UTF8
