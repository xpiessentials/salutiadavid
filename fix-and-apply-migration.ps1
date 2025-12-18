# =============================================
# Script Mejorado - Solución de Problemas y Migración
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Psicosomático - Solución y Migración" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar si LocalDB está corriendo
Write-Host "1. Verificando LocalDB..." -ForegroundColor Yellow

try {
 $localDbInfo = sqllocaldb info MSSQLLocalDB 2>&1
    
 if ($LASTEXITCODE -ne 0) {
        Write-Host "   LocalDB no está iniciado. Iniciando..." -ForegroundColor Yellow
      sqllocaldb start MSSQLLocalDB
        Start-Sleep -Seconds 3
        Write-Host "   ? LocalDB iniciado" -ForegroundColor Green
    } else {
   Write-Host "   ? LocalDB está corriendo" -ForegroundColor Green
    }
} catch {
 Write-Host "   ? Error al verificar LocalDB: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solución alternativa:" -ForegroundColor Yellow
    Write-Host "Ejecute manualmente: sqllocaldb start MSSQLLocalDB" -ForegroundColor White
    exit 1
}

Write-Host ""

# Paso 2: Verificar/Crear la base de datos
Write-Host "2. Verificando base de datos Salutia..." -ForegroundColor Yellow

$checkDbScript = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Salutia')
BEGIN
    PRINT 'Creando base de datos Salutia...'
    CREATE DATABASE Salutia;
    PRINT 'Base de datos creada exitosamente'
END
ELSE
BEGIN
    PRINT 'Base de datos Salutia ya existe'
END
GO
USE Salutia;
GO
SELECT 'Base de datos Salutia lista' AS Estado;
GO
"@

try {
    $checkDbScript | sqlcmd -S "(localdb)\MSSQLLocalDB" -b 2>&1 | ForEach-Object {
        Write-Host "   $_" -ForegroundColor Gray
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ? Base de datos verificada/creada" -ForegroundColor Green
    } else {
    throw "Error al crear/verificar la base de datos"
    }
} catch {
    Write-Host "   ? Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Intente crear la base de datos manualmente:" -ForegroundColor Yellow
    Write-Host "1. Abra SQL Server Management Studio (SSMS)" -ForegroundColor White
    Write-Host "2. Conéctese a: (localdb)\MSSQLLocalDB" -ForegroundColor White
    Write-Host "3. Ejecute: CREATE DATABASE Salutia;" -ForegroundColor White
    exit 1
}

Write-Host ""

# Paso 3: Verificar que el script SQL existe
Write-Host "3. Verificando script de migración..." -ForegroundColor Yellow

$sqlScriptPath = ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"

if (-not (Test-Path $sqlScriptPath)) {
    Write-Host "   ? Script SQL no encontrado en: $sqlScriptPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegúrese de ejecutar este script desde la raíz del proyecto (D:\Desarrollos\Repos\Salutia\)" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ? Script SQL encontrado" -ForegroundColor Green
Write-Host ""

# Paso 4: Confirmar ejecución
Write-Host "4. ¿Desea aplicar la migración del Test Psicosomático?" -ForegroundColor Yellow
Write-Host ""
Write-Host "Esto creará las siguientes tablas en la base de datos 'Salutia':" -ForegroundColor White
Write-Host "  ? PsychosomaticTests" -ForegroundColor Cyan
Write-Host "  ? TestWords" -ForegroundColor Cyan
Write-Host "  ? TestPhrases" -ForegroundColor Cyan
Write-Host "  ? TestEmotions" -ForegroundColor Cyan
Write-Host "  ? TestDiscomfortLevels" -ForegroundColor Cyan
Write-Host "  ? TestBodyParts" -ForegroundColor Cyan
Write-Host "  ? TestAssociatedPersons" -ForegroundColor Cyan
Write-Host "  ? TestMatrices" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "Continuar? (S/N)"
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "5. Ejecutando migración..." -ForegroundColor Cyan
Write-Host ""

try {
    # Ejecutar el script SQL
    $output = sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -i $sqlScriptPath -b 2>&1
    
  # Mostrar salida
    $output | ForEach-Object {
if ($_ -match "?|creada|exitosamente") {
     Write-Host $_ -ForegroundColor Green
        } elseif ($_ -match "Error|error") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -match "ya existe") {
     Write-Host $_ -ForegroundColor Yellow
        } else {
 Write-Host $_ -ForegroundColor White
        }
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "? MIGRACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
      Write-Host ""
        Write-Host "Las tablas del Test Psicosomático han sido creadas." -ForegroundColor White
        Write-Host ""
        Write-Host "?? Próximos pasos:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Compile el proyecto:" -ForegroundColor White
    Write-Host "   dotnet build" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Ejecute la aplicación:" -ForegroundColor White
        Write-Host "   dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
   Write-Host ""
        Write-Host "3. Navegue en su navegador a:" -ForegroundColor White
        Write-Host "   https://localhost:[puerto]/test-psicosomatico" -ForegroundColor Gray
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        
        # Verificar las tablas creadas
        Write-Host ""
        Write-Host "Verificando tablas creadas..." -ForegroundColor Yellow
        
 $verifyScript = @"
USE Salutia;
GO
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'
ORDER BY TABLE_NAME;
GO
"@
     
   Write-Host ""
        Write-Host "Tablas encontradas:" -ForegroundColor Cyan
        $verifyScript | sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -h -1 -W | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
  Write-Host "  ? $_" -ForegroundColor Green
        }
        
    } else {
        Write-Host ""
  Write-Host "========================================" -ForegroundColor Red
        Write-Host "? ERROR EN LA MIGRACIÓN" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
   Write-Host "Revise los mensajes de error anteriores." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Si el error persiste:" -ForegroundColor Yellow
    Write-Host "1. Abra SQL Server Management Studio (SSMS)" -ForegroundColor White
        Write-Host "2. Conéctese a: (localdb)\MSSQLLocalDB" -ForegroundColor White
        Write-Host "3. Ejecute manualmente el script ubicado en:" -ForegroundColor White
    Write-Host "   $sqlScriptPath" -ForegroundColor Gray
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "? ERROR CRÍTICO" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles soluciones:" -ForegroundColor Yellow
    Write-Host "1. Verifique que SQL Server LocalDB está instalado" -ForegroundColor White
    Write-Host "2. Ejecute: sqllocaldb info" -ForegroundColor Gray
    Write-Host "3. Si no aparece 'MSSQLLocalDB', créelo con:" -ForegroundColor White
    Write-Host "   sqllocaldb create MSSQLLocalDB" -ForegroundColor Gray
    Write-Host "4. Luego inicie LocalDB con:" -ForegroundColor White
    Write-Host "   sqllocaldb start MSSQLLocalDB" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Presione cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
