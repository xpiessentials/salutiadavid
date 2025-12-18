# Sistema de Usuarios Multi-Tipo - Salutia

## Resumen de Implementación

Se ha implementado un sistema completo de gestión de usuarios con múltiples tipos:
- **SuperAdministrador**: Acceso total al sistema
- **Entidades**: Empresas u organizaciones
- **Independientes**: Personas naturales
- **Miembros de Entidad**: Usuarios creados por entidades

---

## Cambios Realizados

### 1. Modelos de Base de Datos

#### Archivo: `Salutia Wep App/Data/ApplicationUser.cs`

**Clases Creadas:**
- `ApplicationUser` - Usuario base extendido con UserType
- `IndependentUserProfile` - Perfil de usuario independiente
- `EntityUserProfile` - Perfil de entidad
- `EntityMemberProfile` - Perfil de miembro de entidad

**Enums:**
- `UserType` - Tipos de usuario (SuperAdmin, Entity, Independent, EntityMember)
- `DocumentType` - Tipos de documento de identidad

**Campos de Usuario Independiente:**
- Nombre completo
- Tipo de documento (Cédula, Cédula Extranjería, Pasaporte)
- Número de documento
- Email
- Teléfono
- Fecha de nacimiento (opcional)

**Campos de Entidad:**
- Nombre o razón social
- NIT (número de identificación tributaria)
- Dígito de verificación
- Email corporativo
- Teléfono
- Dirección (opcional)
- Representante legal (opcional)
- Colección de miembros

**Campos de Miembro de Entidad:**
- Referencia a la entidad
- Nombre completo
- Tipo y número de documento
- Email
- Teléfono (opcional)
- Cargo/posición (opcional)
- Estado activo

### 2. Context de Base de Datos

#### Archivo: `Salutia Wep App/Data/ApplicationDbContext.cs`

**DbSets Agregados:**
```csharp
DbSet<IndependentUserProfile> IndependentUserProfiles
DbSet<EntityUserProfile> EntityUserProfiles
DbSet<EntityMemberProfile> EntityMemberProfiles
```

**Configuraciones:**
- Relaciones one-to-one entre ApplicationUser y perfiles
- Índices únicos en documentos y NITs
- Restricciones de integridad referencial
- Valores por defecto para fechas

### 3. DTOs y Modelos de Autenticación

#### Archivo: `Salutia Wep App/Models/Auth/AuthModels.cs`

**Clases Creadas:**
- `RegisterRequestBase` - Base para registro
- `RegisterIndependentRequest` - Registro de independiente
- `RegisterEntityRequest` - Registro de entidad
- `RegisterEntityMemberRequest` - Registro de miembro
- `LoginRequest` - Inicio de sesión
- `AuthResponse` - Respuesta de autenticación
- `UserInfo` - Información del usuario autenticado
- `RegistrationType` - Enum para tipos de registro

### 4. Servicio de Gestión de Usuarios

#### Archivo: `Salutia Wep App/Services/UserManagementService.cs`

**Métodos Principales:**

```csharp
// Registro
Task<AuthResponse> RegisterIndependentUserAsync(RegisterIndependentRequest)
Task<AuthResponse> RegisterEntityAsync(RegisterEntityRequest)
Task<AuthResponse> RegisterEntityMemberAsync(RegisterEntityMemberRequest, createdByUserId)

// Autenticación
Task<AuthResponse> LoginAsync(LoginRequest)

// Utilidades
Task<UserInfo> GetUserInfoAsync(ApplicationUser)
Task<List<EntityMemberProfile>> GetEntityMembersAsync(userId)
```

**Validaciones Implementadas:**
- Email único en el sistema
- Documento único para independientes
- NIT único para entidades
- Solo entidades pueden crear miembros
- Verificación de contraseñas
- Asignación automática de roles

### 5. Páginas de Registro

#### Página: `ChooseRegistrationType.razor`
- Selección visual entre Independiente y Entidad
- Diseño con tarjetas interactivas
- Descripción de características de cada tipo

#### Página: `RegisterIndependent.razor`
- Formulario completo para usuarios independientes
- Validaciones en tiempo real
- Selección de tipo de documento
- Campos obligatorios y opcionales claramente marcados

#### Página: `RegisterEntity.razor`
- Formulario para registro de entidades
- Validación de NIT con dígito de verificación
- Campos específicos para empresas
- Información opcional del representante legal

### 6. Configuración del Sistema

#### Archivo: `Salutia Wep App/Program.cs`

**Servicios Registrados:**
```csharp
// Identity con roles
AddIdentityCore<ApplicationUser>()
    .AddRoles<IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()

// Servicio de gestión de usuarios
AddScoped<UserManagementService>()
```

**Roles Creados Automáticamente:**
- SuperAdmin
- Entity
- Independent
- EntityMember

**Configuración de Contraseñas:**
- Longitud mínima: 6 caracteres
- Requiere dígitos: Sí
- Requiere minúsculas: Sí
- Requiere mayúsculas: No
- Requiere caracteres especiales: No

---

## Próximos Pasos

### 1. Crear Migración de Base de Datos

En la **Consola del Administrador de Paquetes** de Visual Studio:

```powershell
Add-Migration MultiUserTypeSystem
Update-Database
```

### 2. Actualizar Página de Login

Crear `Salutia Wep App/Components/Account/Pages/Login.razor` con:
- Campo de email
- Campo de contraseña
- Opción "Recordarme"
- Enlace a registro
- Manejo de diferentes tipos de usuario después del login

### 3. Página de Gestión de Miembros (Para Entidades)

Crear `Components/Account/Pages/ManageEntityMembers.razor` con:
- Lista de miembros de la entidad
- Botón para agregar nuevo miembro
- Opciones para activar/desactivar miembros
- Edición de información de miembros

### 4. Dashboard por Tipo de Usuario

Crear dashboards específicos:
- **SuperAdmin**: Panel de administración total
- **Entity**: Panel con lista de miembros y estadísticas
- **Independent**: Panel personal
- **EntityMember**: Panel con información limitada

### 5. Página de Confirmación de Email

Crear `Components/Account/Pages/RegisterConfirmation.razor` que:
- Muestre mensaje de confirmación
- Instrucciones para verificar email
- Opción para reenviar email de confirmación

### 6. Middleware de Autorización

Implementar políticas de autorización:

```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("SuperAdminOnly", policy => 
        policy.RequireRole("SuperAdmin"));
    
    options.AddPolicy("EntityOnly", policy => 
        policy.RequireRole("Entity"));
    
    options.AddPolicy("EntityOrSuperAdmin", policy => 
        policy.RequireRole("Entity", "SuperAdmin"));
});
```

### 7. API Controllers para Mobile App

Actualizar controllers en `Salutia Wep App/Controllers/`:
- AuthController con endpoints de registro y login
- EntityController para gestión de miembros
- ProfileController para gestión de perfil

---

## Estructura de Base de Datos

### Tabla: AspNetUsers (Identity)
- Id (PK)
- Email
- UserName
- PasswordHash
- **UserType** (nuevo)
- **IsActive** (nuevo)
- **CreatedAt** (nuevo)

### Tabla: IndependentUserProfiles
- Id (PK)
- ApplicationUserId (FK a AspNetUsers)
- FullName
- DocumentType
- DocumentNumber (Unique)
- Phone
- DateOfBirth
- Address

### Tabla: EntityUserProfiles
- Id (PK)
- ApplicationUserId (FK a AspNetUsers)
- BusinessName
- TaxId (NIT) (Unique)
- VerificationDigit
- Phone
- Address
- Website
- LegalRepresentative

### Tabla: EntityMemberProfiles
- Id (PK)
- ApplicationUserId (FK a AspNetUsers)
- **EntityId (FK a EntityUserProfiles)**
- FullName
- DocumentType
- DocumentNumber
- Position
- Phone
- JoinedAt
- IsActive

---

## Flujos de Usuario

### Flujo de Registro - Usuario Independiente

1. Usuario accede a `/Account/ChooseRegistrationType`
2. Selecciona "Usuario Independiente"
3. Completa formulario en `/Account/RegisterIndependent`
4. Sistema valida:
   - Email único
   - Documento único
   - Contraseñas coinciden
5. Crea ApplicationUser + IndependentUserProfile
6. Asigna rol "Independent"
7. Redirige a confirmación de email

### Flujo de Registro - Entidad

1. Usuario accede a `/Account/ChooseRegistrationType`
2. Selecciona "Entidad"
3. Completa formulario en `/Account/RegisterEntity`
4. Sistema valida:
   - Email único
   - NIT único
   - Dígito de verificación correcto
5. Crea ApplicationUser + EntityUserProfile
6. Asigna rol "Entity"
7. Redirige a confirmación de email

### Flujo de Creación de Miembro (Por Entidad)

1. Entidad inicia sesión
2. Accede a panel de gestión de miembros
3. Clic en "Agregar Miembro"
4. Completa formulario de miembro
5. Sistema valida:
   - Usuario creador es Entidad
   - Email único
   - Documento único dentro de la entidad
6. Crea ApplicationUser + EntityMemberProfile
7. Asigna rol "EntityMember"
8. Vincula miembro a la entidad
9. Envía email al nuevo miembro

### Flujo de Login

1. Usuario accede a `/Account/Login`
2. Ingresa email y contraseña
3. Sistema valida credenciales
4. Obtiene UserType del usuario
5. Carga perfil correspondiente:
   - Independent ? IndependentUserProfile
   - Entity ? EntityUserProfile
   - EntityMember ? EntityMemberProfile + Entity
6. Redirige a dashboard apropiado

---

## Seguridad Implementada

? **Contraseñas Hasheadas**: ASP.NET Identity
? **Validación de Email**: Confirmación requerida
? **Roles y Permisos**: Role-based authorization
? **Integridad Referencial**: Foreign keys y restricciones
? **Índices Únicos**: Email, documento, NIT
? **Bloqueo de Cuenta**: Después de intentos fallidos
? **Tokens de Confirmación**: Para verificación de email
? **Two-Factor Authentication**: Preparado (sistema de QR ya implementado)

---

## Pruebas Recomendadas

### Registro de Usuario Independiente
- [ ] Registro exitoso con datos válidos
- [ ] Error con email duplicado
- [ ] Error con documento duplicado
- [ ] Error con contraseñas que no coinciden
- [ ] Validación de formato de email
- [ ] Validación de teléfono

### Registro de Entidad
- [ ] Registro exitoso con NIT válido
- [ ] Error con NIT duplicado
- [ ] Validación de dígito de verificación
- [ ] Error con email duplicado
- [ ] Formato correcto de datos corporativos

### Gestión de Miembros
- [ ] Entidad puede crear miembros
- [ ] Independiente NO puede crear miembros
- [ ] Miembro vinculado correctamente a entidad
- [ ] Lista de miembros visible para entidad
- [ ] Activar/desactivar miembros

### Login
- [ ] Login exitoso para cada tipo
- [ ] Redirección correcta según tipo
- [ ] Error con credenciales incorrectas
- [ ] Bloqueo después de múltiples intentos
- [ ] Recordarme funciona correctamente

---

## Archivos Modificados

### Nuevos Archivos Creados:
1. `Data/ApplicationUser.cs` - Modelos extendidos
2. `Models/Auth/AuthModels.cs` - DTOs de autenticación
3. `Services/UserManagementService.cs` - Lógica de negocio
4. `Components/Account/Pages/ChooseRegistrationType.razor`
5. `Components/Account/Pages/RegisterIndependent.razor`
6. `Components/Account/Pages/RegisterEntity.razor`

### Archivos Modificados:
1. `Data/ApplicationDbContext.cs` - DbSets y configuraciones
2. `Program.cs` - Registro de servicios y roles

---

## Comandos Útiles

### Crear Migración
```powershell
Add-Migration MultiUserTypeSystem -Project "Salutia Wep App"
```

### Aplicar Migración
```powershell
Update-Database -Project "Salutia Wep App"
```

### Revertir Migración
```powershell
Update-Database -Migration:0 -Project "Salutia Wep App"
Remove-Migration -Project "Salutia Wep App"
```

### Ver Migraciones Aplicadas
```powershell
Get-Migration -Project "Salutia Wep App"
```

---

## Notas Importantes

?? **Antes de Ejecutar en Producción:**
1. Crear y aplicar la migración de base de datos
2. Configurar un servicio real de email (actualmente usa IdentityNoOpEmailSender)
3. Ajustar políticas de contraseña según requisitos
4. Implementar logging adecuado
5. Configurar HTTPS en producción
6. Revisar políticas de CORS

? **Completado:**
- Estructura de base de datos multi-usuario
- Modelos y relaciones
- Servicio de gestión de usuarios
- Páginas de registro para Independientes y Entidades
- Sistema de roles
- Validaciones de negocio
- Compilación exitosa

? **Pendiente:**
- Página de Login actualizada
- Página de gestión de miembros (para entidades)
- Dashboards específicos por tipo de usuario
- API controllers para mobile app
- Página de confirmación de email
- Panel de superadministrador
- Tests unitarios

---

¿Necesitas que implemente alguna de las funcionalidades pendientes?
