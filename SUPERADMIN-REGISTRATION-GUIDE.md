# ?? Guía: Registrar SuperAdmin en Salutia-TBE

## ?? Credenciales del SuperAdmin

- **Email:** `elpeco1@msn.com`
- **Contraseña:** `Admin.123`
- **Rol:** SuperAdmin
- **SuperAdminKey:** `Salutia2025!Setup` (ya configurada en appsettings.json)

---

## ? Método 1: Registro desde la Aplicación (RECOMENDADO)

Este es el método más seguro porque ASP.NET Identity genera el hash de contraseña correctamente.

### Pasos:

1. **Aplicar migración (si no lo has hecho):**
   ```powershell
   Update-Database -Verbose
   ```

2. **Iniciar la aplicación:**
   - Presiona **F5** en Visual Studio

3. **Navegar a la página de registro:**
   - URL: `https://localhost:[puerto]/Account/RegisterSuperAdmin`
   - O desde la página principal: Login > Register > "¿Eres SuperAdmin?"

4. **Completar el formulario:**
   - Email: `elpeco1@msn.com`
   - Contraseña: `Admin.123`
   - Confirmar Contraseña: `Admin.123`
   - SuperAdmin Key: `Salutia2025!Setup`

5. **Hacer clic en:** "Registrar SuperAdmin"

6. **Iniciar sesión:**
   - Email: `elpeco1@msn.com`
   - Contraseña: `Admin.123`

---

## ? Método 2: Script SQL Manual (Alternativo)

Si prefieres usar SQL directamente:

### PASO 1: Ejecutar Script Base en SSMS

Abre `CREATE-SUPERADMIN.sql` en SSMS y ejecútalo. Este script:
- ? Crea todos los roles del sistema
- ? Crea el usuario SuperAdmin
- ?? **IMPORTANTE:** El hash de contraseña en el script es un placeholder

### PASO 2: Cambiar la Contraseña desde la App

Después de ejecutar el script, debes:

1. **Iniciar la aplicación**
2. **Ir a:** `/Account/ForgotPassword`
3. **Ingresar:** `elpeco1@msn.com`
4. **Seguir el proceso de recuperación**

O mejor aún:

1. **Iniciar sesión con cualquier SuperAdmin temporal**
2. **Ir a:** `/Admin/Users`
3. **Editar el usuario:** `elpeco1@msn.com`
4. **Cambiar la contraseña a:** `Admin.123`

---

## ?? Método 3: Usando .NET CLI (Más Confiable)

Crear un comando de inicialización en el código:

### Crear Clase de Inicialización:

**Ubicación:** `Salutia Wep App\Data\DbInitializer.cs`

```csharp
using Microsoft.AspNetCore.Identity;
using Salutia_Wep_App.Data;

public static class DbInitializer
{
    public static async Task InitializeAsync(
        UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole> roleManager)
    {
        // Crear roles
        string[] roles = { "SuperAdmin", "EntityAdmin", "Doctor", "Psychologist", "Patient", "IndependentUser" };
        
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole(role));
            }
        }

        // Crear SuperAdmin
        string email = "elpeco1@msn.com";
        string password = "Admin.123";

        if (await userManager.FindByEmailAsync(email) == null)
        {
            var superAdmin = new ApplicationUser
            {
                UserName = email,
                Email = email,
                EmailConfirmed = true,
                UserType = UserType.SuperAdmin,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            var result = await userManager.CreateAsync(superAdmin, password);

            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(superAdmin, "SuperAdmin");
                Console.WriteLine($"? SuperAdmin creado: {email}");
            }
            else
            {
                Console.WriteLine($"? Error al crear SuperAdmin: {string.Join(", ", result.Errors.Select(e => e.Description))}");
            }
        }
        else
        {
            Console.WriteLine($"? SuperAdmin ya existe: {email}");
        }
    }
}
```

### Llamar desde Program.cs:

**Ubicación:** `Salutia Wep App\Program.cs`

Agregar después de `var app = builder.Build();`:

```csharp
// Inicializar base de datos con SuperAdmin
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
        
        await DbInitializer.InitializeAsync(userManager, roleManager);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Error al inicializar la base de datos");
    }
}
```

**Luego ejecutar la aplicación (F5)** y el SuperAdmin se creará automáticamente.

---

## ? Verificación en SSMS

Después de crear el SuperAdmin (con cualquier método), verifica en SSMS:

```sql
USE [Salutia-TBE]
GO

-- Verificar usuario
SELECT 
    u.Id,
    u.UserName,
    u.Email,
    u.EmailConfirmed,
    u.UserType,
    u.IsActive,
    STRING_AGG(r.Name, ', ') AS Roles
FROM AspNetUsers u
LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
WHERE u.Email = 'elpeco1@msn.com'
GROUP BY u.Id, u.UserName, u.Email, u.EmailConfirmed, u.UserType, u.IsActive
GO

-- Verificar roles
SELECT * FROM AspNetRoles
GO
```

**Resultado esperado:**
```
UserName: elpeco1@msn.com
Email: elpeco1@msn.com
EmailConfirmed: 1
UserType: 0 (SuperAdmin)
IsActive: 1
Roles: SuperAdmin
```

---

## ?? Solución de Problemas

### Problema: "Invalid login attempt"

**Causa:** Hash de contraseña incorrecto (si usaste Script SQL)

**Solución:**
1. Usa el Método 1 (Registro desde la App)
2. O usa el Método 3 (DbInitializer)

---

### Problema: "Email already exists"

**Solución:** Eliminar el usuario existente y volver a crear:

```sql
USE [Salutia-TBE]
GO

-- Eliminar usuario existente
DELETE FROM AspNetUserRoles WHERE UserId IN (SELECT Id FROM AspNetUsers WHERE Email = 'elpeco1@msn.com')
DELETE FROM AspNetUsers WHERE Email = 'elpeco1@msn.com'
GO
```

Luego vuelve a ejecutar el método de creación.

---

### Problema: "Role 'SuperAdmin' does not exist"

**Solución:** Ejecutar script de creación de roles:

```sql
USE [Salutia-TBE]
GO

-- Crear rol SuperAdmin
IF NOT EXISTS (SELECT * FROM AspNetRoles WHERE Name = 'SuperAdmin')
BEGIN
    INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (NEWID(), 'SuperAdmin', 'SUPERADMIN', NEWID())
END
GO
```

---

## ?? Resumen de Métodos

| Método | Ventajas | Desventajas | Recomendado |
|--------|----------|-------------|-------------|
| **1. Registro App** | ? Más seguro<br>? Hash correcto<br>? Sin código | ? Requiere UI | ????? |
| **2. Script SQL** | ? Rápido | ? Hash incorrecto<br>? Necesita cambio de password | ?? |
| **3. DbInitializer** | ? Automático<br>? Reutilizable<br>? Hash correcto | ? Requiere código | ???? |

---

## ?? Recomendación Final

**Usa el Método 3 (DbInitializer)** porque:
1. ? Se ejecuta automáticamente al iniciar la app
2. ? Genera el hash de contraseña correctamente
3. ? Es reutilizable para otros ambientes (test, prod)
4. ? No requiere intervención manual

---

## ?? Acción Inmediata

¿Qué método prefieres?

1. **Método 1:** Te guío para registrar desde la UI
2. **Método 2:** Ejecutas el script SQL (pero requerirá cambio de password)
3. **Método 3:** Creo el código de `DbInitializer.cs` y lo agregas a `Program.cs`

Dime cuál prefieres y te ayudo a completarlo. ??
