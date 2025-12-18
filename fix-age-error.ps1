# fix-age-error.ps1
# Script para verificar y corregir el error de columna Age

Write-Host ""
Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?     FIX: Invalid column name 'Age' - Test Tables     ?" -ForegroundColor Cyan
Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Verificar si SQL Server está corriendo
Write-Host "[1/4] Verificando SQL Server..." -ForegroundColor Yellow

$sqlService = Get-Service -Name "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue

if ($sqlService -and $sqlService.Status -eq "Running") {
    Write-Host "      ? SQL Server está corriendo" -ForegroundColor Green
} else {
    Write-Host "      ? SQL Server no está corriendo" -ForegroundColor Red
    Write-Host "      Iniciando SQL Server..." -ForegroundColor Yellow
    Start-Service -Name "MSSQL`$SQLEXPRESS"
    Start-Sleep -Seconds 5
    Write-Host "      ? SQL Server iniciado" -ForegroundColor Green
}

# Verificar si la tabla TestAges existe
Write-Host ""
Write-Host "[2/4] Verificando tabla TestAges..." -ForegroundColor Yellow

$checkQuery = @"
USE Salutia;
SELECT COUNT(*) as TableExists
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'TestAges';
"@

try {
    $result = Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Query $checkQuery -ErrorAction Stop
    
    if ($result.TableExists -eq 1) {
        Write-Host "      ? Tabla TestAges existe" -ForegroundColor Green
        
        # Verificar columna Age
        $checkColumn = @"
USE Salutia;
SELECT COUNT(*) as ColumnExists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TestAges' AND COLUMN_NAME = 'Age';
"@
        $columnResult = Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Query $checkColumn
        
        if ($columnResult.ColumnExists -eq 1) {
            Write-Host "      ? Columna Age existe" -ForegroundColor Green
            Write-Host ""
            Write-Host "      ? La tabla y columna ya existen" -ForegroundColor Cyan
            Write-Host "      ? El error puede ser de caché o configuración" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "RECOMENDACIÓN:" -ForegroundColor Yellow
            Write-Host "  1. Reinicia la aplicación (Shift + F5, luego F5)" -ForegroundColor White
            Write-Host "  2. Si persiste, ejecuta: .\cleanup-and-restart.ps1" -ForegroundColor White
            exit 0
        } else {
            Write-Host "      ? Columna Age NO existe" -ForegroundColor Red
        }
    } else {
        Write-Host "      ? Tabla TestAges NO existe" -ForegroundColor Red
    }
} catch {
    Write-Host "      ? Error al verificar tabla: $($_.Exception.Message)" -ForegroundColor Red
}

# Aplicar migración completa
Write-Host ""
Write-Host "[3/4] Aplicando migración de Test Psicosomático..." -ForegroundColor Yellow

$scriptPath = "Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"

if (Test-Path $scriptPath) {
    Write-Host "      ? Ejecutando script: $scriptPath" -ForegroundColor Cyan
    
    try {
        Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -InputFile $scriptPath -ErrorAction Stop
        Write-Host "      ? Migración aplicada exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "      ? Error al aplicar migración: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "      ? No se encontró el archivo de migración" -ForegroundColor Red
    exit 1
}

# Verificar que se crearon las tablas
Write-Host ""
Write-Host "[4/4] Verificando tablas creadas..." -ForegroundColor Yellow

$verifyQuery = @"
USE Salutia;
SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'
ORDER BY TABLE_NAME;
"@

try {
    $tables = Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Query $verifyQuery
    
    $expectedTables = @(
        'PsychosomaticTests',
        'TestAges',
        'TestAssociatedPersons',
        'TestBodyParts',
        'TestDiscomfortLevels',
        'TestEmotions',
        'TestMatrices',
        'TestPhrases',
        'TestWords'
    )
    
    $foundTables = $tables | ForEach-Object { $_.TABLE_NAME }
    
    Write-Host ""
    Write-Host "      Tablas encontradas:" -ForegroundColor Cyan
    foreach ($table in $foundTables) {
        if ($expectedTables -contains $table) {
            Write-Host "      ? $table" -ForegroundColor Green
        } else {
            Write-Host "      • $table" -ForegroundColor Gray
        }
    }
    
    # Verificar específicamente la columna Age
    Write-Host ""
    Write-Host "      Verificando columna Age en TestAges:" -ForegroundColor Cyan
    $checkAgeColumn = @"
USE Salutia;
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TestAges';
"@
    $ageColumns = Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Query $checkAgeColumn
    
    foreach ($col in $ageColumns) {
        if ($col.COLUMN_NAME -eq 'Age') {
            Write-Host "      ? Age ($($col.DATA_TYPE)($($col.CHARACTER_MAXIMUM_LENGTH)))" -ForegroundColor Green
        } else {
            Write-Host "      • $($col.COLUMN_NAME) ($($col.DATA_TYPE))" -ForegroundColor Gray
        }
    }
    
} catch {
    Write-Host "      ? Error al verificar tablas: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Resumen final
Write-Host ""
Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "?              ? MIGRACIÓN COMPLETADA                   ?" -ForegroundColor Green
Write-Host "?????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "SIGUIENTES PASOS:" -ForegroundColor Cyan
Write-Host "  1. Reinicia la aplicación:" -ForegroundColor White
Write-Host "     - Shift + F5 (Detener)" -ForegroundColor Gray
Write-Host "     - F5 (Iniciar)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Prueba el test de nuevo:" -ForegroundColor White
Write-Host "     - Navega a /test-psicosomatico" -ForegroundColor Gray
Write-Host "     - Completa las 7 preguntas" -ForegroundColor Gray
Write-Host "     - Click en 'Guardar y Finalizar Test'" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. El error 'Invalid column name Age' debería" -ForegroundColor White
Write-Host "     haber desaparecido ?" -ForegroundColor Green
Write-Host ""
