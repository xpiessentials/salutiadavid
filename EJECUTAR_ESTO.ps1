# =============================================
# Script Definitivo - Ejecutar ESTE
# =============================================

param(
  [switch]$SkipConfirmation
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?   Test Psicosomático - Migración Definitiva   ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Variables - ACTUALIZADO PARA SQL SERVER EXPRESS
$serverName = "LAPTOP-DAVID\SQLEXPRESS"
$databaseName = "Salutia"
$scriptPath = ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"

# Función para ejecutar SQL y capturar resultado
function Invoke-SqlCommand {
    param(
   [string]$Server,
        [string]$Database = "master",
        [string]$Query
    )
    
    try {
        $result = $Query | sqlcmd -S $Server -d $Database -E -W -h -1 2>&1
        return @{
    Success = $LASTEXITCODE -eq 0
            Output = $result
        }
    } catch {
        return @{
  Success = $false
          Output = $_.Exception.Message
        }
    }
}

# ============================================
# PASO 1: Verificar Conexión a SQL Server Express
# ============================================
Write-Host "?? PASO 1: Verificando conexión a SQL Server Express..." -ForegroundColor Yellow
Write-Host ""

$testConnectionQuery = "SELECT @@VERSION AS Version"
$connectionTest = Invoke-SqlCommand -Server $serverName -Database "master" -Query $testConnectionQuery

if ($connectionTest.Success) {
    Write-Host "   ? Conexión exitosa a SQL Server Express" -ForegroundColor Green
    $version = $connectionTest.Output | Select-String -Pattern "SQL Server" | Select-Object -First 1
    Write-Host "   Versión: $version" -ForegroundColor Gray
} else {
    Write-Host "   ? No se pudo conectar a SQL Server Express" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Error: $($connectionTest.Output)" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Soluciones:" -ForegroundColor Yellow
Write-Host "   1. Verifique que SQL Server Express esté instalado" -ForegroundColor White
    Write-Host "   2. Asegúrese de que el servicio esté corriendo:" -ForegroundColor White
    Write-Host "      Services.msc ? SQL Server (SQLEXPRESS) ? Iniciar" -ForegroundColor Gray
    Write-Host "   3. Verifique el nombre del servidor: $serverName" -ForegroundColor White
    exit 1
}

Write-Host ""

# ============================================
# PASO 2: Verificar Base de Datos Salutia
# ============================================
Write-Host "?? PASO 2: Verificando base de datos 'Salutia'..." -ForegroundColor Yellow
Write-Host ""

$checkDbQuery = "SELECT name, create_date FROM sys.databases WHERE name = '$databaseName'"
$dbExists = Invoke-SqlCommand -Server $serverName -Database "master" -Query $checkDbQuery

if ($dbExists.Success -and ($dbExists.Output -match $databaseName)) {
    Write-Host "   ? Base de datos '$databaseName' existe" -ForegroundColor Green
    
    # Verificar usuarios existentes
    $checkUsersQuery = "SELECT COUNT(*) AS UserCount FROM AspNetUsers"
  $usersCheck = Invoke-SqlCommand -Server $serverName -Database $databaseName -Query $checkUsersQuery
    
    if ($usersCheck.Success) {
        $userCount = ($usersCheck.Output | Select-String -Pattern "\d+").Matches[0].Value
   Write-Host "   ? Usuarios existentes en la BD: $userCount" -ForegroundColor Cyan
  }
} else {
    Write-Host "   ? Base de datos '$databaseName' NO EXISTE" -ForegroundColor Red
    Write-Host ""
    Write-Host "   La base de datos Salutia debería existir según tu configuración." -ForegroundColor Yellow
    Write-Host "   ¿Desea crearla ahora? (S/N): " -NoNewline -ForegroundColor Yellow
    $createDb = Read-Host
  
    if ($createDb -eq 'S' -or $createDb -eq 's') {
$createDbQuery = "CREATE DATABASE [$databaseName]"
        $createResult = Invoke-SqlCommand -Server $serverName -Database "master" -Query $createDbQuery
        
     if ($createResult.Success) {
     Write-Host "   ? Base de datos '$databaseName' creada exitosamente" -ForegroundColor Green
        } else {
            Write-Host "   ? Error al crear base de datos" -ForegroundColor Red
  Write-Host "   $($createResult.Output)" -ForegroundColor Red
            exit 1
    }
    } else {
        Write-Host "   Operación cancelada. La base de datos debe existir." -ForegroundColor Yellow
      exit 1
    }
}

Write-Host ""

# ============================================
# PASO 3: Verificar Script SQL
# ============================================
Write-Host "?? PASO 3: Verificando script de migración..." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $scriptPath)) {
    Write-Host "   ? Script SQL no encontrado" -ForegroundColor Red
    Write-Host "   Ruta esperada: $scriptPath" -ForegroundColor Gray
 Write-Host "   Ubicación actual: $(Get-Location)" -ForegroundColor Gray
    Write-Host ""
  Write-Host "   Solución: Navegue a la raíz del proyecto" -ForegroundColor Yellow
  Write-Host "   cd D:\Desarrollos\Repos\Salutia\" -ForegroundColor Gray
    exit 1
}

Write-Host "   ? Script SQL encontrado" -ForegroundColor Green
Write-Host "   Ruta: $scriptPath" -ForegroundColor Gray
Write-Host ""

# ============================================
# PASO 4: Verificar si las tablas ya existen
# ============================================
Write-Host "?? PASO 4: Verificando tablas existentes..." -ForegroundColor Yellow
Write-Host ""

$checkTablesQuery = @"
SELECT COUNT(*) AS TableCount
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN (
    'PsychosomaticTests', 'TestWords', 'TestPhrases', 
    'TestEmotions', 'TestDiscomfortLevels', 'TestAges', 'TestBodyParts',
    'TestAssociatedPersons', 'TestMatrices'
)
"@

$tablesExist = Invoke-SqlCommand -Server $serverName -Database $databaseName -Query $checkTablesQuery

if ($tablesExist.Success) {
    $tableCount = ($tablesExist.Output | Select-String -Pattern "\d+").Matches[0].Value
    
    if ([int]$tableCount -gt 0) {
        Write-Host "   ? Se encontraron $tableCount tablas del test ya existentes" -ForegroundColor Yellow
        Write-Host ""
        
        # Mostrar las tablas existentes
        $listTablesQuery = @"
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN (
    'PsychosomaticTests', 'TestWords', 'TestPhrases', 
    'TestEmotions', 'TestDiscomfortLevels', 'TestAges', 'TestBodyParts',
    'TestAssociatedPersons', 'TestMatrices'
)
ORDER BY TABLE_NAME
"@
      $existingTables = Invoke-SqlCommand -Server $serverName -Database $databaseName -Query $listTablesQuery
        Write-Host "   Tablas encontradas:" -ForegroundColor Cyan
        $existingTables.Output | Where-Object { $_ -match "Test|Psycho" } | ForEach-Object {
Write-Host "     - $_" -ForegroundColor Yellow
        }
        Write-Host ""
        
        if (-not $SkipConfirmation) {
            Write-Host "   ¿Desea recrear las tablas? Esto eliminará los datos existentes. (S/N): " -NoNewline -ForegroundColor Yellow
            $recreate = Read-Host
        
     if ($recreate -ne 'S' -and $recreate -ne 's') {
     Write-Host "   Operación cancelada. Las tablas ya existen." -ForegroundColor Yellow
    Write-Host ""
     Write-Host "   Si las tablas están completas, puede continuar con:" -ForegroundColor Cyan
      Write-Host "   dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
       exit 0
  }
        }
    } else {
        Write-Host "   ? No hay tablas del test psicosomático existentes" -ForegroundColor Green
    }
}

Write-Host ""

# ============================================
# PASO 5: Confirmar Ejecución
# ============================================
if (-not $SkipConfirmation) {
    Write-Host "?? PASO 5: Confirmación" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Se crearán las siguientes tablas en la base de datos '$databaseName':" -ForegroundColor White
    Write-Host ""
    Write-Host "   1. PsychosomaticTests     ? Test principal" -ForegroundColor Cyan
    Write-Host "   2. TestWords              ? 10 palabras" -ForegroundColor Cyan
    Write-Host "   3. TestPhrases            ? 10 frases" -ForegroundColor Cyan
    Write-Host "   4. TestEmotions           ? 10 emociones" -ForegroundColor Cyan
    Write-Host "   5. TestDiscomfortLevels   ? 10 niveles (1-10)" -ForegroundColor Cyan
    Write-Host "   6. TestAges               ? 10 edades" -ForegroundColor Cyan
    Write-Host "   7. TestBodyParts          ? 10 partes del cuerpo" -ForegroundColor Cyan
    Write-Host "   8. TestAssociatedPersons  ? 10 personas" -ForegroundColor Cyan
    Write-Host "   9. TestMatrices           ? Matriz consolidada" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Servidor: $serverName" -ForegroundColor Gray
    Write-Host "   Base de datos: $databaseName" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   ¿Desea continuar? (S/N): " -NoNewline -ForegroundColor Yellow
  $confirm = Read-Host
    
    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-Host "   Operación cancelada" -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

# ============================================
# PASO 6: Ejecutar Migración
# ============================================
Write-Host "?? PASO 6: Ejecutando migración..." -ForegroundColor Yellow
Write-Host ""

try {
    # Usar -E para autenticación de Windows (Trusted_Connection=True)
  $migrationOutput = sqlcmd -S $serverName -d $databaseName -E -i $scriptPath -b 2>&1
    
    $hasError = $false
    $migrationOutput | ForEach-Object {
        $line = $_.ToString()
    
        if ($line -match "error|Error|ERROR|failed|Failed") {
            Write-Host "   ? $line" -ForegroundColor Red
            $hasError = $true
      } elseif ($line -match "creada|exitosamente|completada|successfully|created") {
            Write-Host "   ? $line" -ForegroundColor Green
        } elseif ($line -match "ya existe|already exists") {
         Write-Host "   ? $line" -ForegroundColor Yellow
    } elseif ($line.Trim()) {
            Write-Host "   $line" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    
 if ($hasError -or $LASTEXITCODE -ne 0) {
        Write-Host "??????????????????????????????????????????????????" -ForegroundColor Red
  Write-Host "?           ? ERROR EN LA MIGRACIÓN    ?" -ForegroundColor Red
        Write-Host "??????????????????????????????????????????????????" -ForegroundColor Red
      Write-Host ""
   Write-Host "   Código de error: $LASTEXITCODE" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   Puede intentar ejecutar el script manualmente:" -ForegroundColor Yellow
        Write-Host "   sqlcmd -S ""$serverName"" -d ""$databaseName"" -E -i ""$scriptPath""" -ForegroundColor Gray
        exit 1
    }
    
} catch {
    Write-Host "   ? Excepción: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================
# PASO 7: Verificar Tablas Creadas
# ============================================
Write-Host "?? PASO 7: Verificando tablas creadas..." -ForegroundColor Yellow
Write-Host ""

$verifyQuery = @"
SELECT 
    TABLE_NAME,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMNS.TABLE_NAME = TABLES.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN (
    'PsychosomaticTests', 'TestWords', 'TestPhrases', 
    'TestEmotions', 'TestDiscomfortLevels', 'TestAges', 'TestBodyParts',
    'TestAssociatedPersons', 'TestMatrices'
)
ORDER BY TABLE_NAME
"@

$verifyResult = Invoke-SqlCommand -Server $serverName -Database $databaseName -Query $verifyQuery

if ($verifyResult.Success) {
    $tablesList = $verifyResult.Output | Where-Object { $_ -match "Test|Psycho" }
    
    if ($tablesList) {
        $tablesList | ForEach-Object {
            Write-Host "   ? $_" -ForegroundColor Green
        }
        
        # Contar tablas creadas
        $createdCount = ($tablesList | Measure-Object).Count
        Write-Host ""
        Write-Host "   Total de tablas creadas: $createdCount de 9" -ForegroundColor Cyan
    } else {
        Write-Host "   ? No se encontraron tablas. Verifique manualmente." -ForegroundColor Yellow
    }
} else {
    Write-Host "   ? No se pudo verificar las tablas" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# RESULTADO FINAL
# ============================================
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "?    ? MIGRACIÓN COMPLETADA CON ÉXITO           ?" -ForegroundColor Green
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "?? Siguientes Pasos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Compilar el proyecto:" -ForegroundColor White
Write-Host "      dotnet build" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Ejecutar la aplicación:" -ForegroundColor White
Write-Host "      dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Navegar en el navegador:" -ForegroundColor White
Write-Host "    https://localhost:[puerto]/test-psicosomatico" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Para profesionales, ver tests de pacientes:" -ForegroundColor White
Write-Host "      https://localhost:[puerto]/patient-tests" -ForegroundColor Gray
Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "?? Información de la Base de Datos:" -ForegroundColor Cyan
Write-Host "   Servidor: $serverName" -ForegroundColor Gray
Write-Host "   Base de datos: $databaseName" -ForegroundColor Gray
Write-Host "   Autenticación: Windows (Trusted_Connection)" -ForegroundColor Gray
Write-Host ""

Write-Host "Presione Enter para salir..." -ForegroundColor Gray
if (-not $SkipConfirmation) {
    Read-Host
}
