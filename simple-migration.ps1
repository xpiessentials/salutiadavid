# =============================================
# Script Alternativo Simple - Autenticación Windows
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Psicosomático - Migración Simple" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$serverName = "(localdb)\MSSQLLocalDB"
$databaseName = "Salutia"
$scriptPath = ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Servidor: $serverName" -ForegroundColor Gray
Write-Host "  Base de datos: $databaseName" -ForegroundColor Gray
Write-Host "  Script: $scriptPath" -ForegroundColor Gray
Write-Host ""

# Paso 1: Iniciar LocalDB
Write-Host "Paso 1: Iniciando LocalDB..." -ForegroundColor Yellow
sqllocaldb start MSSQLLocalDB 2>&1 | Out-Null
Start-Sleep -Seconds 2
Write-Host "? LocalDB iniciado" -ForegroundColor Green
Write-Host ""

# Paso 2: Crear base de datos si no existe
Write-Host "Paso 2: Verificando/Creando base de datos..." -ForegroundColor Yellow

$createDbCommand = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$databaseName')
BEGIN
    CREATE DATABASE [$databaseName];
    PRINT 'Base de datos creada';
END
ELSE
    PRINT 'Base de datos ya existe';
"@

$createDbCommand | sqlcmd -S $serverName -E -W -h -1

if ($LASTEXITCODE -eq 0) {
    Write-Host "? Base de datos lista" -ForegroundColor Green
} else {
    Write-Host "? Error al crear/verificar base de datos" -ForegroundColor Red
    Write-Host ""
    Write-Host "Intente ejecutar manualmente:" -ForegroundColor Yellow
    Write-Host "sqlcmd -S $serverName -E -Q ""CREATE DATABASE $databaseName""" -ForegroundColor Gray
    exit 1
}
Write-Host ""

# Paso 3: Verificar script
Write-Host "Paso 3: Verificando script SQL..." -ForegroundColor Yellow
if (-not (Test-Path $scriptPath)) {
    Write-Host "? Script no encontrado: $scriptPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ubicación actual: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "Asegúrese de estar en: D:\Desarrollos\Repos\Salutia\" -ForegroundColor Yellow
    exit 1
}
Write-Host "? Script encontrado" -ForegroundColor Green
Write-Host ""

# Paso 4: Confirmar
Write-Host "Paso 4: Confirmación" -ForegroundColor Yellow
Write-Host "¿Desea ejecutar la migración? (S/N): " -NoNewline -ForegroundColor White
$confirm = Read-Host

if ($confirm -ne 'S' -and $confirm -ne 's') {
    Write-Host "Operación cancelada" -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Paso 5: Ejecutar migración
Write-Host "Paso 5: Ejecutando migración..." -ForegroundColor Yellow
Write-Host ""

# Usar -E para autenticación de Windows
$result = sqlcmd -S $serverName -d $databaseName -E -i $scriptPath 2>&1

# Procesar resultado
$hasError = $false
$result | ForEach-Object {
    $line = $_.ToString()
    if ($line -match "error|Error|ERROR") {
Write-Host $line -ForegroundColor Red
        $hasError = $true
    } elseif ($line -match "creada|exitosamente|completada") {
   Write-Host $line -ForegroundColor Green
    } elseif ($line -match "ya existe") {
 Write-Host $line -ForegroundColor Yellow
    } else {
        Write-Host $line -ForegroundColor White
    }
}

Write-Host ""

if (-not $hasError -and $LASTEXITCODE -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "? MIGRACIÓN COMPLETADA" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Verificar tablas
    Write-Host "Verificando tablas creadas..." -ForegroundColor Cyan
    $verifyQuery = @"
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'
ORDER BY TABLE_NAME;
"@
    
    Write-Host ""
    $verifyQuery | sqlcmd -S $serverName -d $databaseName -E -h -1 -W | Where-Object { $_.Trim() } | ForEach-Object {
        Write-Host "  ? $_" -ForegroundColor Green
    }
  
    Write-Host ""
    Write-Host "Siguiente paso: Ejecutar la aplicación" -ForegroundColor Cyan
    Write-Host "  dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
    
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "? ERROR EN LA MIGRACIÓN" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Código de error: $LASTEXITCODE" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Presione Enter para salir..." -ForegroundColor Gray
Read-Host
