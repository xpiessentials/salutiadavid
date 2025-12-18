# ?? Solución de Problemas - Migración Test Psicosomático

## ? Error Actual

```
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login failed for user 'LAPTOP-DAVID\elpec'..
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Cannot open database "Salutia" requested by the login. The login failed..
```

## ?? Causas del Error

1. **La base de datos `Salutia` no existe**
2. **El usuario Windows no tiene permisos**
3. **LocalDB no está iniciado**

---

## ? Solución 1: Script Mejorado (Recomendado)

Ejecuta el nuevo script que soluciona automáticamente estos problemas:

```powershell
.\fix-and-apply-migration.ps1
```

Este script:
- ? Verifica e inicia LocalDB
- ? Crea la base de datos si no existe
- ? Ejecuta la migración
- ? Verifica las tablas creadas

---

## ? Solución 2: Script Simple

Si el anterior no funciona, prueba:

```powershell
.\simple-migration.ps1
```

---

## ? Solución 3: Pasos Manuales

### Paso 1: Iniciar LocalDB

```powershell
# Ver instancias disponibles
sqllocaldb info

# Iniciar LocalDB
sqllocaldb start MSSQLLocalDB

# Verificar que está corriendo
sqllocaldb info MSSQLLocalDB
```

**Resultado esperado:**
```
Name:        MSSQLLocalDB
Version:    [versión]
Shared name:
Owner:              LAPTOP-DAVID\elpec
Auto-create:      Yes
State: Running
```

### Paso 2: Crear la Base de Datos

**Opción A: Con sqlcmd**

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "CREATE DATABASE Salutia"
```

**Opción B: Con SQL Server Management Studio (SSMS)**

1. Abrir SSMS
2. Conectar a: `(localdb)\MSSQLLocalDB`
3. Clic derecho en "Databases" ? "New Database"
4. Nombre: `Salutia`
5. Clic en "OK"

### Paso 3: Verificar la Base de Datos

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "SELECT name FROM sys.databases WHERE name = 'Salutia'"
```

**Resultado esperado:**
```
name
----------
Salutia
```

### Paso 4: Ejecutar la Migración

```powershell
cd D:\Desarrollos\Repos\Salutia\
sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -E -i ".\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"
```

### Paso 5: Verificar las Tablas

```powershell
$verifyQuery = @"
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'
ORDER BY TABLE_NAME;
"@

$verifyQuery | sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -E -h -1 -W
```

**Resultado esperado:**
```
PsychosomaticTests
TestAssociatedPersons
TestBodyParts
TestDiscomfortLevels
TestEmotions
TestMatrices
TestPhrases
TestWords
```

---

## ? Solución 4: Desde SQL Server Management Studio (SSMS)

Si tienes SSMS instalado:

### 1. Conectar a LocalDB

```
Servidor: (localdb)\MSSQLLocalDB
Autenticación: Windows Authentication
```

### 2. Crear la Base de Datos

```sql
CREATE DATABASE Salutia;
GO
```

### 3. Abrir y Ejecutar el Script

1. File ? Open ? File
2. Navegar a: `D:\Desarrollos\Repos\Salutia\Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql`
3. Asegurarse de que está seleccionada la BD `Salutia` en el dropdown
4. Presionar F5 o clic en "Execute"

### 4. Verificar

```sql
USE Salutia;
GO

SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests'
ORDER BY TABLE_NAME;
GO
```

---

## ?? Diagnóstico de Problemas

### LocalDB no Responde

```powershell
# Detener
sqllocaldb stop MSSQLLocalDB

# Eliminar instancia corrupta (si es necesario)
sqllocaldb delete MSSQLLocalDB

# Crear nueva instancia
sqllocaldb create MSSQLLocalDB

# Iniciar
sqllocaldb start MSSQLLocalDB
```

### Error de Permisos

LocalDB usa automáticamente tu usuario de Windows. Si tienes problemas:

1. Verifica que eres administrador local
2. Ejecuta PowerShell como Administrador
3. Reinicia LocalDB

### Base de Datos No Accesible

```sql
-- Verificar estado de la BD
SELECT name, state_desc, user_access_desc 
FROM sys.databases 
WHERE name = 'Salutia';

-- Si está OFFLINE, ponerla ONLINE
ALTER DATABASE Salutia SET ONLINE;
GO
```

---

## ?? Verificación Final

Una vez completada la migración, verifica con:

```powershell
# Ver todas las tablas creadas
$query = @"
USE Salutia;
SELECT 
    t.TABLE_NAME AS [Tabla],
    COUNT(c.COLUMN_NAME) AS [Columnas]
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_NAME LIKE 'Test%' OR t.TABLE_NAME = 'PsychosomaticTests'
GROUP BY t.TABLE_NAME
ORDER BY t.TABLE_NAME;
"@

$query | sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia" -E -W
```

**Resultado esperado:**

| Tabla | Columnas |
|-------|----------|
| PsychosomaticTests | 5 |
| TestAssociatedPersons | 5 |
| TestBodyParts | 5 |
| TestDiscomfortLevels | 5 |
| TestEmotions | 5 |
| TestMatrices | 9 |
| TestPhrases | 5 |
| TestWords | 5 |

---

## ?? Siguiente Paso

Una vez que la migración sea exitosa:

```powershell
# Compilar
dotnet build

# Ejecutar
dotnet run --project ".\Salutia Wep App\Salutia Wep App.csproj"
```

Luego navegar a: `https://localhost:[puerto]/test-psicosomatico`

---

## ?? Si Nada Funciona

**Opción 1: Usar SQL Server Express en lugar de LocalDB**

1. Descargar SQL Server Express
2. Instalar con opciones predeterminadas
3. Cambiar connection string en `appsettings.json`:

```json
"ConnectionStrings": {
    "sqlserver": "Server=localhost\\SQLEXPRESS;Database=Salutia;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

**Opción 2: Ejecutar desde Entity Framework**

```powershell
# Instalar herramienta EF (si no la tienes)
dotnet tool install --global dotnet-ef

# Crear migración
cd ".\Salutia Wep App\"
dotnet ef migrations add AddPsychosomaticTest

# Aplicar migración
dotnet ef database update
```

---

## ? Checklist de Verificación

- [ ] LocalDB está instalado
- [ ] LocalDB está corriendo (`sqllocaldb info MSSQLLocalDB`)
- [ ] Base de datos `Salutia` existe
- [ ] Script SQL existe en la ruta correcta
- [ ] Estás en el directorio raíz del proyecto
- [ ] Tienes permisos de administrador
- [ ] Las 8 tablas fueron creadas exitosamente

---

**Una vez que funcione, ejecuta:**

```powershell
.\fix-and-apply-migration.ps1
```

o

```powershell
.\simple-migration.ps1
```
