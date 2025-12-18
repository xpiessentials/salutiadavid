# ?? Quick Start Guide - Sistema Multi-Usuario Salutia

## Comandos Rápidos

### 1. Aplicar Migración de Base de Datos

```powershell
# En Package Manager Console de Visual Studio
Add-Migration MultiUserTypeSystem -Project "Salutia Wep App"
Update-Database -Project "Salutia Wep App"
```

### 2. Ejecutar la Aplicación

```powershell
# Opción A: Con Aspire (Recomendado)
dotnet run --project "Salutia.AppHost"

# Opción B: Solo Web App
dotnet run --project "Salutia Wep App"
```

### 3. URLs de Acceso

```
Web App: https://localhost:7XXX (puerto asignado por Aspire)
Aspire Dashboard: https://localhost:15XXX
```

---

## ?? Checklist de Implementación

### Antes de Empezar
- [ ] SQL Server o SQL Server Express instalado y corriendo
- [ ] Connection string configurado en `appsettings.json`
- [ ] Visual Studio 2022 con .NET 9 SDK

### Pasos de Configuración

#### 1. Base de Datos
```powershell
# Verificar connection string en appsettings.json
# Aplicar migración
Add-Migration MultiUserTypeSystem -Project "Salutia Wep App"
Update-Database -Project "Salutia Wep App"
```

#### 2. Crear Primer SuperAdmin

**Opción A: Script SQL** (Temporal, solo para desarrollo)

```sql
-- En SQL Server Management Studio
USE [tu_base_de_datos];

-- Insertar SuperAdmin temporal
-- Importante: Cambiar la contraseña después del primer login
EXEC sp_executesql N'
DECLARE @UserId NVARCHAR(450) = NEWID();
DECLARE @Email NVARCHAR(256) = ''admin@salutia.com'';

INSERT INTO AspNetUsers (
    Id, UserName, NormalizedUserName, Email, NormalizedEmail,
    EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp,
    PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount,
  UserType, IsActive, CreatedAt
)
VALUES (
    @UserId, @Email, UPPER(@Email), @Email, UPPER(@Email),
    1, 
    ''AQAAAAIAAYagAAAAEO7xqVrQ0uQ2TG8cKF8fXqQ8K3rqVl8fXqQ8K3rqVl8fXqQ8K3rqVl8fXqQ8K3rqVl8='', -- Contraseña: Admin123!
    NEWID(), NEWID(),
    0, 0, 1, 0,
 0, -- UserType.SuperAdmin
    1, -- IsActive
    GETUTCDATE()
);

-- Asignar rol
INSERT INTO AspNetUserRoles (UserId, RoleId)
SELECT @UserId, Id FROM AspNetRoles WHERE Name = ''SuperAdmin'';

PRINT ''SuperAdmin creado: '' + @Email + '' / Contraseña: Admin123!'';
';
```

**Opción B: Desde la Aplicación** (Recomendado para producción)

Crear temporalmente una ruta protegida o usar seeding en `Program.cs`.

#### 3. Verificar Roles

```sql
-- Verificar que los roles existen
SELECT * FROM AspNetRoles;
-- Debe mostrar: SuperAdmin, Entity, Independent, EntityMember
```

### 4. Probar Funcionalidades

```
? Test 1: Registro Independiente
 ? Navegar a /Account/ChooseRegistrationType
   ? Seleccionar "Usuario Independiente"
   ? Completar formulario
   ? Verificar email de confirmación
   ? Iniciar sesión

? Test 2: Registro Entidad
   ? Navegar a /Account/ChooseRegistrationType
   ? Seleccionar "Entidad"
 ? Completar formulario con NIT
   ? Verificar confirmación

? Test 3: Login y Redirección
   ? Iniciar sesión como independiente ? Debe ir a /User/Dashboard
   ? Iniciar sesión como entidad ? Debe ir a /Entity/Dashboard
   ? Iniciar sesión como admin ? Debe ir a /Admin/Dashboard

? Test 4: Gestión de Miembros (Entidad)
   ? Login como entidad
   ? Ir a "Gestionar Miembros"
   ? Agregar nuevo miembro
   ? Verificar que aparece en la lista

? Test 5: Login Miembro
   ? Iniciar sesión con usuario miembro creado
   ? Debe ir a /Member/Dashboard
   ? Verificar que ve información de su entidad
```

---

## ?? Troubleshooting Rápido

### Error: "Cannot insert duplicate key"
```sql
-- Verificar email duplicado
SELECT Email FROM AspNetUsers WHERE Email = 'email@test.com';
-- Si existe, usar otro email
```

### Error: "Login failed for user"
```
1. Verificar SQL Server está corriendo
2. Revisar connection string en appsettings.json
3. Verificar permisos de usuario de BD
```

### Error: "Invalid column name 'UserType'"
```powershell
# Aplicar migración
Update-Database -Project "Salutia Wep App"
```

### Error: "Access Denied" en dashboard
```
1. Verificar que el rol está asignado correctamente
2. Limpiar cookies del navegador
3. Iniciar sesión nuevamente
```

### Error: "Page not found" después de login
```csharp
// Verificar que existe la página del dashboard
// Ej: Salutia Wep App/Components/Pages/User/Dashboard.razor
```

---

## ?? Rutas Principales

### Públicas (No requieren login)
```
/        - Home
/Account/Login         - Login
/Account/ChooseRegistrationType   - Selección tipo registro
/Account/RegisterIndependent         - Registro independiente
/Account/RegisterEntity   - Registro entidad
/Account/RegisterConfirmation        - Confirmación registro
/Account/ForgotPassword     - Recuperar contraseña
```

### SuperAdmin (Requiere rol: SuperAdmin)
```
/Admin/Dashboard       - Panel administrador
/Admin/Users    - Gestión usuarios (TODO)
/Admin/Entities     - Gestión entidades (TODO)
/Admin/Reports             - Reportes sistema (TODO)
```

### Entidad (Requiere rol: Entity)
```
/Entity/Dashboard             - Panel entidad
/Entity/ManageMembers            - Gestionar miembros
/Entity/AddMember              - Agregar miembro
/Entity/Member/{id}- Ver miembro (TODO)
/Entity/EditMember/{id}         - Editar miembro (TODO)
/Entity/Reports  - Reportes entidad (TODO)
```

### Independiente (Requiere rol: Independent)
```
/User/Dashboard           - Panel usuario
/User/History       - Historial tests (TODO)
/User/TestResult     - Resultado test (TODO)
/Account/Manage             - Gestión perfil
```

### Miembro (Requiere rol: EntityMember)
```
/Member/Dashboard           - Panel miembro
/Member/Profile           - Ver perfil (TODO)
/Member/History          - Historial tests (TODO)
```

### Compartidas (Requieren login)
```
/test-psicosomatico                  - Test psicosomático
/Account/Manage           - Gestión cuenta
/Account/Manage/EnableAuthenticator  - 2FA
```

---

## ?? Datos de Prueba

### Crear Usuarios de Prueba (SQL)

```sql
-- Usuario Independiente de Prueba
-- Email: juan@test.com / Password: Test123!
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, UserType, IsActive, CreatedAt)
VALUES (NEWID(), 'juan@test.com', 'JUAN@TEST.COM', 'juan@test.com', 'JUAN@TEST.COM', 1, 'AQAAAAIAAYagAAAAEO7xqVrQ0uQ2TG8cKF8fXqQ8K3rqVl8=', NEWID(), NEWID(), 0, 0, 1, 0, 2, 1, GETUTCDATE());

-- Perfil Independiente
INSERT INTO IndependentUserProfiles (ApplicationUserId, FullName, DocumentType, DocumentNumber, Phone)
SELECT Id, 'Juan Pérez García', 1, '1234567890', '3001234567'
FROM AspNetUsers WHERE Email = 'juan@test.com';

-- Asignar rol
INSERT INTO AspNetUserRoles (UserId, RoleId)
SELECT u.Id, r.Id 
FROM AspNetUsers u, AspNetRoles r 
WHERE u.Email = 'juan@test.com' AND r.Name = 'Independent';

-- Entidad de Prueba
-- Email: empresa@test.com / Password: Test123!
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, UserType, IsActive, CreatedAt)
VALUES (NEWID(), 'empresa@test.com', 'EMPRESA@TEST.COM', 'empresa@test.com', 'EMPRESA@TEST.COM', 1, 'AQAAAAIAAYagAAAAEO7xqVrQ0uQ2TG8cKF8fXqQ8K3rqVl8=', NEWID(), NEWID(), 0, 0, 1, 0, 1, 1, GETUTCDATE());

-- Perfil Entidad
INSERT INTO EntityUserProfiles (ApplicationUserId, BusinessName, TaxId, VerificationDigit, Phone)
SELECT Id, 'Hospital San José S.A.', '890123456', '7', '6012345678'
FROM AspNetUsers WHERE Email = 'empresa@test.com';

-- Asignar rol
INSERT INTO AspNetUserRoles (UserId, RoleId)
SELECT u.Id, r.Id 
FROM AspNetUsers u, AspNetRoles r 
WHERE u.Email = 'empresa@test.com' AND r.Name = 'Entity';
```

**Nota**: El hash de contraseña usado es solo ejemplo. En producción, usa Identity para generar hashes válidos.

---

## ?? Configuración de Seguridad

### Políticas de Contraseña Actuales:

```csharp
// En Program.cs
options.Password.RequireDigit = true;
options.Password.RequireLowercase = true;
options.Password.RequireUppercase = false;  // No requiere mayúsculas
options.Password.RequireNonAlphanumeric = false;  // No requiere caracteres especiales
options.Password.RequiredLength = 6;
```

### Modificar si es Necesario:

```csharp
builder.Services.AddIdentityCore<ApplicationUser>(options => {
    options.SignIn.RequireConfirmedAccount = true;
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;  // Cambiar a true
    options.Password.RequireNonAlphanumeric = true;  // Cambiar a true
    options.Password.RequiredLength = 8;  // Aumentar a 8
})
```

---

## ?? Integración Mobile App

### Endpoints API Disponibles:

```csharp
// AuthController (ya implementado)
POST /api/auth/login
POST /api/auth/register

// TODO: Agregar endpoints para multi-user
POST /api/auth/register-independent
POST /api/auth/register-entity
GET /api/auth/user-info
```

### Configurar en Mobile App:

```csharp
// En MauiProgram.cs de Salutia.MobileApp
builder.Services.AddHttpClient("SalutiaAPI", client =>
{
    client.BaseAddress = new Uri("https://localhost:7XXX/");  // URL del Web App
});
```

---

## ?? Verificación de Estado

### Checklist Post-Implementación:

```bash
? Compilación exitosa
? Migración aplicada
? Roles creados (4 roles)
? SuperAdmin creado
? Usuarios de prueba creados (opcional)
? Login funciona para cada tipo
? Dashboards visibles según rol
? Entidad puede crear miembros
? Miembro puede iniciar sesión
? Búsqueda y filtros funcionan
```

### Comandos de Verificación BD:

```sql
-- Total de usuarios
SELECT COUNT(*) AS TotalUsers FROM AspNetUsers;

-- Usuarios por tipo
SELECT UserType, COUNT(*) AS Count
FROM AspNetUsers
GROUP BY UserType;

-- Roles asignados
SELECT r.Name, COUNT(ur.UserId) AS UserCount
FROM AspNetRoles r
LEFT JOIN AspNetUserRoles ur ON r.Id = ur.RoleId
GROUP BY r.Name;

-- Entidades con miembros
SELECT 
    e.BusinessName,
    COUNT(m.Id) AS TotalMembers,
    SUM(CASE WHEN m.IsActive = 1 THEN 1 ELSE 0 END) AS ActiveMembers
FROM EntityUserProfiles e
LEFT JOIN EntityMemberProfiles m ON e.Id = m.EntityId
GROUP BY e.Id, e.BusinessName;
```

---

## ?? Demo Script

### Para Demostrar el Sistema:

1. **Mostrar Home Page**
   - Navegar a `/`
   - Mostrar hero banner y características

2. **Registro de Usuario Independiente**
   - Ir a registro
   - Seleccionar "Independiente"
   - Llenar formulario
   - Mostrar confirmación

3. **Login y Dashboard**
   - Iniciar sesión
   - Mostrar redirección automática
   - Explorar dashboard de usuario

4. **Registro de Entidad**
   - Registrar una entidad
   - Mostrar confirmación

5. **Gestión de Miembros**
   - Login como entidad
   - Agregar un miembro
   - Mostrar lista de miembros
   - Activar/desactivar miembro
   - Búsqueda y filtros

6. **Login como Miembro**
   - Iniciar sesión con usuario miembro
   - Mostrar su dashboard
   - Ver información de entidad

7. **SuperAdmin** (si está disponible)
   - Login como superadmin
 - Mostrar estadísticas globales
   - Ver todos los usuarios

---

## ?? Soporte

### Si encuentras problemas:

1. **Revisar logs** en consola de Visual Studio
2. **Verificar base de datos** con queries de verificación
3. **Limpiar y reconstruir** solución
4. **Reiniciar SQL Server**
5. **Consultar documentación**:
   - `IMPLEMENTATION_COMPLETE.md`
   - `DATABASE_MIGRATION_GUIDE.md`
   - `MULTI_USER_SYSTEM_IMPLEMENTATION.md`

---

## ? Próximos Pasos Sugeridos

1. [ ] Configurar email real (SendGrid, SMTP)
2. [ ] Implementar páginas TODO marcadas
3. [ ] Agregar tests unitarios
4. [ ] Configurar CI/CD
5. [ ] Preparar para producción
6. [ ] Documentar APIs para mobile
7. [ ] Agregar más validaciones
8. [ ] Implementar auditoría de cambios

---

**?? ¡El sistema está listo para usar!**

Solo falta aplicar la migración de base de datos y crear el primer superadministrador.

**Comando rápido**:
```powershell
Add-Migration MultiUserTypeSystem -Project "Salutia Wep App"
Update-Database -Project "Salutia Wep App"
```

¡Éxito! ??
