# ?? Guía de Permisos y Gestión de Usuarios - Salutia

## Jerarquía de Roles y Permisos

### 1. SuperAdmin (Administrador del Sistema)
**Permisos Completos:**
- ? Gestiona **TODOS** los usuarios del sistema
- ? Crea y administra **Entidades**
- ? Asigna y gestiona **Profesionales** para cualquier entidad
- ? Ve **todos los pacientes** de todas las entidades
- ? Acceso a reportes globales del sistema
- ? Gestiona configuración del sistema

**Rutas Disponibles:**
```
/Admin/Dashboard          - Panel de administración
/Admin/Users              - Gestionar todos los usuarios
/Admin/Entities           - Gestionar entidades
/Admin/AddProfessional    - Agregar profesional a cualquier entidad
/Admin/Reports            - Reportes del sistema
```

---

### 2. EntityAdmin (Administrador de Entidad)
**Permisos de Entidad:**
- ? Gestiona **Profesionales** de su propia entidad
- ? Gestiona **todos los Pacientes** de su entidad (de todos sus profesionales)
- ? Asigna pacientes a sus profesionales
- ? Ve estadísticas de su entidad
- ? NO puede ver/gestionar otras entidades
- ? NO puede gestionar pacientes de otras entidades

**Rutas Disponibles:**
```
/Entity/Dashboard               - Dashboard de su entidad
/Entity/ManageProfessionals     - Ver y gestionar sus profesionales
/Entity/AddProfessional         - Agregar profesional a su entidad
/Entity/Professional/{id}       - Ver detalles del profesional
/Entity/AddPatient/{profId}     - Agregar paciente para un profesional
/Entity/Patient/{id}            - Ver detalles de cualquier paciente de su entidad
/Entity/Reports                 - Reportes de su entidad
```

**Restricciones de Seguridad:**
```csharp
// Validación en el código:
var entityProfile = await DbContext.EntityUserProfiles
    .FirstOrDefaultAsync(e => e.ApplicationUserId == currentUser.Id);

// Solo carga profesionales de SU entidad
var professionals = await DbContext.EntityProfessionalProfiles
    .Where(p => p.EntityId == entityProfile.Id)
    .ToListAsync();
```

---

### 3. Professional (Médico/Psicólogo - Miembro de Entidad)
**Permisos Limitados a Sus Pacientes:**
- ? Gestiona **SOLO sus propios pacientes**
- ? Registra nuevos pacientes asignados a él
- ? Ve historial y test de sus pacientes
- ? Genera reportes de sus pacientes
- ? NO puede ver pacientes de otros profesionales
- ? NO puede gestionar otros profesionales
- ? NO puede ver información de la entidad

**Rutas Disponibles:**
```
/Professional/Dashboard         - Dashboard personal
/Professional/ManagePatients    - Ver SOLO sus pacientes
/Professional/AddPatient        - Registrar nuevo paciente asignado a él
/Professional/Patient/{id}      - Ver detalles de SU paciente
```

**Restricciones de Seguridad:**
```csharp
// Validación estricta en el código:
var professionalProfile = await DbContext.EntityProfessionalProfiles
    .FirstOrDefaultAsync(p => p.ApplicationUserId == currentUser.Id);

// SOLO carga sus propios pacientes
var patients = await DbContext.PatientProfiles
    .Where(p => p.ProfessionalId == professionalProfile.Id)
    .ToListAsync();

// Validación al ver detalles de un paciente:
var patient = await DbContext.PatientProfiles
    .FirstOrDefaultAsync(p => 
        p.Id == patientId && 
        p.ProfessionalId == professionalProfile.Id); // ?? Crítico

if (patient == null)
{
    // Redirigir o mostrar error 403 Forbidden
    return;
}
```

---

### 4. Patient (Paciente de Entidad)
**Permisos Personales:**
- ? Completa su perfil en el primer inicio de sesión
- ? Realiza el **Test Psicosomático** (una vez completado el perfil)
- ? Ve sus propios resultados
- ? Accede a sus reportes personales
- ? NO puede ver otros pacientes
- ? NO puede ver información de profesionales
- ? NO puede gestionar su cuenta (solo su perfil)

**Rutas Disponibles:**
```
/Patient/CompleteProfile     - Completar perfil (primer login)
/Patient/Dashboard           - Dashboard personal
/test-psicosomatico          - Realizar test (si perfil completado)
/Patient/Results             - Ver resultados del test
```

**Flujo de Primer Login:**
```
1. Professional registra paciente ? Usuario=Documento, Password=Documento
2. Paciente inicia sesión con documento
3. Sistema detecta ProfileCompleted=false
4. Redirección automática a /Patient/CompleteProfile
5. Paciente completa información obligatoria
6. ProfileCompleted=true ? Acceso al Dashboard y Test
```

---

### 5. Independent (Usuario Independiente)
**Permisos Personales:**
- ? Se registra por sí mismo
- ? Gestiona su propio perfil
- ? Realiza el **Test Psicosomático** sin restricciones
- ? Ve sus propios resultados
- ? NO está asociado a ninguna entidad
- ? NO tiene profesional asignado

**Rutas Disponibles:**
```
/User/Dashboard              - Dashboard personal
/test-psicosomatico          - Realizar test
/User/Results                - Ver resultados
```

---

## ?? Matriz de Permisos

| Acción | SuperAdmin | EntityAdmin | Professional | Patient | Independent |
|--------|------------|-------------|--------------|---------|-------------|
| Ver todos los usuarios | ? | ? | ? | ? | ? |
| Gestionar entidades | ? | ? | ? | ? | ? |
| Ver todos los profesionales | ? | ? (Su entidad) | ? | ? | ? |
| Agregar profesional | ? | ? (A su entidad) | ? | ? | ? |
| Ver todos los pacientes | ? | ? (Su entidad) | ? (Solo suyos) | ? | ? |
| Agregar paciente | ? | ? | ? (A él mismo) | ? | ? |
| Realizar test | ? | ? | ? | ? | ? |
| Ver su propio perfil | ? | ? | ? | ? | ? |
| Generar reportes | ? (Todos) | ? (Su entidad) | ? (Sus pacientes) | ? (Propio) | ? (Propio) |

---

## ??? Implementación de Seguridad en el Código

### Validación en EntityAdmin (Ejemplo)
```csharp
// En Entity/Professional/{id}
private async Task LoadProfessionalAsync()
{
    var entityProfile = await DbContext.EntityUserProfiles
        .FirstOrDefaultAsync(e => e.ApplicationUserId == currentUser.Id);

    // ?? CRÍTICO: Solo cargar profesionales de SU entidad
    professional = await DbContext.EntityProfessionalProfiles
        .FirstOrDefaultAsync(p => 
            p.Id == ProfessionalId && 
            p.EntityId == entityProfile.Id); // <-- Validación de pertenencia

    if (professional == null)
    {
        // El profesional no existe o no pertenece a esta entidad
        Navigation.NavigateTo("/Entity/Dashboard");
        return;
    }
}
```

### Validación en Professional (Ejemplo)
```csharp
// En Professional/Patient/{id}
private async Task LoadPatientAsync()
{
    var professionalProfile = await DbContext.EntityProfessionalProfiles
        .FirstOrDefaultAsync(p => p.ApplicationUserId == currentUser.Id);

    // ?? CRÍTICO: Solo cargar pacientes de ESTE profesional
    patient = await DbContext.PatientProfiles
        .FirstOrDefaultAsync(p => 
            p.Id == PatientId && 
            p.ProfessionalId == professionalProfile.Id); // <-- Validación de propiedad

    if (patient == null)
    {
        // El paciente no existe o no pertenece a este profesional
        Navigation.NavigateTo("/Professional/ManagePatients");
        return;
    }
}
```

---

## ?? Flujos de Gestión

### Flujo 1: SuperAdmin crea Profesional
```
1. SuperAdmin ? /Admin/AddProfessional
2. Selecciona Entidad del dropdown
3. Ingresa datos del profesional
4. Sistema crea usuario con rol Doctor/Psychologist
5. Profesional recibe credenciales por email
6. Profesional puede iniciar sesión y gestionar pacientes
```

### Flujo 2: EntityAdmin crea Profesional
```
1. EntityAdmin ? /Entity/AddProfessional
2. Sistema detecta automáticamente su entidad
3. Ingresa datos del profesional
4. Sistema asigna profesional a SU entidad
5. Profesional queda vinculado automáticamente
6. EntityAdmin puede ver el profesional en su lista
```

### Flujo 3: Professional registra Paciente
```
1. Professional ? /Professional/AddPatient
2. Ingresa: Tipo Doc, Número Doc, Email
3. Sistema crea:
   - Usuario con username=documento, password=documento
   - PatientProfile con ProfessionalId=profesional actual
   - IsEntityPatient=true, ProfileCompleted=false
4. Paciente recibe credenciales
5. En primer login ? /Patient/CompleteProfile
6. Después ? Acceso completo
```

### Flujo 4: EntityAdmin ve Paciente de Profesional
```
1. EntityAdmin ? /Entity/ManageProfessionals
2. Clic en profesional ? /Entity/Professional/{id}
3. Ve lista de pacientes del profesional
4. Puede agregar más pacientes al profesional
5. Puede ver detalles de cualquier paciente de su entidad
```

---

## ? Archivos Implementados

### Componentes Creados:
- ? `/Professional/ManagePatients.razor` - Lista de pacientes del profesional
- ? `/Professional/AddPatient.razor` - Registrar paciente
- ? `/Entity/ManageProfessionals.razor` - Lista de profesionales de entidad
- ? `/Entity/AddProfessional.razor` - Agregar profesional
- ? `/Entity/AddEntityPatient.razor` - Agregar paciente por entidad
- ? `/Patient/CompleteProfile.razor` - Completar perfil obligatorio

### Servicios Creados:
- ? `PatientRegistrationService.cs` - Registro de pacientes de entidad
- ? `CustomAuthenticationService.cs` - Autenticación con documento

### Seguridad Implementada:
- ? Atributo `[Authorize(Roles = "...")]` en cada componente
- ? Validación de propiedad de datos en cada consulta
- ? Filtrado por EntityId y ProfessionalId
- ? Redirecciones en caso de acceso no autorizado

---

## ?? Próximos Pasos Recomendados

1. **Crear Dashboard para Patient** - Visualización personalizada
2. **Implementar vista de detalles de paciente** para Professional
3. **Agregar sistema de notificaciones** cuando paciente completa test
4. **Crear reportes diferenciados** por rol
5. **Implementar auditoría** de accesos a datos sensibles

---

**Última actualización:** 2025-01-25
**Versión del sistema:** 1.0
**Estado:** ? Completado y Compilado
