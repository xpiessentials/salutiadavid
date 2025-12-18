# =============================================
# EJECUTAR TODO - Ultra Simple
# =============================================

Write-Host "?????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  Test Psicosomático - Setup Rápido   ?" -ForegroundColor Cyan
Write-Host "?????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$server = "LAPTOP-DAVID\SQLEXPRESS"
$db = "Salutia"

Write-Host "1?? Verificando estado..." -ForegroundColor Yellow

# Verificar tablas
$check = @"
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('PsychosomaticTests', 'TestWords', 'TestPhrases', 
'TestEmotions', 'TestDiscomfortLevels', 'TestBodyParts',
'TestAssociatedPersons', 'TestMatrices')
"@ | sqlcmd -S $server -d $db -E -h -1 -W 2>&1

$count = if ($check -match "\d+") { [int]$Matches[0] } else { 0 }

Write-Host "   Tablas encontradas: $count de 8" -ForegroundColor Cyan
Write-Host ""

if ($count -eq 8) {
    Write-Host "? YA ESTÁ LISTO" -ForegroundColor Green
    Write-Host ""
 Write-Host "Las tablas ya existen. Puede ejecutar:" -ForegroundColor White
    Write-Host "dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
} else {
    Write-Host "?? Necesita migración" -ForegroundColor Yellow
    Write-Host ""
 Write-Host "¿Ejecutar migración ahora? (S/N): " -NoNewline -ForegroundColor Yellow
    $resp = Read-Host
 
    if ($resp -eq 'S' -or $resp -eq 's') {
 Write-Host ""
        Write-Host "2?? Ejecutando migración..." -ForegroundColor Yellow
        
$script = ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"
      
   if (Test-Path $script) {
            sqlcmd -S $server -d $db -E -i $script -b | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
       Write-Host "   ? Migración completada" -ForegroundColor Green
   Write-Host ""
 Write-Host "? TODO LISTO" -ForegroundColor Green
   Write-Host ""
      Write-Host "Ejecute:" -ForegroundColor White
 Write-Host "dotnet run --project "".\Salutia Wep App\Salutia Wep App.csproj""" -ForegroundColor Gray
            } else {
     Write-Host "   ? Error en migración" -ForegroundColor Red
       Write-Host "   Ejecute: .\EJECUTAR_ESTO.ps1" -ForegroundColor Yellow
  }
        } else {
         Write-Host "   ? Script no encontrado" -ForegroundColor Red
          Write-Host "   Ruta: $script" -ForegroundColor Gray
        }
    } else {
        Write-Host "   Cancelado" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Presione Enter..."
Read-Host
