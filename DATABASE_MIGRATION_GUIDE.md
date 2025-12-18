# Guía de Migración de Base de Datos - Sistema Multi-Usuario

## Comandos de Migración

### 1. Crear la Migración

Abre la **Consola del Administrador de Paquetes** en Visual Studio (Tools ? NuGet Package Manager ? Package Manager Console) y ejecuta:

```powershell
Add-Migration MultiUserTypeSystem -Project "Salutia Wep App" -Context ApplicationDbContext
```

### 2. Revisar la Migración

Revisa el archivo de migración generado en `Salutia Wep App/Migrations/` para asegurarte de que incluye:

- Modificación de tabla `AspNetUsers` con columnas:
  - `UserType` (int)
  - `IsActive` (bit)
  - `CreatedAt` (datetime2)
  - `UpdatedAt` (datetime2, nullable)

- Creación de tabla `IndependentUserProfiles`:
  - `Id` (PK)
  - `ApplicationUserId` (FK a AspNetUsers)
  - `FullName`
  - `DocumentType`
  - `DocumentNumber` (Unique)
  - `Phone`
  - `DateOfBirth` (nullable)
  - `Address` (nullable)

- Creación de tabla `EntityUserProfiles`:
  - `Id` (PK)
  - `ApplicationUserId` (FK a AspNetUsers)
  - `BusinessName`
  - `TaxId` (Unique)
  - `VerificationDigit`
  - `Phone`
  - `Address` (nullable)
  - `Website` (nullable)
  - `LegalRepresentative` (nullable)

- Creación de tabla `EntityMemberProfiles`:
  - `Id` (PK)
  - `ApplicationUserId` (FK a AspNetUsers)
  - `EntityId` (FK a EntityUserProfiles)
  - `FullName`
  - `DocumentType`
  - `DocumentNumber`
  - `Position` (nullable)
  - `Phone` (nullable)
  - `JoinedAt`
  - `IsActive`

### 3. Aplicar la Migración

```powershell
Update-Database -Project "Salutia Wep App" -Context ApplicationDbContext
```

### 4. Verificar la Migración

Conéctate a tu base de datos SQL Server y verifica que las tablas fueron creadas correctamente:

```sql
-- Verificar columnas de AspNetUsers
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AspNetUsers'
ORDER BY ORDINAL_POSITION;

-- Verificar tablas creadas
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('IndependentUserProfiles', 'EntityUserProfiles', 'EntityMemberProfiles');

-- Verificar relaciones
SELECT 
    fk.name AS ForeignKey,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
    INNER JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
    INNER JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id
    INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
    INNER JOIN sys.columns AS cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
    INNER JOIN sys.columns AS cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
WHERE tp.name IN ('IndependentUserProfiles', 'EntityUserProfiles', 'EntityMemberProfiles');
```

## Crear Primer SuperAdministrador

Después de aplicar la migración, necesitas crear el primer superadministrador manualmente:

### Opción 1: Usando SQL Server Management Studio

```sql
-- 1. Insertar usuario en AspNetUsers
DECLARE @UserId NVARCHAR(450) = NEWID();
DECLARE @Email NVARCHAR(256) = 'admin@salutia.com';
DECLARE @UserName NVARCHAR(256) = 'admin@salutia.com';

-- Hash para contraseña "Admin123!" (debes cambiarla después del primer login)
-- Este hash es solo un ejemplo, usa Identity para generar el hash real
DECLARE @PasswordHash NVARCHAR(MAX) = 'AQAAAAIAAYagAAAAEBx...'; -- Generado por Identity

INSERT INTO AspNetUsers (
    Id, UserName, NormalizedUserName, Email, NormalizedEmail, 
    EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp,
    PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount,
    UserType, IsActive, CreatedAt
)
VALUES (
    @UserId, @Email, UPPER(@Email), @Email, UPPER(@Email),
    1, @PasswordHash, NEWID(), NEWID(),
    0, 0, 1, 0,
    0, -- UserType.SuperAdmin = 0
    1, -- IsActive = true
    GETUTCDATE()
);

-- 2. Asignar rol SuperAdmin
DECLARE @RoleId NVARCHAR(450) = (SELECT Id FROM AspNetRoles WHERE Name = 'SuperAdmin');

INSERT INTO AspNetUserRoles (UserId, RoleId)
VALUES (@UserId, @RoleId);

SELECT 'SuperAdmin creado exitosamente. Email: ' + @Email;
```

### Opción 2: Crear SuperAdmin desde la Aplicación (Recomendado)

Crea temporalmente una página de registro de superadmin o usa la consola del administrador de paquetes:

```csharp
// TODO: Crear endpoint temporal para registro de primer superadmin
// Este endpoint debe ser eliminado después de crear el primer admin
```

## Revertir Migración (Si es necesario)

Si necesitas revertir la migración:

```powershell
# Revertir a la migración anterior
Update-Database -Migration:<NombreMigracionAnterior> -Project "Salutia Wep App"

# Eliminar el archivo de migración
Remove-Migration -Project "Salutia Wep App"
```

## Datos de Prueba

### Crear Usuario Independiente de Prueba

```sql
-- Insertar usuario
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, UserType, IsActive, CreatedAt)
VALUES (NEWID(), 'juan@test.com', 'JUAN@TEST.COM', 'juan@test.com', 'JUAN@TEST.COM', 1, 'AQAAAAIAAYagAAAA...', NEWID(), NEWID(), 0, 0, 1, 0, 2, 1, GETUTCDATE());

-- Insertar perfil independiente
INSERT INTO IndependentUserProfiles (ApplicationUserId, FullName, DocumentType, DocumentNumber, Phone)
VALUES ((SELECT Id FROM AspNetUsers WHERE Email = 'juan@test.com'), 'Juan Pérez', 1, '1234567890', '3001234567');

-- Asignar rol
INSERT INTO AspNetUserRoles (UserId, RoleId)
VALUES ((SELECT Id FROM AspNetUsers WHERE Email = 'juan@test.com'), (SELECT Id FROM AspNetRoles WHERE Name = 'Independent'));
```

### Crear Entidad de Prueba

```sql
-- Insertar usuario entidad
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, UserType, IsActive, CreatedAt)
VALUES (NEWID(), 'empresa@test.com', 'EMPRESA@TEST.COM', 'empresa@test.com', 'EMPRESA@TEST.COM', 1, 'AQAAAAIAAYagAAAA...', NEWID(), NEWID(), 0, 0, 1, 0, 1, 1, GETUTCDATE());

-- Insertar perfil entidad
INSERT INTO EntityUserProfiles (ApplicationUserId, BusinessName, TaxId, VerificationDigit, Phone)
VALUES ((SELECT Id FROM AspNetUsers WHERE Email = 'empresa@test.com'), 'Hospital San José S.A.', '890123456', '7', '6012345678');

-- Asignar rol
INSERT INTO AspNetUserRoles (UserId, RoleId)
VALUES ((SELECT Id FROM AspNetUsers WHERE Email = 'empresa@test.com'), (SELECT Id FROM AspNetRoles WHERE Name = 'Entity'));
```

## Troubleshooting

### Error: "Cannot insert duplicate key"

**Causa**: Ya existe un usuario con ese email o documento.

**Solución**: 
```sql
-- Verificar usuarios existentes
SELECT Email, UserType FROM AspNetUsers;

-- Verificar documentos duplicados
SELECT DocumentNumber FROM IndependentUserProfiles;
SELECT TaxId FROM EntityUserProfiles;
```

### Error: "The DELETE statement conflicted with the REFERENCE constraint"

**Causa**: Intentando eliminar un registro que tiene dependencias.

**Solución**:
1. Eliminar primero los registros dependientes (EntityMemberProfiles)
2. Luego eliminar el perfil (EntityUserProfile/IndependentUserProfile)
3. Finalmente eliminar el usuario (AspNetUsers)

### Error: "Invalid column name 'UserType'"

**Causa**: La migración no se aplicó correctamente.

**Solución**:
```powershell
# Verificar migraciones aplicadas
Get-Migration -Project "Salutia Wep App"

# Aplicar migración pendiente
Update-Database -Project "Salutia Wep App"
```

## Verificación Post-Migración

### Checklist

- [ ] Tabla AspNetUsers tiene columnas: UserType, IsActive, CreatedAt, UpdatedAt
- [ ] Tabla IndependentUserProfiles creada con índice único en DocumentNumber
- [ ] Tabla EntityUserProfiles creada con índice único en TaxId
- [ ] Tabla EntityMemberProfiles creada con FK a EntityUserProfiles
- [ ] Roles creados: SuperAdmin, Entity, Independent, EntityMember
- [ ] Relaciones FK configuradas correctamente
- [ ] Índices únicos funcionando
- [ ] Primer superadministrador creado y funcional

## Próximos Pasos

1. ? Aplicar migración
2. ? Crear primer superadministrador
3. ? Probar registro de usuario independiente
4. ? Probar registro de entidad
5. ? Probar creación de miembro por entidad
6. ? Verificar login para cada tipo de usuario
7. ? Verificar redirección a dashboard apropiado

## Comandos Útiles

```powershell
# Ver estado de migraciones
Get-Migration -Project "Salutia Wep App"

# Generar script SQL sin aplicar
Script-Migration -From 0 -Project "Salutia Wep App"

# Aplicar hasta una migración específica
Update-Database -Migration:<NombreMigración> -Project "Salutia Wep App"

# Ver diferencias
Get-Migration -Project "Salutia Wep App" | Format-Table Name, Applied

# Eliminar todas las migraciones (¡CUIDADO!)
# Update-Database -Migration:0 -Project "Salutia Wep App"
# Get-Migration -Project "Salutia Wep App" | Remove-Migration
```

---

**Nota Importante**: Realiza un backup de tu base de datos antes de aplicar cualquier migración en producción.
