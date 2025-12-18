# ??? Nueva Arquitectura: Sistema de Entidades Refactorizado

## ?? Resumen de Cambios

Se ha refactorizado completamente el sistema para tener una tabla **`Entities`** independiente que representa empresas/organizaciones, y múltiples usuarios administradores por entidad.

---

## ??? Nueva Estructura de Base de Datos

### Tabla Principal: **Entities**

```sql
CREATE TABLE [dbo].[Entities] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [BusinessName] NVARCHAR(300) NOT NULL,
    [TaxId] NVARCHAR(20) NOT NULL,
    [VerificationDigit] NVARCHAR(1) NOT NULL,
    [Phone] NVARCHAR(20) NOT NULL,
    [Email] NVARCHAR(256) NOT NULL,
    [Address] NVARCHAR(500) NULL,
    [Website] NVARCHAR(200) NULL,
    [LegalRepresentative] NVARCHAR(200) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    
    CONSTRAINT [UQ_Entities_TaxId] UNIQUE ([TaxId]),
    CONSTRAINT [UQ_Entities_Email] UNIQUE ([Email])
)
```

**Propósito:** 
- Almacena información de empresas/organizaciones
- Una entidad puede tener múltiples administradores
- Centraliza la información de la empresa

---

### Tabla Modificada: **EntityUserProfiles** (Ahora solo Administradores)

**ANTES:**
```sql
EntityUserProfiles
??? Contenía información de la empresa
??? Un perfil = Una empresa
??? Un usuario = Una empresa
```

**DESPUÉS:**
```sql
EntityUserProfiles
??? Solo es administrador
??? Referencia a Entity (EntityId)
??? Múltiples administradores por Entity
??? Un usuario puede administrar UNA entidad
```

**Cambios en la tabla:**
```sql
ALTER TABLE [dbo].[EntityUserProfiles]
ADD [EntityId] INT NOT NULL,
    [FullName] NVARCHAR(200) NOT NULL,
    [Position] NVARCHAR(100) NULL,
    [DirectPhone] NVARCHAR(20) NULL,
    [JoinedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [IsActive] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [FK_EntityUserProfiles_Entities] FOREIGN KEY ([EntityId]) 
        REFERENCES [dbo].[Entities]([Id]) ON DELETE NO ACTION
GO

-- Eliminar columnas que ahora están en Entities
ALTER TABLE [dbo].[EntityUserProfiles]
DROP COLUMN [BusinessName],
    [TaxId],
    [VerificationDigit],
    [Website],
    [LegalRepresentative],
    [CountryId],
    [StateId],
    [CityId],
    [Address]
GO

-- Agregar índice único
CREATE UNIQUE INDEX [IX_EntityUserProfiles_EntityId_ApplicationUserId]
ON [dbo].[EntityUserProfiles] ([EntityId], [ApplicationUserId])
GO
```

---

### Tabla Modificada: **EntityProfessionalProfiles**

**Cambios:**
```sql
-- Ahora referencia directamente a Entity en lugar de EntityUserProfile
ALTER TABLE [dbo].[EntityProfessionalProfiles]
DROP CONSTRAINT [FK_EntityProfessionalProfiles_EntityUserProfiles]
GO

-- Agregar referencia a Entity
ALTER TABLE [dbo].[EntityProfessionalProfiles]
ADD CONSTRAINT [FK_EntityProfessionalProfiles_Entities] FOREIGN KEY ([EntityId]) 
    REFERENCES [dbo].[Entities]([Id]) ON DELETE NO ACTION
GO
```

---

### Tabla Modificada: **PatientProfiles**

**Cambios:**
```sql
-- Agregar EntityId para asociar pacientes directamente a la entidad
ALTER TABLE [dbo].[PatientProfiles]
ADD [EntityId] INT NULL,
    CONSTRAINT [FK_PatientProfiles_Entities] FOREIGN KEY ([EntityId]) 
        REFERENCES [dbo].[Entities]([Id]) ON DELETE NO ACTION
GO

-- Crear índice
CREATE INDEX [IX_PatientProfiles_EntityId]
ON [dbo].[PatientProfiles] ([EntityId])
GO
```

---

## ?? Diagrama de Relaciones

```
???????????????
?  Entities   ? ??????????
???????????????          ?
       ?                 ?
       ?                 ?
       ? EntityId        ? EntityId
       ?                 ?
????????????????????????????????????
?                                  ?
?????????????????????????  ???????????????????????????
? EntityUserProfiles    ?  ? EntityProfessionalProfiles?
? (Administradores)     ?  ? (Médicos/Psicólogos)       ?
?????????????????????????  ???????????????????????????
                                    ?
                                    ? ProfessionalId
                                    ?
                           ???????????????????????
                           ? PatientProfiles      ?
                           ? (Pacientes)          ?
                           ???????????????????????
                                    ?
                                    ? EntityId (opcional)
                                    ?
                           ???????????????????
                           ?  Entities       ?
                           ???????????????????
```

---

## ?? Flujo de Registro Actualizado

### 1. **Registro de Nueva Entidad** (`/Account/RegisterEntity`)

```
Usuario completa formulario
    ?
1. Crear registro en Entities
    ??? BusinessName
    ??? TaxId + VerificationDigit
    ??? Email
    ??? Phone
    ??? LegalRepresentative
    ?
2. Crear ApplicationUser
    ??? UserType = EntityAdmin
    ??? Email (del formulario)
    ??? Password
    ?
3. Crear EntityUserProfile
    ??? ApplicationUserId
    ??? EntityId (del paso 1)
    ??? FullName (del usuario)
    ??? Position = "Administrador Principal"
    ??? IsActive = true
    ?
4. Asignar rol "EntityAdmin"
```

### 2. **EntityAdmin Agrega Nuevo Administrador**

```
EntityAdmin autenticado
    ?
Obtener EntityId del perfil
    ?
Formulario: Email, FullName, Position
    ?
1. Crear ApplicationUser
    ??? UserType = EntityAdmin
    ??? Email
    ??? Password temporal
    ?
2. Crear EntityUserProfile
    ??? ApplicationUserId
    ??? EntityId (del admin actual)
    ??? FullName
    ??? Position
    ??? IsActive = true
    ?
3. Asignar rol "EntityAdmin"
```

### 3. **EntityAdmin Agrega Profesional**

```
EntityAdmin autenticado
    ?
Obtener EntityId del perfil
    ?
Formulario: Datos del profesional
    ?
1. Crear ApplicationUser
    ??? UserType = Doctor/Psychologist
    ??? Credenciales
    ?
2. Crear EntityProfessionalProfile
    ??? ApplicationUserId
    ??? EntityId (del admin)
    ??? FullName
    ??? DocumentType/Number
    ??? Specialty
    ??? ProfessionalLicense
    ?
3. Asignar rol "Doctor" o "Psychologist"
```

### 4. **Profesional Registra Paciente**

```
Professional autenticado
    ?
Obtener ProfessionalId y EntityId
    ?
Formulario: DocumentType, DocumentNumber, Email
    ?
1. Crear ApplicationUser
    ??? UserType = Patient
    ??? UserName = DocumentNumber
    ??? Password = DocumentNumber
    ?
2. Crear PatientProfile
    ??? ApplicationUserId
    ??? ProfessionalId (del profesional)
    ??? EntityId (de la entidad del profesional)
    ??? DocumentType/Number
    ??? Email
    ??? IsEntityPatient = true
    ??? ProfileCompleted = false
    ?
3. Asignar rol "Patient"
```

---

## ?? Reglas de Seguridad Actualizadas

### SuperAdmin
- ? Gestiona **todas las entidades**
- ? Crea nuevas entidades
- ? Asigna administradores a entidades
- ? Ve todos los profesionales y pacientes

### EntityAdmin
- ? Gestiona **su entidad**
- ? Agrega **otros administradores** a su entidad
- ? Gestiona profesionales de su entidad
- ? Ve todos los pacientes de su entidad
- ? NO puede ver/modificar otras entidades

**Validación en código:**
```csharp
// Obtener EntityId del usuario actual
var entityProfile = await DbContext.EntityUserProfiles
    .FirstOrDefaultAsync(e => e.ApplicationUserId == currentUserId);

var entityId = entityProfile.EntityId;

// Solo cargar datos de SU entidad
var professionals = await DbContext.EntityProfessionalProfiles
    .Where(p => p.EntityId == entityId)
    .ToListAsync();
```

### Professional
- ? Registra pacientes para su entidad
- ? Gestiona **solo sus pacientes**
- ? NO ve pacientes de otros profesionales
- ? NO gestiona la entidad

**Validación en código:**
```csharp
var professionalProfile = await DbContext.EntityProfessionalProfiles
    .FirstOrDefaultAsync(p => p.ApplicationUserId == currentUserId);

// Al crear paciente, asignar EntityId del profesional
var patient = new PatientProfile
{
    ProfessionalId = professionalProfile.Id,
    EntityId = professionalProfile.EntityId, // ? Heredado
    // ...
};
```

---

## ?? Script SQL Completo de Migración

```sql
USE [Salutia]
GO

BEGIN TRANSACTION
GO

-- ========================================
-- 1. CREAR TABLA ENTITIES
-- ========================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Entities')
BEGIN
    CREATE TABLE [dbo].[Entities] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [BusinessName] NVARCHAR(300) NOT NULL,
        [TaxId] NVARCHAR(20) NOT NULL,
        [VerificationDigit] NVARCHAR(1) NOT NULL,
        [Phone] NVARCHAR(20) NOT NULL,
        [Email] NVARCHAR(256) NOT NULL,
        [Address] NVARCHAR(500) NULL,
        [Website] NVARCHAR(200) NULL,
        [LegalRepresentative] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2 NULL,
        
        CONSTRAINT [UQ_Entities_TaxId] UNIQUE ([TaxId]),
        CONSTRAINT [UQ_Entities_Email] UNIQUE ([Email])
    )
    
    PRINT '? Tabla Entities creada'
END
ELSE
BEGIN
    PRINT '? Tabla Entities ya existe'
END
GO

-- ========================================
-- 2. MIGRAR DATOS EXISTENTES
-- ========================================

-- Insertar entidades existentes desde EntityUserProfiles
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Entities')
AND EXISTS (SELECT * FROM sys.tables WHERE name = 'EntityUserProfiles')
BEGIN
    -- Verificar si hay datos para migrar
    IF EXISTS (SELECT 1 FROM [dbo].[EntityUserProfiles])
    BEGIN
        INSERT INTO [dbo].[Entities] (
            [BusinessName],
            [TaxId],
            [VerificationDigit],
            [Phone],
            [Email],
            [Address],
            [Website],
            [LegalRepresentative],
            [IsActive],
            [CreatedAt]
        )
        SELECT DISTINCT
            e.[BusinessName],
            e.[TaxId],
            e.[VerificationDigit],
            e.[Phone],
            u.[Email], -- Email del usuario ApplicationUser
            e.[Address],
            e.[Website],
            e.[LegalRepresentative],
            1 AS [IsActive],
            u.[CreatedAt]
        FROM [dbo].[EntityUserProfiles] e
        INNER JOIN [dbo].[AspNetUsers] u ON e.[ApplicationUserId] = u.[Id]
        WHERE NOT EXISTS (
            SELECT 1 FROM [dbo].[Entities] ent 
            WHERE ent.[TaxId] = e.[TaxId]
        )
        
        PRINT '? Datos migrados a Entities'
    END
    ELSE
    BEGIN
        PRINT '? No hay datos para migrar'
    END
END
GO

-- ========================================
-- 3. AGREGAR ENTITYID A ENTITYUSERPROFILES
-- ========================================

-- Agregar columna temporal EntityId
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
               AND name = 'EntityId')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD [EntityId] INT NULL
    
    PRINT '? Columna EntityId agregada a EntityUserProfiles'
END
GO

-- Actualizar EntityId con valores de Entities
UPDATE eup
SET eup.[EntityId] = ent.[Id]
FROM [dbo].[EntityUserProfiles] eup
INNER JOIN [dbo].[Entities] ent ON eup.[TaxId] = ent.[TaxId]
WHERE eup.[EntityId] IS NULL
GO

-- Hacer EntityId NOT NULL
ALTER TABLE [dbo].[EntityUserProfiles]
ALTER COLUMN [EntityId] INT NOT NULL
GO

-- Agregar FK
IF NOT EXISTS (SELECT * FROM sys.foreign_keys 
               WHERE name = 'FK_EntityUserProfiles_Entities')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD CONSTRAINT [FK_EntityUserProfiles_Entities] 
        FOREIGN KEY ([EntityId]) 
        REFERENCES [dbo].[Entities]([Id])
    
    PRINT '? FK EntityUserProfiles ? Entities creada'
END
GO

-- ========================================
-- 4. AGREGAR NUEVAS COLUMNAS A ENTITYUSERPROFILES
-- ========================================

-- FullName
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
               AND name = 'FullName')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD [FullName] NVARCHAR(200) NULL
    
    -- Poblar con datos de AspNetUsers
    UPDATE eup
    SET eup.[FullName] = u.[UserName]
    FROM [dbo].[EntityUserProfiles] eup
    INNER JOIN [dbo].[AspNetUsers] u ON eup.[ApplicationUserId] = u.[Id]
    WHERE eup.[FullName] IS NULL
    
    -- Hacer NOT NULL
    ALTER TABLE [dbo].[EntityUserProfiles]
    ALTER COLUMN [FullName] NVARCHAR(200) NOT NULL
    
    PRINT '? Columna FullName agregada'
END
GO

-- Position
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
               AND name = 'Position')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD [Position] NVARCHAR(100) NULL
    
    UPDATE [dbo].[EntityUserProfiles]
    SET [Position] = 'Administrador Principal'
    WHERE [Position] IS NULL
    
    PRINT '? Columna Position agregada'
END
GO

-- DirectPhone
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
               AND name = 'DirectPhone')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD [DirectPhone] NVARCHAR(20) NULL
    
    -- Copiar desde Phone existente
    UPDATE [dbo].[EntityUserProfiles]
    SET [DirectPhone] = [Phone]
    WHERE [DirectPhone] IS NULL AND [Phone] IS NOT NULL
    
    PRINT '? Columna DirectPhone agregada'
END
GO

-- JoinedAt
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
               AND name = 'JoinedAt')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD [JoinedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    
    PRINT '? Columna JoinedAt agregada'
END
GO

-- IsActive
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
               AND name = 'IsActive')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles]
    ADD [IsActive] BIT NOT NULL DEFAULT 1
    
    PRINT '? Columna IsActive agregada'
END
GO

-- ========================================
-- 5. ELIMINAR COLUMNAS REDUNDANTES
-- ========================================

-- Eliminar columnas que ahora están en Entities
DECLARE @sql NVARCHAR(MAX)

-- BusinessName
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'BusinessName')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [BusinessName]
    PRINT '? Columna BusinessName eliminada'
END

-- TaxId
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'TaxId')
BEGIN
    -- Primero eliminar el índice único
    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EntityUserProfiles_TaxId')
    BEGIN
        DROP INDEX [IX_EntityUserProfiles_TaxId] ON [dbo].[EntityUserProfiles]
    END
    
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [TaxId]
    PRINT '? Columna TaxId eliminada'
END

-- VerificationDigit
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'VerificationDigit')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [VerificationDigit]
    PRINT '? Columna VerificationDigit eliminada'
END

-- Website
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'Website')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [Website]
    PRINT '? Columna Website eliminada'
END

-- LegalRepresentative
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'LegalRepresentative')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [LegalRepresentative]
    PRINT '? Columna LegalRepresentative eliminada'
END

-- Phone (se reemplaza por DirectPhone)
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'Phone')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [Phone]
    PRINT '? Columna Phone eliminada'
END

-- Campos geográficos (ahora en Entities si se necesitan)
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'CountryId')
BEGIN
    -- Eliminar FKs primero
    DECLARE @fkName NVARCHAR(255)
    
    SELECT @fkName = fk.name
    FROM sys.foreign_keys fk
    WHERE fk.parent_object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]')
    AND COL_NAME(fk.parent_object_id, (SELECT column_id FROM sys.foreign_key_columns WHERE constraint_object_id = fk.object_id)) = 'CountryId'
    
    IF @fkName IS NOT NULL
    BEGIN
        SET @sql = 'ALTER TABLE [dbo].[EntityUserProfiles] DROP CONSTRAINT [' + @fkName + ']'
        EXEC sp_executesql @sql
    END
    
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [CountryId]
    PRINT '? Columna CountryId eliminada'
END

-- StateId
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'StateId')
BEGIN
    SELECT @fkName = fk.name
    FROM sys.foreign_keys fk
    WHERE fk.parent_object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]')
    AND COL_NAME(fk.parent_object_id, (SELECT column_id FROM sys.foreign_key_columns WHERE constraint_object_id = fk.object_id)) = 'StateId'
    
    IF @fkName IS NOT NULL
    BEGIN
        SET @sql = 'ALTER TABLE [dbo].[EntityUserProfiles] DROP CONSTRAINT [' + @fkName + ']'
        EXEC sp_executesql @sql
    END
    
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [StateId]
    PRINT '? Columna StateId eliminada'
END

-- CityId
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'CityId')
BEGIN
    SELECT @fkName = fk.name
    FROM sys.foreign_keys fk
    WHERE fk.parent_object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]')
    AND COL_NAME(fk.parent_object_id, (SELECT column_id FROM sys.foreign_key_columns WHERE constraint_object_id = fk.object_id)) = 'CityId'
    
    IF @fkName IS NOT NULL
    BEGIN
        SET @sql = 'ALTER TABLE [dbo].[EntityUserProfiles] DROP CONSTRAINT [' + @fkName + ']'
        EXEC sp_executesql @sql
    END
    
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [CityId]
    PRINT '? Columna CityId eliminada'
END

-- Address
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'Address')
BEGIN
    ALTER TABLE [dbo].[EntityUserProfiles] DROP COLUMN [Address]
    PRINT '? Columna Address eliminada'
END
GO

-- ========================================
-- 6. ACTUALIZAR ENTITYPROFESSIONALPROFILES
-- ========================================

-- Actualizar FK para que apunte a Entities en lugar de EntityUserProfiles
-- Primero, poblar EntityId en EntityProfessionalProfiles desde EntityUserProfiles

IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityProfessionalProfiles]') 
           AND name = 'EntityId')
BEGIN
    -- Actualizar EntityId basado en la entidad del EntityUserProfile actual
    UPDATE ep
    SET ep.[EntityId] = eup.[EntityId]
    FROM [dbo].[EntityProfessionalProfiles] ep
    INNER JOIN [dbo].[EntityUserProfiles] eup ON ep.[EntityId] = eup.[Id]
    WHERE ep.[EntityId] != eup.[EntityId] OR ep.[EntityId] IS NULL
    
    PRINT '? EntityId actualizado en EntityProfessionalProfiles'
END
GO

-- Eliminar y recrear FK
DECLARE @fkProfName NVARCHAR(255)
SELECT @fkProfName = fk.name
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID(N'[dbo].[EntityProfessionalProfiles]')
AND fk.referenced_object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]')

IF @fkProfName IS NOT NULL
BEGIN
    DECLARE @dropFK NVARCHAR(MAX) = 'ALTER TABLE [dbo].[EntityProfessionalProfiles] DROP CONSTRAINT [' + @fkProfName + ']'
    EXEC sp_executesql @dropFK
    PRINT '? FK antigua eliminada de EntityProfessionalProfiles'
END
GO

-- Crear nueva FK a Entities
IF NOT EXISTS (SELECT * FROM sys.foreign_keys 
               WHERE name = 'FK_EntityProfessionalProfiles_Entities')
BEGIN
    ALTER TABLE [dbo].[EntityProfessionalProfiles]
    ADD CONSTRAINT [FK_EntityProfessionalProfiles_Entities] 
        FOREIGN KEY ([EntityId]) 
        REFERENCES [dbo].[Entities]([Id])
    
    PRINT '? FK EntityProfessionalProfiles ? Entities creada'
END
GO

-- ========================================
-- 7. ACTUALIZAR PATIENTPROFILES
-- ========================================

-- Agregar EntityId a PatientProfiles
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[PatientProfiles]') 
               AND name = 'EntityId')
BEGIN
    ALTER TABLE [dbo].[PatientProfiles]
    ADD [EntityId] INT NULL
    
    PRINT '? Columna EntityId agregada a PatientProfiles'
END
GO

-- Poblar EntityId desde el profesional asignado
UPDATE p
SET p.[EntityId] = prof.[EntityId]
FROM [dbo].[PatientProfiles] p
INNER JOIN [dbo].[EntityProfessionalProfiles] prof ON p.[ProfessionalId] = prof.[Id]
WHERE p.[EntityId] IS NULL
GO

-- Agregar FK
IF NOT EXISTS (SELECT * FROM sys.foreign_keys 
               WHERE name = 'FK_PatientProfiles_Entities')
BEGIN
    ALTER TABLE [dbo].[PatientProfiles]
    ADD CONSTRAINT [FK_PatientProfiles_Entities] 
        FOREIGN KEY ([EntityId]) 
        REFERENCES [dbo].[Entities]([Id])
    
    PRINT '? FK PatientProfiles ? Entities creada'
END
GO

-- Agregar índice
IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'IX_PatientProfiles_EntityId')
BEGIN
    CREATE INDEX [IX_PatientProfiles_EntityId]
    ON [dbo].[PatientProfiles] ([EntityId])
    
    PRINT '? Índice IX_PatientProfiles_EntityId creado'
END
GO

-- ========================================
-- 8. CREAR ÍNDICES ADICIONALES
-- ========================================

-- EntityUserProfiles
IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'IX_EntityUserProfiles_EntityId_ApplicationUserId')
BEGIN
    CREATE UNIQUE INDEX [IX_EntityUserProfiles_EntityId_ApplicationUserId]
    ON [dbo].[EntityUserProfiles] ([EntityId], [ApplicationUserId])
    
    PRINT '? Índice único EntityUserProfiles creado'
END
GO

-- ========================================
-- 9. REGISTRAR MIGRACIÓN
-- ========================================

IF NOT EXISTS (SELECT * FROM [dbo].[__EFMigrationsHistory] 
               WHERE [MigrationId] = N'20250125000002_AddEntityTableAndRefactorRelations')
BEGIN
    INSERT INTO [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20250125000002_AddEntityTableAndRefactorRelations', N'8.0.21')
    
    PRINT '? Migración registrada'
END
GO

-- ========================================
-- 10. VERIFICACIÓN FINAL
-- ========================================

PRINT ''
PRINT '=========================================='
PRINT 'VERIFICACIÓN DE LA MIGRACIÓN'
PRINT '=========================================='
PRINT ''

-- Verificar tabla Entities
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Entities')
BEGIN
    DECLARE @entitiesCount INT
    SELECT @entitiesCount = COUNT(*) FROM [dbo].[Entities]
    PRINT '? Tabla Entities existe (' + CAST(@entitiesCount AS VARCHAR) + ' registros)'
END
ELSE
BEGIN
    PRINT '? ERROR: Tabla Entities no existe'
END

-- Verificar EntityUserProfiles
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[EntityUserProfiles]') 
           AND name = 'EntityId')
BEGIN
    PRINT '? EntityUserProfiles tiene EntityId'
END
ELSE
BEGIN
    PRINT '? ERROR: EntityUserProfiles NO tiene EntityId'
END

-- Verificar EntityProfessionalProfiles
IF EXISTS (SELECT * FROM sys.foreign_keys 
           WHERE name = 'FK_EntityProfessionalProfiles_Entities')
BEGIN
    PRINT '? EntityProfessionalProfiles referencia Entities'
END
ELSE
BEGIN
    PRINT '? ERROR: FK EntityProfessionalProfiles ? Entities no existe'
END

-- Verificar PatientProfiles
IF EXISTS (SELECT * FROM sys.columns 
           WHERE object_id = OBJECT_ID(N'[dbo].[PatientProfiles]') 
           AND name = 'EntityId')
BEGIN
    PRINT '? PatientProfiles tiene EntityId'
END
ELSE
BEGIN
    PRINT '? ERROR: PatientProfiles NO tiene EntityId'
END

COMMIT TRANSACTION
GO

PRINT ''
PRINT '=========================================='
PRINT '? MIGRACIÓN COMPLETADA EXITOSAMENTE'
PRINT '=========================================='
PRINT ''

-- Mostrar estadísticas finales
SELECT 
    'Entities' AS Tabla,
    COUNT(*) AS Registros
FROM [dbo].[Entities]
UNION ALL
SELECT 
    'EntityUserProfiles (Administradores)',
    COUNT(*)
FROM [dbo].[EntityUserProfiles]
UNION ALL
SELECT 
    'EntityProfessionalProfiles',
    COUNT(*)
FROM [dbo].[EntityProfessionalProfiles]
UNION ALL
SELECT 
    'PatientProfiles',
    COUNT(*)
FROM [dbo].[PatientProfiles]
GO
```

---

## ? Próximos Pasos

1. **Ejecutar el script SQL** en SQL Server Management Studio
2. **Actualizar servicios** para trabajar con la nueva estructura
3. **Crear componente** `ManageEntityAdmins.razor` para gestionar administradores
4. **Actualizar** `RegisterEntity.razor` para crear Entity primero
5. **Modificar** `AddProfessional.razor` y otros componentes para usar EntityId
6. **Probar** flujos de registro completos

---

**Fecha:** 2025-01-25  
**Versión:** 2.0 - Refactorización completa de entidades
