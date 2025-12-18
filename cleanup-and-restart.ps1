# cleanup-and-restart.ps1
# Script de limpieza total para aplicar cambios en Blazor

Write-Host ""
Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?       LIMPIEZA TOTAL Y RECOMPILACIÓN - BLAZOR        ?" -ForegroundColor Cyan
Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# 1. Detener procesos
Write-Host "[1/5] Deteniendo procesos..." -ForegroundColor Yellow
$processesKilled = 0

$processes = @("dotnet", "msedge", "chrome", "iisexpress")
foreach ($proc in $processes) {
    $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($running) {
        $running | Stop-Process -Force
        $processesKilled++
        Write-Host "      ? Detenido: $proc" -ForegroundColor Green
    }
}

if ($processesKilled -eq 0) {
    Write-Host "      ? No hay procesos activos" -ForegroundColor Gray
}

Start-Sleep -Seconds 2

# 2. Cambiar al directorio del proyecto
Write-Host ""
Write-Host "[2/5] Cambiando al directorio del proyecto..." -ForegroundColor Yellow
$projectPath = "D:\Desarrollos\Repos\Salutia"

if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "      ? Directorio: $projectPath" -ForegroundColor Green
} else {
    Write-Host "      ? No se encontró el directorio del proyecto" -ForegroundColor Red
    exit 1
}

# 3. Ejecutar dotnet clean
Write-Host ""
Write-Host "[3/5] Ejecutando dotnet clean..." -ForegroundColor Yellow
dotnet clean | Out-Null
Write-Host "      ? Limpieza de solución completada" -ForegroundColor Green

# 4. Eliminar directorios bin y obj
Write-Host ""
Write-Host "[4/5] Eliminando directorios bin y obj..." -ForegroundColor Yellow

$dirsToDelete = @(
    "Salutia Wep App\bin",
    "Salutia Wep App\obj",
    "Salutia.MobileApp\bin",
    "Salutia.MobileApp\obj",
    "Salutia.Shared\bin",
    "Salutia.Shared\obj"
)

foreach ($dir in $dirsToDelete) {
    $fullPath = Join-Path $projectPath $dir
    if (Test-Path $fullPath) {
        Remove-Item -Recurse -Force $fullPath -ErrorAction SilentlyContinue
        Write-Host "      ? Eliminado: $dir" -ForegroundColor Green
    }
}

# 5. Recompilar
Write-Host ""
Write-Host "[5/5] Recompilando proyecto..." -ForegroundColor Yellow
$buildOutput = dotnet build "Salutia Wep App\Salutia Wep App.csproj" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "      ? Compilación exitosa" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host "?                  ? LISTO PARA PROBAR                  ?" -ForegroundColor Green
    Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host ""
    Write-Host "SIGUIENTES PASOS:" -ForegroundColor Cyan
    Write-Host "  1. Presiona F5 en Visual Studio" -ForegroundColor White
    Write-Host "  2. Espera a que abra el navegador" -ForegroundColor White
    Write-Host "  3. Navega a /test-psicosomatico" -ForegroundColor White
    Write-Host "  4. Haz click en un campo de texto" -ForegroundColor White
    Write-Host "  5. Verifica en consola (F12) - NO debe haber error" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "      ? Error en compilación" -ForegroundColor Red
    Write-Host ""
    Write-Host "DETALLES DEL ERROR:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Resumen
Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "RESUMEN:" -ForegroundColor Cyan
Write-Host "  • Procesos detenidos: $processesKilled" -ForegroundColor White
Write-Host "  • Directorios limpiados: ?" -ForegroundColor Green
Write-Host "  • Compilación: ? Exitosa" -ForegroundColor Green
Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""
