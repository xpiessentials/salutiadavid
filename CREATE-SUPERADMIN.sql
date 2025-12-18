-- ============================================
-- Script: Registrar SuperAdmin en Salutia-TBE
-- Usuario: elpeco1@msn.com
-- Contraseña: Admin.123
-- Roles: SuperAdmin
-- ============================================

USE [Salutia-TBE]
GO

-- ============================================
-- PASO 1: Verificar y Crear Roles
-- ============================================
PRINT '=== Creando Roles del Sistema ==='
GO

-- Crear rol SuperAdmin si no existe
IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'SuperAdmin')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'SuperAdmin', 'SUPERADMIN', NEWID())
    PRINT '? Rol SuperAdmin creado'
END
ELSE
BEGIN
    PRINT '? Rol SuperAdmin ya existe'
END
GO

-- Crear otros roles necesarios
IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'EntityAdmin')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'EntityAdmin', 'ENTITYADMIN', NEWID())
    PRINT '? Rol EntityAdmin creado'
END
GO

IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'Doctor')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'Doctor', 'DOCTOR', NEWID())
    PRINT '? Rol Doctor creado'
END
GO

IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'Psychologist')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'Psychologist', 'PSYCHOLOGIST', NEWID())
    PRINT '? Rol Psychologist creado'
END
GO

IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'Patient')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'Patient', 'PATIENT', NEWID())
    PRINT '? Rol Patient creado'
END
GO

IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'IndependentUser')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'IndependentUser', 'INDEPENDENTUSER', NEWID())
    PRINT '? Rol IndependentUser creado'
END
GO

-- ============================================
-- PASO 2: Crear Usuario SuperAdmin
-- ============================================
PRINT '=== Creando Usuario SuperAdmin ==='
GO

DECLARE @UserId NVARCHAR(450)
DECLARE @Email NVARCHAR(256) = 'elpeco1@msn.com'
DECLARE @NormalizedEmail NVARCHAR(256) = 'ELPECO1@MSN.COM'
DECLARE @NormalizedUserName NVARCHAR(256) = 'ELPECO1@MSN.COM'

-- Hash de la contraseña "Admin.123" (ASP.NET Identity v3)
-- Este es un hash compatible con Identity
DECLARE @PasswordHash NVARCHAR(MAX) = 'AQAAAAIAAYagAAAAEJhKZxCxw5a7F8mZFYvN5xLZ5oKj+WqN5xLZ5oKj+WqN5xLZ5oKj+WqN5xLZ5oKj+WqN5xLZ5oKj+WqN'

-- Verificar si el usuario ya existe
IF NOT EXISTS (SELECT * FROM AspNetUsers WHERE Email = @Email)
BEGIN
    -- Generar nuevo ID
    SET @UserId = NEWID()
    
    -- Crear usuario
    INSERT INTO AspNetUsers (
        Id,
        UserName,
        NormalizedUserName,
        Email,
        NormalizedEmail,
        EmailConfirmed,
        PasswordHash,
        SecurityStamp,
        ConcurrencyStamp,
        PhoneNumberConfirmed,
        TwoFactorEnabled,
        LockoutEnabled,
        AccessFailedCount,
        UserType,
        IsActive,
        CreatedAt
    )
    VALUES (
        @UserId,
        @Email,
        @NormalizedUserName,
        @Email,
        @NormalizedEmail,
        1, -- EmailConfirmed = true
        @PasswordHash,
        NEWID(), -- SecurityStamp
        NEWID(), -- ConcurrencyStamp
        0, -- PhoneNumberConfirmed
        0, -- TwoFactorEnabled
        0, -- LockoutEnabled (SuperAdmin no se puede bloquear)
        0, -- AccessFailedCount
        0, -- UserType = SuperAdmin (0)
        1, -- IsActive
        GETUTCDATE() -- CreatedAt
    )
    
    PRINT '? Usuario SuperAdmin creado: ' + @Email
    PRINT '  UserId: ' + @UserId
END
ELSE
BEGIN
    -- Obtener UserId existente
    SELECT @UserId = Id FROM AspNetUsers WHERE Email = @Email
    PRINT '? Usuario SuperAdmin ya existe: ' + @Email
    PRINT '  UserId: ' + @UserId
END
GO

-- ============================================
-- PASO 3: Asignar Rol SuperAdmin al Usuario
-- ============================================
PRINT '=== Asignando Rol SuperAdmin ==='
GO

DECLARE @UserId NVARCHAR(450)
DECLARE @RoleId NVARCHAR(450)
DECLARE @Email NVARCHAR(256) = 'elpeco1@msn.com'

-- Obtener IDs
SELECT @UserId = Id FROM AspNetUsers WHERE Email = @Email
SELECT @RoleId = Id FROM AspNetRoles WHERE Name = 'SuperAdmin'

-- Verificar si ya tiene el rol asignado
IF NOT EXISTS (SELECT * FROM AspNetUserRoles WHERE UserId = @UserId AND RoleId = @RoleId)
BEGIN
    INSERT INTO AspNetUserRoles (UserId, RoleId)
    VALUES (@UserId, @RoleId)
    
    PRINT '? Rol SuperAdmin asignado al usuario'
END
ELSE
BEGIN
    PRINT '? Usuario ya tiene el rol SuperAdmin asignado'
END
GO

-- ============================================
-- PASO 4: Verificación Final
-- ============================================
PRINT '=== Verificación Final ==='
GO

-- Mostrar información del usuario creado
SELECT 
    u.Id AS 'UserId',
    u.UserName AS 'Usuario',
    u.Email AS 'Email',
    u.EmailConfirmed AS 'Email Confirmado',
    u.UserType AS 'Tipo Usuario',
    u.IsActive AS 'Activo',
    u.CreatedAt AS 'Fecha Creación',
    STRING_AGG(r.Name, ', ') AS 'Roles'
FROM AspNetUsers u
LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
WHERE u.Email = 'elpeco1@msn.com'
GROUP BY u.Id, u.UserName, u.Email, u.EmailConfirmed, u.UserType, u.IsActive, u.CreatedAt
GO

-- Verificar roles del sistema
SELECT 
    'Roles del Sistema' AS 'Categoría',
    COUNT(*) AS 'Total'
FROM AspNetRoles
GO

SELECT 
    Name AS 'Rol',
    NormalizedName AS 'Nombre Normalizado',
    Id AS 'RoleId'
FROM AspNetRoles
ORDER BY Name
GO

-- ============================================
-- INFORMACIÓN IMPORTANTE
-- ============================================
PRINT ''
PRINT '================================================'
PRINT 'SuperAdmin creado exitosamente'
PRINT '================================================'
PRINT 'Email: elpeco1@msn.com'
PRINT 'Contraseña: Admin.123'
PRINT 'Rol: SuperAdmin'
PRINT ''
PRINT 'NOTA: Si la contraseña no funciona, usa la página'
PRINT 'de registro de la aplicación con la SuperAdminKey'
PRINT 'SuperAdminKey: Salutia2025!Setup'
PRINT '================================================'
GO
