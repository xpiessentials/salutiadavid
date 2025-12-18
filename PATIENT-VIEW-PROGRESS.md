# ?? Vista Unificada de Paciente - En Progreso

## ?? **Estado: 60% Completado**

---

## ? **Lo que se Creó:**

### **Archivo Principal:**
`Components/Pages/Shared/ViewPatient.razor` (~650 líneas)

**Ruta:** `/ViewPatient/{TestId:int}`

---

## ?? **Características Implementadas:**

### **1. Control de Acceso (CRÍTICO)**

#### **Reglas de Negocio:**
```
? Profesional ? Solo tests que ÉL asignó al paciente
? Entidad ? Todos los pacientes de SU entidad
? Sin acceso ? Mensaje de error
```

#### **Validación Implementada:**
```csharp
private async Task<bool> ValidateAccessAsync()
{
    if (isProfessional)
    {
        // Profesional solo ve pacientes de su entidad
        // TODO: Validar relación específica Professional-Patient-Test
        var professional = await DbContext.Professionals
            .FirstOrDefaultAsync(p => p.ApplicationUserId == currentUserId);
        
        return professional.EntityId == patientProfile.EntityId;
    }
    else if (isEntity)
    {
        // Entidad ve todos los pacientes de su entidad
        var entity = await DbContext.Entities
            .FirstOrDefaultAsync(e => e.ApplicationUserId == currentUserId);
        
        return entity.Id == patientProfile.EntityId;
    }
    
    return false;
}
```

---

### **2. Header del Paciente**

**Información Mostrada:**
- ? Avatar circular
- ? Nombre completo
- ? Documento (tipo + número)
- ? Fecha de nacimiento
- ? Test ID
- ? Estado del test (Completado/En Progreso)
- ? Breadcrumb navigation

---

### **3. Tarjetas de Información**

#### **Información Personal:**
- Edad (calculada)
- Sexo ? **PENDIENTE CORRECCIÓN** (usar `Gender`)
- Email ? **PENDIENTE CORRECCIÓN** (viene de `ApplicationUser`)
- Teléfono

#### **Información Laboral:** ? **PENDIENTE**
- Entidad (ya disponible)
- Cargo ? **NO EXISTE EN MODELO**
- Área ? **NO EXISTE EN MODELO**
- Antigüedad ? **NO EXISTE EN MODELO**

#### **Información Médica:** ? **PENDIENTE**
- EPS ? **NO EXISTE EN MODELO**
- ARL ? **NO EXISTE EN MODELO**
- Contacto Emergencia ? **Usar `EmergencyContacts` collection**
- Tel. Emergencia ? **Usar `EmergencyContacts` collection**

#### **Estado de Documentos:**
- ? Perfil completo/incompleto
- ? Consentimientos (firmados vs requeridos)
- ? Test (completado vs en progreso)

---

### **4. Sistema de Tabs**

#### **Tab 1: Consentimientos Informados** ?
**Estado:** Funcional

**Características:**
- ? Lista de consentimientos con cards
- ? Badge de estado (Firmado/No Firmado)
- ? Información de firma digital
- ? Vista expandible del contenido HTML
- ? Botón descargar PDF individual
- ? Botón generar/descargar paquete completo
- ? Registro de auditoría de descargas
- ? Metadata (IP, fecha, versión)

**Diseño:**
- Grid responsivo (2 columnas en desktop)
- Cards con bordes de color según estado
- Vista previa de firma digital
- Información de auditoría colapsable

#### **Tab 2: Resultados del Test** ??
**Estado:** Placeholder

**Características Actuales:**
- ? Mensaje de "En Progreso" si test no completado
- ? Placeholder de informe si completado
- ? Botón "Descargar Informe" (deshabilitado)

**Por Implementar:**
- [ ] Generación de informe de resultados
- [ ] Visualización de análisis psicosomático
- [ ] Gráficos de resultados
- [ ] Recomendaciones
- [ ] Descarga de PDF del informe

---

## ?? **Errores a Corregir:**

### **Errores de Compilación:**

#### **1. Campos del PatientProfile:**
```csharp
// ERRORES:
patientProfile.BirthDate    ? Usar: DateOfBirth
patientProfile.Sex          ? Usar: Gender
patientProfile.Email        ? Usar: ApplicationUser?.Email
patientProfile.Position     ? NO EXISTE (eliminar o agregar)
patientProfile.WorkArea     ? NO EXISTE (eliminar o agregar)
patientProfile.YearsOfService ? NO EXISTE (eliminar o agregar)
patientProfile.EPS          ? NO EXISTE (eliminar o agregar)
patientProfile.ARL          ? NO EXISTE (eliminar o agregar)
patientProfile.EmergencyContactName  ? Usar: EmergencyContacts.FirstOrDefault()?.FullName
patientProfile.EmergencyContactPhone ? Usar: EmergencyContacts.FirstOrDefault()?.PhoneNumber
```

#### **2. PatientConsents.razor:**
```csharp
// ERROR en línea 386:
.Include(t => t.Patient)  // NO EXISTE esta navegación

// SOLUCIÓN:
// No incluir Patient, cargar por separado con PatientUserId
```

#### **3. Profesionales y Entidades:**
```csharp
// ERROR:
DbContext.Professionals     // NO EXISTE este DbSet
DbContext.Entities          // NO EXISTE este DbSet

// DEBEN SER:
DbContext.EntityProfessionalProfiles
DbContext.EntityUserProfiles  // (para entidades)
```

---

## ?? **Correcciones Necesarias:**

### **Archivo: ViewPatient.razor**

```razor
<!-- CORRECCIÓN 1: Información Personal -->
<p class="mb-2">
    <strong>Edad:</strong> @CalculateAge(patientProfile.DateOfBirth) años
</p>
<p class="mb-2">
    <strong>Sexo:</strong> @patientProfile.Gender
</p>
<p class="mb-2">
    <strong>Email:</strong> @patientProfile.ApplicationUser?.Email
</p>

<!-- CORRECCIÓN 2: Información Laboral (Simplificada) -->
<div class="col-md-3">
    <div class="card h-100">
        <div class="card-body">
            <h6 class="text-muted mb-3">
                <i class="bi bi-briefcase"></i> Información Laboral
            </h6>
            <p class="mb-2">
                <strong>Entidad:</strong> @(patientProfile.Entity?.BusinessName ?? "N/A")
            </p>
            <p class="mb-2">
                <strong>Profesional Asignado:</strong> @(patientProfile.Professional?.FullName ?? "N/A")
            </p>
            <p class="mb-2">
                <strong>Ocupación:</strong> @(patientProfile.Occupation?.Name ?? "N/A")
            </p>
        </div>
    </div>
</div>

<!-- CORRECCIÓN 3: Información Médica (Simplificada) -->
<div class="col-md-3">
    <div class="card h-100">
        <div class="card-body">
            <h6 class="text-muted mb-3">
                <i class="bi bi-heart-pulse"></i> Información Médica
            </h6>
            @{
                var emergency = patientProfile.EmergencyContacts.FirstOrDefault();
            }
            @if (emergency != null)
            {
                <p class="mb-2">
                    <strong>Contacto Emergencia:</strong> @emergency.FullName
                </p>
                <p class="mb-2">
                    <strong>Relación:</strong> @emergency.Relationship
                </p>
                <p class="mb-2">
                    <strong>Teléfono:</strong> @emergency.PhoneNumber
                </p>
            }
            else
            {
                <p class="text-muted">Sin contacto de emergencia registrado</p>
            }
        </div>
    </div>
</div>

<!-- CORRECCIÓN 4: Cargar test sin Include de Patient -->
test = await DbContext.PsychosomaticTests
    .FirstOrDefaultAsync(t => t.Id == TestId);

<!-- CORRECCIÓN 5: Validación de acceso profesional -->
var professional = await DbContext.EntityProfessionalProfiles
    .FirstOrDefaultAsync(p => p.ApplicationUserId == currentUserId);

<!-- CORRECCIÓN 6: Validación de acceso entidad -->
var entity = await DbContext.EntityUserProfiles
    .FirstOrDefaultAsync(e => e.ApplicationUserId == currentUserId);

return entity.EntityId == patientProfile.EntityId;
```

---

### **Archivo: PatientConsents.razor**

```csharp
// CORRECCIÓN: Cargar tests sin Include de Patient
var tests = await DbContext.PsychosomaticTests
    .ToListAsync();
```

---

## ?? **Tareas Pendientes:**

### **Prioridad Alta (Ahora):**
1. ? Corregir campos de PatientProfile en ViewPatient.razor
2. ? Corregir Include de Patient en PatientConsents.razor
3. ? Corregir nombres de DbSets (Professionals ? EntityProfessionalProfiles)
4. ? Probar compilación
5. ? Probar navegación desde dashboard

### **Prioridad Media (Próxima Sesión):**
6. [ ] Implementar vista de resultados del test
7. [ ] Generar informe PDF de resultados
8. [ ] Agregar gráficos de análisis
9. [ ] Implementar recomendaciones

### **Prioridad Baja:**
10. [ ] Agregar campos faltantes al modelo (EPS, ARL, Position, etc.)
11. [ ] Implementar timeline de historial médico
12. [ ] Agregar notas del profesional

---

## ?? **Integración con Dashboards:**

### **Desde Dashboard de Profesional:**
```razor
<!-- En Professional/Dashboard.razor -->
<button class="btn btn-primary" 
        @onclick='() => Navigation.NavigateTo($"/ViewPatient/{test.Id}")'>
    <i class="bi bi-eye"></i> Ver Expediente
</button>
```

### **Desde Dashboard de Entidad:**
```razor
<!-- En Entity/Dashboard.razor -->
<button class="btn btn-primary" 
        @onclick='() => Navigation.NavigateTo($"/ViewPatient/{test.Id}")'>
    <i class="bi bi-eye"></i> Ver Paciente
</button>
```

---

## ?? **Estructura del Archivo:**

```
ViewPatient.razor
??? Header
?   ??? Breadcrumb
?   ??? Avatar + Info del Paciente
?   ??? Estado del Test
??? Tarjetas de Información (4 columnas)
?   ??? Personal
?   ??? Laboral (simplificada)
?   ??? Médica (simplificada)
?   ??? Estado de Documentos
??? Tabs
?   ??? Tab 1: Consentimientos ?
?   ?   ??? Botón descargar paquete
?   ?   ??? Grid de consentimientos (2 cols)
?   ?   ??? Cards por consentimiento
?   ?       ??? Header con estado
?   ?       ??? Fecha y versión
?   ?       ??? Firma digital
?   ?       ??? Auditoría
?   ?       ??? Botones (Ver/PDF)
?   ??? Tab 2: Resultados ??
?       ??? Mensaje "En Progreso" (si no completado)
?       ??? Placeholder de informe (si completado)
??? Code Section
    ??? Carga de datos
    ??? Validación de acceso
    ??? Gestión de consentimientos
    ??? Métodos auxiliares
```

---

## ?? **Próximos Pasos Inmediatos:**

1. **Corregir errores de compilación** (5-10 min)
2. **Probar navegación** desde dashboards (5 min)
3. **Verificar permisos** de acceso (10 min)
4. **Probar descarga de PDFs** (5 min)

**Total:** ~30 minutos para tener funcional la vista de consentimientos.

---

## ?? **Mejoras Futuras:**

### **Vista de Resultados:**
- [ ] Dashboard con métricas del test
- [ ] Gráfico de 10 palabras (palabra vs nivel de malestar)
- [ ] Timeline de evolución emocional
- [ ] Mapa corporal de malestares
- [ ] Análisis de emociones predominantes
- [ ] Recomendaciones personalizadas
- [ ] Botón "Generar Informe PDF"

### **Funcionalidades Adicionales:**
- [ ] Historial de tests del paciente
- [ ] Comparativa entre tests
- [ ] Notas del profesional
- [ ] Plan de tratamiento
- [ ] Seguimiento de evolución

---

## ? **Resultado Final Esperado:**

Una vez corregidos los errores, tendremos:

```
/ViewPatient/123
    ?
???????????????????????????????????????
?  Avatar | Nombre del Paciente       ?
?  Documento | Edad | Test ID          ?
?  Estado: ? Completado               ?
???????????????????????????????????????
?  [Info Personal] [Laboral] [Médica] ?
?  [Estado Docs]                       ?
???????????????????????????????????????
?  [Consentimientos] [Resultados]     ?
?  ?                                   ?
?  ???????????????????????????????   ?
?  ? ? Consentimiento 1          ?   ?
?  ? [Firma] [PDF] [Ver Contenido]?  ?
?  ???????????????????????????????   ?
?  ???????????????????????????????   ?
?  ? ? Consentimiento 2          ?   ?
?  ???????????????????????????????   ?
?  [Descargar Paquete Completo]      ?
???????????????????????????????????????
```

---

**?? Estado:** En Progreso (60%)  
**?? Siguiente:** Correcciones de Compilación  
**?? Tiempo Estimado:** 30 minutos
