# Script para cambiar la contraseña del SuperAdmin
# Usuario: elpeco1@msn.com

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CAMBIO DE CONTRASEÑA SUPERADMIN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar la nueva contraseña
$newPassword = Read-Host "Ingresa la nueva contraseña para el SuperAdmin" -AsSecureString
$confirmPassword = Read-Host "Confirma la nueva contraseña" -AsSecureString

# Convertir a texto plano para comparar
$newPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword)
)
$confirmPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword)
)

if ($newPasswordText -ne $confirmPasswordText) {
    Write-Host "ERROR: Las contraseñas no coinciden" -ForegroundColor Red
    exit 1
}

# Validar requisitos de contraseña
if ($newPasswordText.Length -lt 6) {
    Write-Host "ERROR: La contraseña debe tener al menos 6 caracteres" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Generando hash de contraseña seguro..." -ForegroundColor Yellow

# Crear el hash usando la API de ASP.NET Core Identity
$projectPath = "Salutia Wep App"

# Verificar que el proyecto existe
if (-not (Test-Path $projectPath)) {
    Write-Host "ERROR: No se encuentra el proyecto en: $projectPath" -ForegroundColor Red
    exit 1
}

# Crear un pequeño programa C# para generar el hash
$tempCsFile = "TempPasswordHasher.cs"
$tempCode = @"
using Microsoft.AspNetCore.Identity;
using System;

public class Program
{
    public static void Main(string[] args)
    {
        if (args.Length == 0)
     {
            Console.WriteLine("ERROR: No se proporcionó contraseña");
            return;
      }

   var hasher = new PasswordHasher<object>();
        var hash = hasher.HashPassword(null, args[0]);
        Console.WriteLine(hash);
    }
}
"@

Set-Content -Path $tempCsFile -Value $tempCode

# Compilar y ejecutar el programa para obtener el hash
try {
    $output = dotnet script eval $tempCode -- $newPasswordText 2>&1
    
    # Alternativa: usar una pequeña app de consola
    if ($LASTEXITCODE -ne 0) {
    Write-Host "Generando hash alternativo..." -ForegroundColor Yellow
        
        # Crear proyecto temporal
     $tempDir = "TempPasswordHasher"
      if (Test-Path $tempDir) {
     Remove-Item $tempDir -Recurse -Force
        }
        
        dotnet new console -n $tempDir -o $tempDir | Out-Null
        
        $programCs = @"
using Microsoft.AspNetCore.Identity;

var hasher = new PasswordHasher<object>();
var hash = hasher.HashPassword(null, args[0]);
Console.WriteLine(hash);
"@
        
        Set-Content -Path "$tempDir/Program.cs" -Value $programCs
        
    # Agregar paquete de Identity
        Push-Location $tempDir
        dotnet add package Microsoft.AspNetCore.Identity --version 8.0.0 | Out-Null
        
   # Ejecutar y obtener el hash
        $passwordHash = dotnet run -- $newPasswordText
        Pop-Location
        
 # Limpiar
        Remove-Item $tempDir -Recurse -Force
    }
    else {
        $passwordHash = $output
    }
}
catch {
    Write-Host "ERROR generando el hash: $_" -ForegroundColor Red
    exit 1
}
finally {
    if (Test-Path $tempCsFile) {
        Remove-Item $tempCsFile
    }
}

if ([string]::IsNullOrWhiteSpace($passwordHash)) {
    Write-Host "ERROR: No se pudo generar el hash de contraseña" -ForegroundColor Red
    exit 1
}

Write-Host "Hash generado exitosamente" -ForegroundColor Green
Write-Host ""

# Connection string
$connectionString = "Server=LAPTOP-DAVID\SQLEXPRESS;Database=Salutia;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"

Write-Host "Conectando a la base de datos..." -ForegroundColor Yellow

try {
    # Cargar el ensamblado de SQL Client
    Add-Type -AssemblyName "System.Data"
    
    # Crear conexión
    $connection = New-Object System.Data.SqlClient.SqlConnection
 $connection.ConnectionString = $connectionString
    $connection.Open()
    
 Write-Host "Conexión establecida" -ForegroundColor Green
    
    # Actualizar la contraseña del superadmin
    $query = @"
UPDATE AspNetUsers 
SET PasswordHash = @PasswordHash,
    SecurityStamp = NEWID(),
    ConcurrencyStamp = NEWID()
WHERE LOWER(Email) = 'elpeco1@msn.com' 
   OR LOWER(UserName) = 'elpeco1@msn.com'
   OR LOWER(NormalizedEmail) = 'ELPECO1@MSN.COM'
   OR LOWER(NormalizedUserName) = 'ELPECO1@MSN.COM';

SELECT @@ROWCOUNT as RowsAffected;
"@
    
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.Parameters.AddWithValue("@PasswordHash", $passwordHash) | Out-Null
    
    Write-Host "Actualizando contraseña..." -ForegroundColor Yellow
    
    $rowsAffected = $command.ExecuteScalar()
    
    if ($rowsAffected -gt 0) {
        Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
Write-Host "  ¡CONTRASEÑA ACTUALIZADA!" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Usuario: elpeco1@msn.com" -ForegroundColor Cyan
        Write-Host "Nueva contraseña: [la que ingresaste]" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Ahora puedes iniciar sesión con la nueva contraseña" -ForegroundColor Green
    }
    else {
      Write-Host ""
        Write-Host "ADVERTENCIA: No se encontró el usuario SuperAdmin" -ForegroundColor Yellow
        Write-Host "Verifica que el usuario existe en la base de datos" -ForegroundColor Yellow
        
        # Verificar si existe algún usuario
        $checkQuery = "SELECT COUNT(*) FROM AspNetUsers"
      $checkCmd = $connection.CreateCommand()
        $checkCmd.CommandText = $checkQuery
 $userCount = $checkCmd.ExecuteScalar()
        
        Write-Host "Usuarios en la base de datos: $userCount" -ForegroundColor Yellow
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
 Write-Host $_.Exception.Message -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
