# ?? Migración a Base de Datos Local: Salutia-TBE

## ? Configuración Actualizada

**Servidor:** SQL Server Express Local (`LAPTOP-DAVID\SQLEXPRESS`)  
**Base de Datos:** `Salutia-TBE` (nueva, limpia)  
**Autenticación:** Windows (Trusted_Connection)

---

## ?? PASO 1: Verificar que la Base de Datos Existe

Ya creaste la BD `Salutia-TBE` en SQL Server Express. Vamos a verificarlo:

### En SQL Server Management Studio (SSMS):

```sql
-- Conectarse a LAPTOP-DAVID\SQLEXPRESS
-- Verificar que la BD existe
USE master
GO

SELECT 
    name AS 'Base de Datos',
    database_id,
    create_date AS 'Fecha Creación',
    state_desc AS 'Estado'
FROM sys.databases 
WHERE name = 'Salutia-TBE'
GO
```

**Resultado esperado:**
```
Base de Datos    database_id    Fecha Creación    Estado
Salutia-TBE      [número]       [fecha actual]    ONLINE
```

---

## ?? PASO 2: Aplicar Migraciones de EF Core

Ahora que `appsettings.json` apunta a la BD local, vamos a aplicar las migraciones.

### En Package Manager Console:

1. **Asegurar que la aplicación está detenida** (Shift + F5)

2. **Verificar proyecto seleccionado:**
   - Default project: `Salutia Wep App`

3. **Ejecutar migración:**
   ```powershell
   Update-Database -Verbose
   ```

**Esto creará todas las tablas en `Salutia-TBE`:**
- ? AspNetRoles, AspNetUsers (Identity)
- ? Countries, States, Cities (Geografía)
- ? **Entities** (Nueva tabla de empresas)
- ? **EntityUserProfiles** (Refactorizada - solo admins)
- ? EntityProfessionalProfiles
- ? PatientProfiles
- ? IndependentUserProfiles
- ? PsychosomaticTests y tablas relacionadas

---

## ?? PASO 3: Verificar Migración Exitosa

### En SSMS (conectado a SQLEXPRESS):

```sql
USE [Salutia-TBE]
GO

-- 1. Ver todas las tablas creadas
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME
GO

-- 2. Verificar tabla Entities (nueva)
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Entities'
ORDER BY ORDINAL_POSITION
GO

-- 3. Verificar tabla EntityUserProfiles (refactorizada)
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EntityUserProfiles'
ORDER BY ORDINAL_POSITION
GO

-- 4. Ver migraciones aplicadas
SELECT * FROM __EFMigrationsHistory
ORDER BY MigrationId DESC
GO

-- 5. Contar tablas creadas
SELECT COUNT(*) AS 'Total Tablas' 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
GO
```

**Resultado esperado:**
- **Total Tablas:** ~25+ tablas
- **__EFMigrationsHistory:** Debe incluir `AddEntityTableAndRefactorRelations`

---

## ?? PASO 4: Insertar Datos Iniciales (Opcional)

Si necesitas roles y datos base:

```sql
USE [Salutia-TBE]
GO

-- Verificar si hay roles
SELECT COUNT(*) AS 'Total Roles' FROM AspNetRoles
GO

-- Si no hay roles, la aplicación los creará automáticamente
-- al iniciar por primera vez
```

---

## ?? PASO 5: Iniciar la Aplicación

1. En Visual Studio, presiona **F5**
2. La app se conectará a `Salutia-TBE` local
3. Todo debería funcionar correctamente

---

## ? Verificación de Funcionamiento

### Probar Funcionalidades:

1. **Registro de Entidad:**
   - `/Account/RegisterEntity`
   - Debe crear una `Entity` y un `EntityUserProfile` asociado

2. **Dashboard de Entity:**
   - `/Entity/Dashboard`
   - Debe cargar información de la empresa desde `Entity`

3. **Agregar Profesional:**
   - `/Entity/AddProfessional`
   - Debe funcionar sin error "Invalid object name 'Entities'"

4. **Dashboard de Admin:**
   - `/Admin/Entities`
   - Debe listar todas las entities correctamente

---

## ?? Comparación de Configuraciones

| Aspecto | Antes (AWS) | Ahora (Local) |
|---------|-------------|---------------|
| **Servidor** | `3.150.156.25,4096` | `LAPTOP-DAVID\SQLEXPRESS` |
| **Base de Datos** | `Salutia-TBE` | `Salutia-TBE` |
| **Autenticación** | SQL Server (`sa`/`password`) | Windows (Trusted_Connection) |
| **Puerto** | 4096 | Default (1433) |
| **Encrypt** | False | No especificado (default) |
| **Timeout** | 120 seg | Default (15 seg) |

---

## ?? Si Hay Errores Durante Update-Database

### Error: "Cannot open database 'Salutia-TBE'"

**Solución:** Verificar que la BD existe en SSMS.

```sql
-- Crear BD si no existe
USE master
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Salutia-TBE')
BEGIN
    CREATE DATABASE [Salutia-TBE]
END
GO
```

---

### Error: "A network-related error occurred"

**Solución:** Verificar que SQL Server Express está corriendo.

```powershell
# En PowerShell (como administrador)
Get-Service -Name MSSQL*

# Si está detenido, iniciarlo
Start-Service -Name 'MSSQL$SQLEXPRESS'
```

---

### Error: "Login failed for user 'LAPTOP-DAVID\Usuario'"

**Solución:** Verificar permisos del usuario de Windows.

```sql
-- En SSMS
USE master
GO

-- Agregar login si no existe
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'LAPTOP-DAVID\[TuUsuario]')
BEGIN
    CREATE LOGIN [LAPTOP-DAVID\[TuUsuario]] FROM WINDOWS
END
GO

-- Dar permisos dbcreator
ALTER SERVER ROLE dbcreator ADD MEMBER [LAPTOP-DAVID\[TuUsuario]]
GO
```

---

## ?? Estructura Final de Salutia-TBE

```
Salutia-TBE (Local SQL Express)
??? AspNetRoles
??? AspNetUsers
??? Countries, States, Cities
??? Entities ? Nueva tabla (empresas)
?   ??? Relaciones:
?       ??? EntityUserProfiles (administradores)
?       ??? EntityProfessionalProfiles (médicos/psicólogos)
?       ??? PatientProfiles (pacientes)
??? IndependentUserProfiles
??? PsychosomaticTests
??? Test* (Words, Phrases, Emotions, etc.)
```

---

## ?? Comandos Rápidos

```powershell
# ============================================
# Package Manager Console
# ============================================

# Ver migraciones
Get-Migration

# Aplicar migración
Update-Database -Verbose

# Si hay error, ver más detalles
Update-Database -Verbose -ErrorAction Continue
```

```sql
-- ============================================
-- SQL Server Management Studio
-- ============================================

-- Verificar BD
USE master
SELECT name FROM sys.databases WHERE name = 'Salutia-TBE'

-- Ver tablas
USE [Salutia-TBE]
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'

-- Ver datos en Entities
SELECT * FROM Entities
SELECT * FROM EntityUserProfiles
```

---

## ? Checklist de Migración

- [x] `appsettings.json` actualizado a SQL Express local
- [ ] BD `Salutia-TBE` existe en SSMS
- [ ] Aplicación detenida (Shift + F5)
- [ ] `Update-Database -Verbose` ejecutado exitosamente
- [ ] Todas las tablas creadas (verificar en SSMS)
- [ ] Migración registrada en `__EFMigrationsHistory`
- [ ] Aplicación inicia sin errores
- [ ] Funcionalidades probadas (registro, dashboards, etc.)

---

## ?? Siguiente Paso

**Ejecuta en Package Manager Console:**

```powershell
Update-Database -Verbose
```

Esto aplicará la migración `AddEntityTableAndRefactorRelations` y creará todas las tablas con la nueva arquitectura en la base de datos local `Salutia-TBE`.

---

**Estado:** ? Configuración revertida a SQL Express local  
**Base de Datos:** Salutia-TBE (nueva, limpia)  
**Listo para:** Migración de EF Core

Dime cuando hayas ejecutado `Update-Database` y te ayudo a verificar que todo esté correcto. ??
