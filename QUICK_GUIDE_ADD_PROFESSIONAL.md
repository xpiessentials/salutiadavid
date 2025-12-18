# ?? GUÍA RÁPIDA - Agregar Profesionales

## ? IMPLEMENTACIÓN COMPLETA

Tanto **SuperAdmin** como **EntityAdmin** ya pueden agregar profesionales.

---

## ?? RUTAS DISPONIBLES

### SuperAdmin:
- **Menú**: "Agregar Profesional"
- **Ruta**: `/Admin/AddProfessional`
- **Característica**: Selecciona la entidad a la que pertenece el profesional

### EntityAdmin:
- **Menú**: "Agregar Profesional"
- **Ruta**: `/Entity/AddProfessional`
- **Característica**: Crea profesionales automáticamente para su entidad

---

## ?? ANTES DE USAR

### 1. Ejecutar Migraciones SQL (Si no lo has hecho)

**En SQL Server Management Studio:**

1. Ejecutar `UpdateToNewUserSystem.sql`
2. Ejecutar `UpdateUserRoles.sql`

### 2. Reiniciar Aplicación

```powershell
cd "Salutia Wep App"
dotnet run
```

---

## ?? USO RÁPIDO

### Como SuperAdmin:

1. Login como SuperAdmin
2. Menú ? "Agregar Profesional"
3. **Seleccionar Entidad** en el dropdown
4. Llenar formulario
5. Clic en "Agregar Profesional"

### Como EntityAdmin:

1. Login como EntityAdmin
2. Menú ? "Agregar Profesional"
3. Llenar formulario (sin seleccionar entidad)
4. Clic en "Agregar Profesional"

---

## ?? CAMPOS DEL FORMULARIO

### Obligatorios (*):
- **[SuperAdmin]** Entidad *
- Nombre Completo *
- Tipo de Profesional * (Médico/Psicólogo)
- Especialidad *
- Licencia Profesional *
- Tipo de Documento *
- Número de Documento *
- Email *
- Contraseña *
- Confirmar Contraseña *

### Opcionales:
- Teléfono
- País, Estado, Ciudad
- Dirección

---

## ? VERIFICACIÓN

### Después de crear un profesional:

**SuperAdmin**:
- Redirige a `/Admin/Users`
- Busca el email del profesional creado
- Debe aparecer con tipo "Doctor" o "Psychologist"

**EntityAdmin**:
- Redirige a `/Entity/ManageProfessionals`
- El profesional debe aparecer en la lista
- Estado: Activo

### En la Base de Datos:

```sql
-- Ver profesionales creados
SELECT 
 ep.FullName,
  ep.Specialty,
    ep.ProfessionalLicense,
    u.Email,
 u.UserType,
    e.BusinessName as Entidad
FROM EntityProfessionalProfiles ep
INNER JOIN AspNetUsers u ON ep.ApplicationUserId = u.Id
INNER JOIN EntityUserProfiles e ON ep.EntityId = e.Id;

-- Ver roles asignados
SELECT u.Email, r.Name as Role
FROM AspNetUsers u
INNER JOIN AspNetUserRoles ur ON u.Id = ur.UserId
INNER JOIN AspNetRoles r ON ur.RoleId = r.Id
WHERE u.UserType IN (3, 4); -- Doctor (3), Psychologist (4)
```

---

## ?? SOLUCIÓN DE PROBLEMAS

### Error: "Debes especificar la entidad..."
**Solución**: SuperAdmin debe seleccionar una entidad en el dropdown

### Error: "El email ya está registrado"
**Solución**: Usa un email diferente, ese ya existe en el sistema

### Error: "Ya existe un profesional con ese número de documento..."
**Solución**: Ese documento ya está registrado para un profesional en esa entidad

### No aparece el dropdown de entidades (SuperAdmin)
**Solución**: Verifica que existan entidades registradas en `EntityUserProfiles`

### Build falla: "archivo en uso"
**Solución**: Detén la aplicación (Ctrl+C) antes de compilar

---

## ?? FLUJO COMPLETO

```
SuperAdmin           Sistema           Base de Datos
    |       |           |
    |-- Selecciona Entidad ------>|    |
    |-- Llena Formulario -------->|    |
    |-- Submit ------------------>|        |
  |    |-- Valida Email ----------->|
    |      |<-- Email OK --------------|
    |          |-- Valida Documento ------->|
    |   |<-- Doc OK ----------------|
    |           |-- Crea User ------------->|
    |           |-- Crea Profile ----------->|
    |          |-- Asigna Rol ------------->|
    |<-- Éxito -------------------|           |
    |-- Redirige a Users   |             |


EntityAdmin       Sistema   Base de Datos
    |                  |      |
    |-- Llena Formulario -------->|         |
    |-- Submit ------------------>|       |
    ||-- Obtiene EntityId ------->|
    |       |-- Valida Email ----------->|
    |        |<-- Email OK --------------|
    |          |-- Valida Documento ------->|
    |          |<-- Doc OK ----------------|
    |           |-- Crea User ------------->|
    |           |-- Crea Profile ----------->|
    |         |-- Asigna Rol ------------->|
    |<-- Éxito -------------------|        |
|-- Redirige a Professionals  |       |
```

---

## ?? RESULTADO ESPERADO

Después de registrar un profesional:

1. ? Usuario creado en `AspNetUsers`
2. ? Perfil creado en `EntityProfessionalProfiles`
3. ? Rol asignado (`Doctor` o `Psychologist`)
4. ? Puede iniciar sesión con el email y contraseña
5. ? Aparece en la lista de profesionales
6. ? Tiene acceso a su dashboard correspondiente

---

## ?? AYUDA ADICIONAL

Para más detalles, consulta:
- `PROFESSIONAL_REGISTRATION_COMPLETE.md` - Documentación completa
- `EJECUTAR_MIGRACION_RAPIDO.md` - Guía de migraciones
- `SOLUCION_ERROR_404.md` - Solución de problemas comunes

---

¡Listo para usar! ??
