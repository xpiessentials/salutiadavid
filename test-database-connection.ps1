# Script para probar conexión a base de datos SQL Server
# Soporta tanto local como remota

param(
    [Parameter(Mandatory=$false)]
    [string]$ServerInstance = "LAPTOP-DAVID\SQLEXPRESS",
    
    [Parameter(Mandatory=$false)]
    [string]$Database = "Salutia",
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "",
 
    [Parameter(Mandatory=$false)]
    [string]$Password = "",
    
    [Parameter(Mandatory=$false)]
  [switch]$UseWindowsAuth = $true
)

Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?   PRUEBA DE CONEXIÓN A BASE DE DATOS SQL SERVER    ?" -ForegroundColor Cyan
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Write-Host "?? Parámetros de conexión:" -ForegroundColor Yellow
Write-Host "   Servidor: $ServerInstance" -ForegroundColor White
Write-Host "   Base de datos: $Database" -ForegroundColor White
Write-Host "   Autenticación: $(if($UseWindowsAuth){'Windows'}else{'SQL Server'})" -ForegroundColor White
Write-Host ""

# Construir cadena de conexión
if ($UseWindowsAuth) {
    $connectionString = "Server=$ServerInstance;Database=$Database;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=15"
} else {
    if ([string]::IsNullOrEmpty($Username) -or [string]::IsNullOrEmpty($Password)) {
        Write-Host "? ERROR: Se requiere usuario y contraseña para autenticación SQL Server" -ForegroundColor Red
        exit 1
    }
    $connectionString = "Server=$ServerInstance;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;Encrypt=True;Connection Timeout=15"
}

Write-Host "?? Intentando conectar..." -ForegroundColor Yellow

try {
    # Crear conexión
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    
    # Intentar abrir la conexión
    $connection.Open()
    
    Write-Host "? CONEXIÓN EXITOSA!" -ForegroundColor Green
    Write-Host ""
    
    # Obtener información del servidor
    Write-Host "?? Información del servidor:" -ForegroundColor Cyan
    
    $command = $connection.CreateCommand()
    $command.CommandText = @"
        SELECT 
 @@VERSION as Version,
            @@SERVERNAME as ServerName,
            DB_NAME() as CurrentDatabase,
            SUSER_SNAME() as CurrentUser,
            GETDATE() as ServerTime
"@
    
    $reader = $command.ExecuteReader()
    
    if ($reader.Read()) {
      Write-Host "   Servidor: $($reader["ServerName"])" -ForegroundColor White
        Write-Host "   Base de datos: $($reader["CurrentDatabase"])" -ForegroundColor White
        Write-Host "   Usuario conectado: $($reader["CurrentUser"])" -ForegroundColor White
     Write-Host "   Hora del servidor: $($reader["ServerTime"])" -ForegroundColor White
        Write-Host ""
        Write-Host "   Versión: $($reader["Version"])" -ForegroundColor Gray
    }
    
    $reader.Close()
    
    # Verificar tablas principales
  Write-Host ""
    Write-Host "?? Verificando tablas principales..." -ForegroundColor Cyan
    
    $command.CommandText = @"
        SELECT 
   TABLE_NAME,
 (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = t.TABLE_NAME) as ColumnCount
        FROM INFORMATION_SCHEMA.TABLES t
  WHERE TABLE_TYPE = 'BASE TABLE'
        AND TABLE_NAME IN ('AspNetUsers', 'AspNetRoles', 'AspNetUserRoles', 
              'Entities', 'Professionals', 'Patients',
       'Departments', 'Cities')
        ORDER BY TABLE_NAME
"@
  
    $reader = $command.ExecuteReader()
    $tablesFound = 0
    
    while ($reader.Read()) {
        $tablesFound++
        Write-Host "   ? $($reader["TABLE_NAME"]) ($($reader["ColumnCount"]) columnas)" -ForegroundColor Green
    }
    
    $reader.Close()
    
    if ($tablesFound -eq 0) {
        Write-Host "   ?? No se encontraron las tablas principales. La base de datos puede estar vacía." -ForegroundColor Yellow
    }
    
    # Contar usuarios
    Write-Host ""
    Write-Host "?? Estadísticas de usuarios:" -ForegroundColor Cyan
    
    try {
 $command.CommandText = "SELECT COUNT(*) as UserCount FROM AspNetUsers"
        $userCount = $command.ExecuteScalar()
     Write-Host "   Total de usuarios: $userCount" -ForegroundColor White
        
        $command.CommandText = @"
  SELECT r.Name as RoleName, COUNT(ur.UserId) as UserCount
            FROM AspNetRoles r
        LEFT JOIN AspNetUserRoles ur ON r.Id = ur.RoleId
            GROUP BY r.Name
   ORDER BY r.Name
"@
     
   $reader = $command.ExecuteReader()
        
        if ($reader.HasRows) {
   Write-Host "   Usuarios por rol:" -ForegroundColor White
       while ($reader.Read()) {
      Write-Host "    - $($reader["RoleName"]): $($reader["UserCount"])" -ForegroundColor Gray
            }
        }
        
        $reader.Close()
    }
    catch {
        Write-Host "   ?? No se pudo obtener estadísticas de usuarios" -ForegroundColor Yellow
    }
    
    # Cerrar conexión
    $connection.Close()
    
    Write-Host ""
    Write-Host "????????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host "? PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host "????????????????????????????????????????????????????" -ForegroundColor Green
    
    exit 0
}
catch {
    Write-Host ""
 Write-Host "????????????????????????????????????????????????????" -ForegroundColor Red
    Write-Host "? ERROR DE CONEXIÓN" -ForegroundColor Red
    Write-Host "????????????????????????????????????????????????????" -ForegroundColor Red
    Write-Host ""
    Write-Host "Mensaje de error:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    Write-Host "?? Posibles soluciones:" -ForegroundColor Yellow
    Write-Host "   1. Verificar que el servidor esté accesible" -ForegroundColor White
    Write-Host "   2. Verificar que SQL Server esté iniciado" -ForegroundColor White
    Write-Host "   3. Verificar el nombre del servidor/instancia" -ForegroundColor White
    Write-Host "   4. Verificar las credenciales (si usa auth SQL)" -ForegroundColor White
    Write-Host "   5. Verificar el firewall y puertos (1433 para remoto)" -ForegroundColor White
    Write-Host "   6. Verificar que la base de datos exista" -ForegroundColor White
    Write-Host ""
    
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
    
    exit 1
}
