# =============================================
# Script PowerShell para aplicar migración del Test Psicosomático
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Psicosomático - Aplicar Migración" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Leer configuración de appsettings.json
$appSettingsPath = ".\Salutia Wep App\appsettings.json"

if (-not (Test-Path $appSettingsPath)) {
    Write-Host "? Error: No se encuentra appsettings.json" -ForegroundColor Red
    Write-Host "   Ruta esperada: $appSettingsPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "? Leyendo configuración..." -ForegroundColor Green

try {
    $appSettings = Get-Content $appSettingsPath | ConvertFrom-Json
    $connectionString = $appSettings.ConnectionStrings.sqlserver
    
    if ([string]::IsNullOrEmpty($connectionString)) {
     Write-Host "? Error: ConnectionString 'sqlserver' no encontrado" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "? ConnectionString encontrado" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "? Error al leer appsettings.json: $_" -ForegroundColor Red
    exit 1
}

# Ruta del script SQL
$sqlScriptPath = ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"

if (-not (Test-Path $sqlScriptPath)) {
Write-Host "? Error: Script SQL no encontrado" -ForegroundColor Red
    Write-Host "   Ruta esperada: $sqlScriptPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "? Script SQL encontrado" -ForegroundColor Green
Write-Host ""

# Confirmar ejecución
Write-Host "¿Desea aplicar la migración del Test Psicosomático?" -ForegroundColor Yellow
Write-Host "Esto creará las siguientes tablas:" -ForegroundColor White
Write-Host "  - PsychosomaticTests" -ForegroundColor Cyan
Write-Host "  - TestWords" -ForegroundColor Cyan
Write-Host "  - TestPhrases" -ForegroundColor Cyan
Write-Host "  - TestEmotions" -ForegroundColor Cyan
Write-Host "  - TestDiscomfortLevels" -ForegroundColor Cyan
Write-Host "  - TestBodyParts" -ForegroundColor Cyan
Write-Host "  - TestAssociatedPersons" -ForegroundColor Cyan
Write-Host "  - TestMatrices" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "Continuar? (S/N)"
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Ejecutando migración..." -ForegroundColor Cyan

try {
    # Ejecutar script SQL usando sqlcmd
$result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -i $sqlScriptPath -b
    
    if ($LASTEXITCODE -eq 0) {
    Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "? Migración aplicada exitosamente" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
     Write-Host ""
        Write-Host "Las tablas del Test Psicosomático han sido creadas." -ForegroundColor White
    Write-Host ""
     Write-Host "Próximos pasos:" -ForegroundColor Cyan
      Write-Host "1. Compile el proyecto: dotnet build" -ForegroundColor White
        Write-Host "2. Ejecute la aplicación: dotnet run --project '.\Salutia Wep App\Salutia Wep App.csproj'" -ForegroundColor White
        Write-Host "3. Navegue a: /test-psicosomatico" -ForegroundColor White
    } else {
  Write-Host ""
        Write-Host "? Error al ejecutar la migración" -ForegroundColor Red
        Write-Host "Verifique los mensajes de error anteriores." -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "? Error al ejecutar sqlcmd: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegúrese de que SQL Server LocalDB está instalado y en ejecución." -ForegroundColor Yellow
  Write-Host "Puede verificar con: sqllocaldb info MSSQLLocalDB" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Presione cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
