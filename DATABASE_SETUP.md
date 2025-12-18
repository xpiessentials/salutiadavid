# Configuración de la Base de Datos Salutia

## Resumen
La aplicación Salutia está configurada para usar **SQL Server Express local** (LAPTOP-DAVID\SQLEXPRESS). La base de datos se llama **Salutia** y se almacena localmente en tu equipo de desarrollo.

## Configuración Actual

### Servidor SQL Server
- **Instancia**: `LAPTOP-DAVID\SQLEXPRESS`
- **Base de datos**: `Salutia`
- **Autenticación**: Windows Authentication (Trusted_Connection=True)

### AppHost (Salutia.AppHost\AppHost.cs)
- Configurado con SQL Server Express local
- La cadena de conexión apunta directamente a tu instancia local
- No usa contenedores Docker

### Aplicación Blazor (Salutia Wep App)
- Usa Entity Framework Core con SQL Server
- Configurada con Identity para autenticación
- Las migraciones de Identity ya están creadas

## Cómo Crear y Aplicar Migraciones

### 1. Crear la Base de Datos (Primera Vez)
Antes de aplicar migraciones, asegúrate de que SQL Server Express esté en ejecución:

```powershell
# Verificar que el servicio SQL Server Express esté corriendo
Get-Service -Name "MSSQL$SQLEXPRESS"

# Si no está corriendo, inícialo
Start-Service -Name "MSSQL$SQLEXPRESS"
```

### 2. Aplicar las Migraciones Existentes de Identity
```powershell
# Desde la raíz del proyecto
dotnet ef database update --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

### 3. Crear Nuevas Migraciones
Cuando agregues nuevas entidades o modifiques el DbContext, ejecuta:

```powershell
dotnet ef migrations add NombreDeLaMigracion --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

### 4. Ver el Estado de las Migraciones
```powershell
dotnet ef migrations list --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

### 5. Revertir una Migración
```powershell
dotnet ef database update NombreDeLaMigracionAnterior --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

### 6. Eliminar la Última Migración (si no se ha aplicado)
```powershell
dotnet ef migrations remove --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

## Estructura de la Base de Datos

### Tablas Actuales (Identity)
La base de datos actualmente incluye las siguientes tablas de ASP.NET Core Identity:
- `AspNetUsers` - Usuarios del sistema
- `AspNetRoles` - Roles de usuario
- `AspNetUserRoles` - Relación usuarios-roles
- `AspNetUserClaims` - Claims de usuarios
- `AspNetUserLogins` - Logins externos
- `AspNetUserTokens` - Tokens de usuario
- `AspNetRoleClaims` - Claims de roles

### Agregar Nuevas Tablas

#### Paso 1: Crear las Entidades
Crea tus clases de entidad en la carpeta `Salutia Wep App\Data\` o en una subcarpeta `Models\`:

```csharp
public class Paciente
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Apellido { get; set; } = string.Empty;
    public DateTime FechaNacimiento { get; set; }
    // ... más propiedades
}
```

#### Paso 2: Agregar al DbContext
Edita `Salutia Wep App\Data\ApplicationDbContext.cs`:

```csharp
public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) 
        : base(options)
    {
    }

    // Agregar DbSets para tus entidades
    public DbSet<Paciente> Pacientes { get; set; }
    
    protected override void OnModelCreating(ModelBuilder builder)
    {
    base.OnModelCreating(builder);
        
      // Configurar relaciones y restricciones aquí
   builder.Entity<Paciente>(entity =>
        {
            entity.HasKey(e => e.Id);
  entity.Property(e => e.Nombre).IsRequired().HasMaxLength(100);
  // ... más configuraciones
     });
    }
}
```

#### Paso 3: Crear y Aplicar Migración
```powershell
dotnet ef migrations add AgregarTablaPacientes --project "Salutia Wep App" --startup-project "Salutia Wep App"
dotnet ef database update --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

## Ejecutar la Aplicación con .NET Aspire

### Opción 1: Desde Visual Studio
1. Establece `Salutia.AppHost` como proyecto de inicio
2. Presiona F5 o haz clic en el botón de ejecutar
3. Se abrirá el Dashboard de Aspire en tu navegador
4. Desde allí puedes ver y acceder a tu aplicación

### Opción 2: Desde la línea de comandos
```powershell
dotnet run --project "Salutia.AppHost\Salutia.AppHost.csproj"
```

## Conexión Directa a la Base de Datos

Puedes conectarte directamente a SQL Server Express usando:

**Cadena de conexión:**
```
Server=LAPTOP-DAVID\SQLEXPRESS;Database=Salutia;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True
```

**Desde SQL Server Management Studio (SSMS):**
- Server name: `LAPTOP-DAVID\SQLEXPRESS`
- Authentication: Windows Authentication
- Database: `Salutia`

**Desde Visual Studio:**
- SQL Server Object Explorer
- Add SQL Server ? `LAPTOP-DAVID\SQLEXPRESS`

## Consejos y Mejores Prácticas

1. **Siempre crea una migración antes de modificar la base de datos**
2. **Usa nombres descriptivos para las migraciones** (ej: `AgregarTablaPacientes`, `AgregarCampoTelefonoAPaciente`)
3. **Revisa el código de la migración** antes de aplicarla para asegurarte de que es correcto
4. **Haz backup de tu base de datos** antes de aplicar migraciones en producción
5. **Usa `OnModelCreating`** para configurar restricciones, índices y relaciones
6. **Mantén las entidades en archivos separados** para mejor organización

## Solución de Problemas

### Error: "No se pudo conectar a la base de datos"
1. Verifica que SQL Server Express esté en ejecución:
```powershell
Get-Service -Name "MSSQL$SQLEXPRESS"
```

2. Si no está corriendo, inícialo:
```powershell
Start-Service -Name "MSSQL$SQLEXPRESS"
```

3. Verifica la conectividad con SQLCMD:
```powershell
sqlcmd -S LAPTOP-DAVID\SQLEXPRESS -E -Q "SELECT @@VERSION"
```

### Error: "Login failed for user"
- Asegúrate de tener permisos en SQL Server Express
- Verifica que Windows Authentication esté habilitada
- Intenta conectarte con SQL Server Management Studio primero

### Error: "La base de datos ya existe"
Si necesitas recrear la base de datos desde cero:
```powershell
dotnet ef database drop --project "Salutia Wep App" --startup-project "Salutia Wep App"
dotnet ef database update --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

### Error en las migraciones
```powershell
# Ver el error detallado
dotnet ef database update --verbose --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

### Verificar que SQL Server Express esté instalado y configurado
```powershell
# Listar todas las instancias de SQL Server
Get-Service -Name "MSSQL*" | Select-Object Name, Status, DisplayName

# Ver la configuración de red de SQL Server Express
sqlcmd -S LAPTOP-DAVID\SQLEXPRESS -E -Q "EXEC sp_configure 'show advanced options', 1; RECONFIGURE; EXEC sp_configure;"
```

## Próximos Pasos

1. ? **Base de datos configurada** - La infraestructura está lista con SQL Server Express
2. ?? **Aplicar migraciones iniciales** - Ejecuta `dotnet ef database update`
3. ?? **Crear entidades de dominio** - Define tus modelos de negocio
4. ?? **Crear migraciones** - Genera las tablas en la base de datos
5. ?? **Implementar repositorios** - Crea servicios para acceder a los datos
6. ?? **Crear componentes Blazor** - Construye la interfaz de usuario

## Recursos Adicionales

- [Documentación de Entity Framework Core](https://docs.microsoft.com/ef/core/)
- [Migraciones en EF Core](https://docs.microsoft.com/ef/core/managing-schemas/migrations/)
- [.NET Aspire](https://learn.microsoft.com/dotnet/aspire/)
- [ASP.NET Core Identity](https://docs.microsoft.com/aspnet/core/security/authentication/identity)
- [SQL Server Express](https://docs.microsoft.com/sql/sql-server/editions-and-components-of-sql-server-2019)
