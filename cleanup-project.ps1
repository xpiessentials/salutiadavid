# ?? SCRIPT DE LIMPIEZA AUTOMÁTICA DEL PROYECTO SALUTIA
# Versión: 1.0
# Fecha: 2025-01-12

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateBackup = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput = $false
)

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

# Colores para output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header($message) {
    Write-Host ""
    Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Cyan
  Write-Host " $message" -ForegroundColor Cyan
    Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success($message) {
    Write-Host "? $message" -ForegroundColor Green
}

function Write-Info($message) {
    Write-Host "??  $message" -ForegroundColor Cyan
}

function Write-Warning2($message) {
    Write-Host "??  $message" -ForegroundColor Yellow
}

function Write-Error2($message) {
    Write-Host "? $message" -ForegroundColor Red
}

# Banner
Clear-Host
Write-Host ""
Write-Host "????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?              ?" -ForegroundColor Cyan
Write-Host "?      SCRIPT DE LIMPIEZA AUTOMÁTICA - PROYECTO SALUTIA  ?" -ForegroundColor Cyan
Write-Host "?            ?" -ForegroundColor Cyan
Write-Host "????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Variables
$projectRoot = Get-Location
$archiveFolder = Join-Path $projectRoot "_Archive"
$backupFolder = Join-Path $projectRoot "_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$logFile = Join-Path $projectRoot "cleanup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Arrays para tracking
$deletedFiles = @()
$archivedFiles = @()
$errors = @()

# Logging function
function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 "$timestamp - $message" | Out-File -FilePath $logFile -Append
    if ($VerboseOutput) {
        Write-Host $message -ForegroundColor Gray
    }
}
Write-Header "CONFIGURACIÓN"
Write-Info "Directorio de trabajo: $projectRoot"
Write-Info "Modo: $(if($DryRun){'SIMULACIÓN (Dry Run)'}else{'EJECUCIÓN REAL'})"
Write-Info "Crear backup: $(if($CreateBackup){'SÍ'}else{'NO'})"
Write-Info "Log file: $logFile"
Write-Host ""

if ($DryRun) {
    Write-Warning2 "MODO SIMULACIÓN ACTIVADO - No se realizarán cambios reales"
    Write-Host ""
}

# Confirmación
if (-not $DryRun) {
    Write-Host "??  ADVERTENCIA: Esta operación moverá/eliminará archivos." -ForegroundColor Yellow
    Write-Host "¿Desea continuar? (S/N): " -NoNewline -ForegroundColor Yellow
    $confirmation = Read-Host
    if ($confirmation -ne 'S' -and $confirmation -ne 's') {
        Write-Error2 "Operación cancelada por el usuario"
        exit 0
    }
}

Write-Header "FASE 1: CREAR ESTRUCTURA DE ARCHIVADO"

# Crear carpetas de archivo
$archiveFolders = @(
    (Join-Path $archiveFolder "Setup"),
    (Join-Path $archiveFolder "Migrations"),
    (Join-Path $archiveFolder "Fixes"),
    (Join-Path $archiveFolder "Guides")
)

foreach ($folder in $archiveFolders) {
    if (-not (Test-Path $folder)) {
        if (-not $DryRun) {
 New-Item -ItemType Directory -Path $folder -Force | Out-Null
     Write-Success "Creada carpeta: $folder"
        } else {
            Write-Info "[DRY-RUN] Crear carpeta: $folder"
        }
        Write-Log "Carpeta creada: $folder"
    }
}

# Crear backup si está habilitado
if ($CreateBackup -and -not $DryRun) {
    Write-Header "CREANDO BACKUP"
    New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
    Write-Success "Carpeta de backup creada: $backupFolder"
}

Write-Header "FASE 2: ELIMINAR ARCHIVOS TEMPORALES"

# Archivos temporales para eliminar
$tempFilesToDelete = @(
    "Salutia Wep App\Salutia Wep App.csproj.Backup.tmp"
)

foreach ($file in $tempFilesToDelete) {
    $fullPath = Join-Path $projectRoot $file
    if (Test-Path $fullPath) {
     try {
   if (-not $DryRun) {
       if ($CreateBackup) {
     $backupPath = Join-Path $backupFolder $file
   $backupDir = Split-Path $backupPath -Parent
       if (-not (Test-Path $backupDir)) {
     New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
   }
  Copy-Item -Path $fullPath -Destination $backupPath -Force
   }
    Remove-Item -Path $fullPath -Force
  Write-Success "Eliminado: $file"
                $deletedFiles += $file
            } else {
          Write-Info "[DRY-RUN] Eliminar: $file"
          }
            Write-Log "Archivo eliminado: $file"
        }
        catch {
    Write-Error2 "Error al eliminar $file : $_"
            $errors += "Error eliminando $file : $_"
            Write-Log "ERROR: $file - $_"
  }
    } else {
        Write-Warning2 "No encontrado: $file"
        Write-Log "Archivo no encontrado: $file"
    }
}

Write-Header "FASE 3: ARCHIVAR SCRIPTS DE SETUP DE SUPERADMIN"

$setupScripts = @(
    "cleanup-and-create-superadmin.ps1",
    "cleanup-and-create-superadmin.sql",
    "create-superadmin-direct.sql",
    "create-superadmin-via-api.ps1",
    "create-superadmin.ps1",
    "generate-superadmin-with-correct-hash.ps1"
)

$setupArchive = Join-Path $archiveFolder "Setup"
foreach ($file in $setupScripts) {
    $fullPath = Join-Path $projectRoot $file
    if (Test-Path $fullPath) {
     try {
            $destPath = Join-Path $setupArchive $file
         if (-not $DryRun) {
            if ($CreateBackup) {
          $backupPath = Join-Path $backupFolder $file
     Copy-Item -Path $fullPath -Destination $backupPath -Force
        }
    Move-Item -Path $fullPath -Destination $destPath -Force
 Write-Success "Archivado: $file ? Setup/"
         $archivedFiles += $file
          } else {
          Write-Info "[DRY-RUN] Archivar: $file ? Setup/"
            }
Write-Log "Archivo archivado: $file ? Setup/"
        }
  catch {
 Write-Error2 "Error al archivar $file : $_"
         $errors += "Error archivando $file : $_"
            Write-Log "ERROR: $file - $_"
        }
    }
}

Write-Header "FASE 4: ARCHIVAR SCRIPTS DE MIGRACIÓN"

$migrationScripts = @(
    "apply-new-user-system-migration.ps1",
    "apply-user-system-migration.ps1",
 "update-user-references.ps1",
    "Database-Migration-UserSystem-Update.sql",
    "cleanup-database.sql"
)

$migrationArchive = Join-Path $archiveFolder "Migrations"
foreach ($file in $migrationScripts) {
    $fullPath = Join-Path $projectRoot $file
    if (Test-Path $fullPath) {
     try {
            $destPath = Join-Path $migrationArchive $file
            if (-not $DryRun) {
         if ($CreateBackup) {
         $backupPath = Join-Path $backupFolder $file
  Copy-Item -Path $fullPath -Destination $backupPath -Force
      }
       Move-Item -Path $fullPath -Destination $destPath -Force
       Write-Success "Archivado: $file ? Migrations/"
       $archivedFiles += $file
       } else {
    Write-Info "[DRY-RUN] Archivar: $file ? Migrations/"
  }
            Write-Log "Archivo archivado: $file ? Migrations/"
        }
        catch {
            Write-Error2 "Error al archivar $file : $_"
       $errors += "Error archivando $file : $_"
            Write-Log "ERROR: $file - $_"
      }
  }
}

Write-Header "FASE 5: ARCHIVAR DOCUMENTACIÓN DE CORRECCIONES"

$fixDocs = @(
    "ADMIN_DASHBOARD_REVIEW.md",
    "ANTIFORGERY_FIX_CREATEENTITY.md",
 "ANTIFORGERY_TOKEN_FIX.md",
    "ENTITY_DASHBOARD_QUICK_ACTIONS_COMPLETE.md",
    "PROFESSIONALDETAILS_CORRECTED_FILE.md",
    "PROFESSIONAL_REGISTRATION_COMPLETE.md",
    "SOLUCION_ERROR_404.md",
    "FORMULARIOS_ANTIFORGERY_CHECKLIST.md",
    "PENDING_TASKS_CHECKLIST.md"
)

$fixesArchive = Join-Path $archiveFolder "Fixes"
foreach ($file in $fixDocs) {
    $fullPath = Join-Path $projectRoot $file
    if (Test-Path $fullPath) {
        try {
         $destPath = Join-Path $fixesArchive $file
            if (-not $DryRun) {
      if ($CreateBackup) {
          $backupPath = Join-Path $backupFolder $file
    Copy-Item -Path $fullPath -Destination $backupPath -Force
    }
       Move-Item -Path $fullPath -Destination $destPath -Force
                Write-Success "Archivado: $file ? Fixes/"
     $archivedFiles += $file
            } else {
     Write-Info "[DRY-RUN] Archivar: $file ? Fixes/"
            }
     Write-Log "Archivo archivado: $file ? Fixes/"
        }
        catch {
    Write-Error2 "Error al archivar $file : $_"
 $errors += "Error archivando $file : $_"
          Write-Log "ERROR: $file - $_"
        }
    }
}

Write-Header "FASE 6: ARCHIVAR GUÍAS DE IMPLEMENTACIÓN COMPLETADAS"

$guideDocs = @(
    "CREATE_SUPERADMIN_GUIDE.md",
    "CREATE_SUPERADMIN_SOLUTIONS.md",
    "IMPLEMENTATION_COMPLETE.md",
    "MIGRATION_SUMMARY.md",
    "EJECUTAR_MIGRACION_RAPIDO.md",
    "INSTRUCCIONES_FINALES_MIGRACION.md"
)

$guidesArchive = Join-Path $archiveFolder "Guides"
foreach ($file in $guideDocs) {
    $fullPath = Join-Path $projectRoot $file
    if (Test-Path $fullPath) {
 try {
  $destPath = Join-Path $guidesArchive $file
       if (-not $DryRun) {
      if ($CreateBackup) {
           $backupPath = Join-Path $backupFolder $file
      Copy-Item -Path $fullPath -Destination $backupPath -Force
  }
 Move-Item -Path $fullPath -Destination $destPath -Force
     Write-Success "Archivado: $file ? Guides/"
   $archivedFiles += $file
    } else {
      Write-Info "[DRY-RUN] Archivar: $file ? Guides/"
        }
        Write-Log "Archivo archivado: $file ? Guides/"
        }
 catch {
         Write-Error2 "Error al archivar $file : $_"
            $errors += "Error archivando $file : $_"
            Write-Log "ERROR: $file - $_"
      }
    }
}

# RESUMEN FINAL
Write-Header "RESUMEN DE OPERACIONES"

Write-Host ""
Write-Host "?? Estadísticas:" -ForegroundColor Cyan
Write-Host "   • Archivos eliminados: $($deletedFiles.Count)" -ForegroundColor White
Write-Host "   • Archivos archivados: $($archivedFiles.Count)" -ForegroundColor White
Write-Host "   • Errores: $($errors.Count)" -ForegroundColor $(if($errors.Count -gt 0){'Red'}else{'Green'})

if ($deletedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "???  Archivos eliminados:" -ForegroundColor Yellow
    foreach ($file in $deletedFiles) {
        Write-Host "   - $file" -ForegroundColor Gray
    }
}

if ($archivedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "?? Archivos archivados:" -ForegroundColor Cyan
 foreach ($file in $archivedFiles) {
        Write-Host "   - $file" -ForegroundColor Gray
    }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "? Errores encontrados:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "   - $error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "?? Log completo guardado en: $logFile" -ForegroundColor Cyan

if ($CreateBackup -and -not $DryRun -and (Test-Path $backupFolder)) {
    Write-Host "?? Backup creado en: $backupFolder" -ForegroundColor Green
}

Write-Host ""
if ($DryRun) {
    Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Yellow
    Write-Host "? SIMULACIÓN COMPLETADA - No se realizaron cambios" -ForegroundColor Yellow
    Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Para ejecutar los cambios reales, ejecuta:" -ForegroundColor Cyan
    Write-Host "   .\cleanup-project.ps1" -ForegroundColor White
} else {
    Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host "? LIMPIEZA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Green
}

Write-Host ""

# Return exit code
if ($errors.Count -gt 0) {
    exit 1
} else {
    exit 0
}
