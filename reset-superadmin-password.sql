-- =============================================
-- Script para cambiar contraseña del SuperAdmin
-- =============================================
-- INSTRUCCIONES:
-- 1. Ejecuta el script de PowerShell: reset-superadmin-password.ps1
--    (Es la forma más fácil y segura)
-- 
-- 2. O si prefieres, ejecuta este script SQL directamente:
--    - Reemplaza el valor de @NewPasswordHash con un hash generado
--    - El hash debe ser generado con ASP.NET Core Identity PasswordHasher
-- =============================================

USE Salutia;
GO

-- Verificar que existe el usuario SuperAdmin
SELECT 
    Id,
    UserName,
    Email,
    EmailConfirmed,
    PhoneNumber
FROM AspNetUsers
WHERE LOWER(Email) = 'elpeco1@msn.com'
   OR LOWER(UserName) = 'elpeco1@msn.com';
GO

-- Para cambiar la contraseña, usa el script de PowerShell
-- O genera un hash manualmente y ejecuta este UPDATE:

/*
DECLARE @NewPasswordHash NVARCHAR(MAX) = 'TU_HASH_AQUI';

UPDATE AspNetUsers 
SET PasswordHash = @NewPasswordHash,
    SecurityStamp = NEWID(),
    ConcurrencyStamp = NEWID(),
    LockoutEnd = NULL,
  AccessFailedCount = 0
WHERE LOWER(Email) = 'elpeco1@msn.com' 
   OR LOWER(UserName) = 'elpeco1@msn.com';

SELECT @@ROWCOUNT as 'Filas actualizadas';
*/

-- Verificar roles del usuario
SELECT 
    u.UserName,
    u.Email,
    r.Name as RoleName
FROM AspNetUsers u
INNER JOIN AspNetUserRoles ur ON u.Id = ur.UserId
INNER JOIN AspNetRoles r ON ur.RoleId = r.Id
WHERE LOWER(u.Email) = 'elpeco1@msn.com';
GO

-- Si el usuario no tiene el rol SuperAdmin, agregarlo:
/*
DECLARE @UserId NVARCHAR(450);
DECLARE @RoleId NVARCHAR(450);

SELECT @UserId = Id FROM AspNetUsers 
WHERE LOWER(Email) = 'elpeco1@msn.com';

SELECT @RoleId = Id FROM AspNetRoles 
WHERE Name = 'SuperAdmin';

IF @UserId IS NOT NULL AND @RoleId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM AspNetUserRoles WHERE UserId = @UserId AND RoleId = @RoleId)
    BEGIN
        INSERT INTO AspNetUserRoles (UserId, RoleId) 
        VALUES (@UserId, @RoleId);
        PRINT 'Rol SuperAdmin agregado';
    END
  ELSE
    BEGIN
        PRINT 'El usuario ya tiene el rol SuperAdmin';
    END
END
ELSE
BEGIN
    PRINT 'ERROR: Usuario o rol no encontrado';
END
*/
GO
