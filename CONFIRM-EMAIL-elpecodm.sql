-- ============================================
-- Script: Confirmar Email para Usuario Entidad
-- Usuario: elpecodm@hotmail.com
-- Problema: Email no confirmado, no puede iniciar sesión
-- ============================================

USE Salutia;
GO

-- 1. Verificar estado actual del usuario
SELECT 
    Id,
    Email,
    EmailConfirmed,
    UserType,
    IsActive,
    CreatedAt
FROM AspNetUsers
WHERE Email = 'elpecodm@hotmail.com';
GO

-- 2. Confirmar el email
UPDATE AspNetUsers
SET EmailConfirmed = 1
WHERE Email = 'elpecodm@hotmail.com';
GO

-- 3. Verificar que se aplicó el cambio
SELECT 
    Id,
    Email,
    EmailConfirmed AS [Email Confirmado],
    UserType,
    IsActive AS [Usuario Activo],
    CreatedAt AS [Fecha Registro]
FROM AspNetUsers
WHERE Email = 'elpecodm@hotmail.com';
GO

-- 4. Verificar roles asignados
SELECT 
    u.Email,
    r.Name AS Rol
FROM AspNetUsers u
INNER JOIN AspNetUserRoles ur ON u.Id = ur.UserId
INNER JOIN AspNetRoles r ON ur.RoleId = r.Id
WHERE u.Email = 'elpecodm@hotmail.com';
GO

-- 5. Verificar entidad asociada
SELECT 
    e.Id AS EntityId,
    e.BusinessName AS [Razón Social],
    e.TaxId AS NIT,
    e.Phone AS Teléfono,
    e.IsActive AS [Entidad Activa],
    ep.FullName AS [Administrador],
    ep.Position AS Cargo
FROM EntityUserProfiles ep
INNER JOIN Entities e ON ep.EntityId = e.Id
INNER JOIN AspNetUsers u ON ep.ApplicationUserId = u.Id
WHERE u.Email = 'elpecodm@hotmail.com';
GO

PRINT '? Email confirmado exitosamente para: elpecodm@hotmail.com'
PRINT '? Ahora puedes iniciar sesión con tu contraseña'
GO
