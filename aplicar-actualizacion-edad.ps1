# =============================================
# Actualizar Test Psicosomático - Agregar Edad
# Mantiene datos existentes
# =============================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?   Actualización Test Psicosomático - Edad     ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$serverName = "LAPTOP-DAVID\SQLEXPRESS"
$databaseName = "Salutia"
$scriptPath = ".\Salutia Wep App\Data\Migrations\UpdatePsychosomaticTestAddAge.sql"

Write-Host "?? Configuración:" -ForegroundColor Yellow
Write-Host "   Servidor: $serverName" -ForegroundColor Gray
Write-Host "   Base de datos: $databaseName" -ForegroundColor Gray
Write-Host ""

# ============================================
# Verificar conexión
# ============================================
Write-Host "?? Paso 1: Verificando conexión..." -ForegroundColor Yellow

$testQuery = "SELECT @@VERSION"
$connectionTest = $testQuery | sqlcmd -S $serverName -d "master" -E -h -1 -W 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ? Conexión exitosa" -ForegroundColor Green
} else {
    Write-Host "   ? Error de conexión" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ============================================
# Verificar script
# ============================================
Write-Host "?? Paso 2: Verificando script..." -ForegroundColor Yellow

if (-not (Test-Path $scriptPath)) {
    Write-Host "   ? Script no encontrado: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "   ? Script encontrado" -ForegroundColor Green
Write-Host ""

# ============================================
# Verificar estado actual
# ============================================
Write-Host "?? Paso 3: Verificando estado actual..." -ForegroundColor Yellow

# Verificar si TestAges existe
$checkAges = @"
SELECT CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'TestAges') 
       THEN 1 ELSE 0 END AS Existe
"@ | sqlcmd -S $serverName -d $databaseName -E -h -1 -W 2>&1

$agesExists = $checkAges -match "1"

if ($agesExists) {
    Write-Host "   ? TestAges ya existe" -ForegroundColor Green
} else {
    Write-Host "   ? TestAges NO existe (se creará)" -ForegroundColor Cyan
}

# Verificar si TestMatrices tiene columna Age
$checkAge = @"
SELECT CASE WHEN EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'TestMatrices' AND COLUMN_NAME = 'Age'
) THEN 1 ELSE 0 END AS Existe
"@ | sqlcmd -S $serverName -d $databaseName -E -h -1 -W 2>&1

$ageColumnExists = $checkAge -match "1"

if ($ageColumnExists) {
    Write-Host "   ? TestMatrices.Age ya existe" -ForegroundColor Green
} else {
    Write-Host "   ? TestMatrices.Age NO existe (se agregará)" -ForegroundColor Cyan
}

Write-Host ""

# ============================================
# Verificar tests existentes
# ============================================
Write-Host "?? Paso 4: Verificando tests existentes..." -ForegroundColor Yellow

$testsQuery = @"
SELECT 
    COUNT(*) AS Total,
    SUM(CASE WHEN IsCompleted = 1 THEN 1 ELSE 0 END) AS Completados,
    SUM(CASE WHEN IsCompleted = 0 THEN 1 ELSE 0 END) AS EnProgreso
FROM PsychosomaticTests
"@ | sqlcmd -S $serverName -d $databaseName -E -W 2>&1

if ($LASTEXITCODE -eq 0) {
    $testsData = $testsQuery | Where-Object { $_ -match "\d+" }
    if ($testsData) {
        Write-Host "   ? Tests en la base de datos:" -ForegroundColor Cyan
        $testsData | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "   ?? NOTA: Los tests completados NO tendrán datos de edad" -ForegroundColor Yellow
        Write-Host "     Solo los nuevos tests incluirán esta información" -ForegroundColor Gray
    } else {
        Write-Host "   ? No hay tests en la base de datos" -ForegroundColor Gray
    }
} else {
    Write-Host "   ? No hay tests todavía" -ForegroundColor Gray
}

Write-Host ""

# ============================================
# Confirmación
# ============================================
if ($agesExists -and $ageColumnExists) {
    Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host "?   ? ACTUALIZACIÓN YA APLICADA                  ?" -ForegroundColor Green
    Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host ""
    Write-Host "El test ya está actualizado con la pregunta de edad." -ForegroundColor White
    Write-Host ""
    Write-Host "Puede ejecutar la aplicación:" -ForegroundColor Cyan
    Write-Host "dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Presione Enter para salir"
    exit 0
}

Write-Host "?? Paso 5: Confirmación" -ForegroundColor Yellow
Write-Host ""
Write-Host "Esta actualización agregará:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Tabla TestAges (para almacenar las edades)" -ForegroundColor Cyan
Write-Host "  2. Columna Age en TestMatrices" -ForegroundColor Cyan
Write-Host ""
Write-Host "? MANTIENE todos los datos existentes" -ForegroundColor Green
Write-Host "? Solo agrega nuevas estructuras" -ForegroundColor Green
Write-Host ""
Write-Host "¿Desea continuar? (S/N): " -NoNewline -ForegroundColor Yellow
$confirm = Read-Host

if ($confirm -ne 'S' -and $confirm -ne 's') {
    Write-Host "Operación cancelada" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# ============================================
# Ejecutar actualización
# ============================================
Write-Host "?? Paso 6: Aplicando actualización..." -ForegroundColor Yellow
Write-Host ""

try {
    $output = sqlcmd -S $serverName -d $databaseName -E -i $scriptPath -b 2>&1
    
    $hasError = $false
    $output | ForEach-Object {
        $line = $_.ToString()
        
        if ($line -match "error|Error|ERROR") {
            Write-Host "   ? $line" -ForegroundColor Red
            $hasError = $true
        } elseif ($line -match "?|exitosa|creada|agregada") {
            Write-Host "   ? $line" -ForegroundColor Green
        } elseif ($line -match "??|NOTA|Advertencia") {
            Write-Host "   $line" -ForegroundColor Yellow
        } elseif ($line -match "?|?|?" -or $line -match "Tabla|Total") {
            Write-Host "   $line" -ForegroundColor Cyan
        } elseif ($line.Trim()) {
            Write-Host "   $line" -ForegroundColor Gray
        }
    }
    
    if ($hasError -or $LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "??????????????????????????????????????????????????" -ForegroundColor Red
        Write-Host "?   ? ERROR EN LA ACTUALIZACIÓN                  ?" -ForegroundColor Red
        Write-Host "??????????????????????????????????????????????????" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "   ? Excepción: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ============================================
# Resultado final
# ============================================
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "?   ? ACTUALIZACIÓN COMPLETADA                   ?" -ForegroundColor Green
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "?? Cambios aplicados:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ? Tabla TestAges creada" -ForegroundColor Green
Write-Host "  ? Columna Age agregada a TestMatrices" -ForegroundColor Green
Write-Host "  ? Test actualizado a 7 preguntas" -ForegroundColor Green
Write-Host ""
Write-Host "?? Estructura del Test:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Palabras (10)" -ForegroundColor White
Write-Host "  2. Frases (10)" -ForegroundColor White
Write-Host "  3. Emociones (10)" -ForegroundColor White
Write-Host "  4. Niveles de Malestar (10)" -ForegroundColor White
Write-Host "  5. Edad del Malestar (10) ? NUEVA" -ForegroundColor Yellow
Write-Host "  6. Partes del Cuerpo (10)" -ForegroundColor White
Write-Host "  7. Personas Asociadas (10)" -ForegroundColor White
Write-Host ""
Write-Host "?? Siguiente paso:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
Write-Host ""
Write-Host "Presione Enter para salir..."
Read-Host
