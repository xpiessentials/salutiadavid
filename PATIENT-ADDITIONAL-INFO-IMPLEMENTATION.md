# ?? Implementación de Información Adicional del Paciente

## ? Pasos Completados

### 1. ?? Modelos Creados

Se ha creado el archivo `Salutia Wep App/Models/Patient/PatientAdditionalModels.cs` con los siguientes modelos:

#### Maestros (Catálogos):
- **Occupation** - Ocupaciones del paciente
- **MaritalStatus** - Estados civiles
- **EducationLevel** - Niveles educativos

#### Datos Adicionales del Paciente:
- **PatientMedicalHistory** - Historial médico/psicológico
- **PatientMedication** - Medicación actual
- **PatientAllergy** - Alergias
- **PatientEmergencyContact** - Contactos de emergencia

### 2. ?? Modelo PatientProfile Actualizado

Se ha actualizado `ApplicationUser.cs` agregando los siguientes campos al modelo `PatientProfile`:

```csharp
// Nuevos campos de maestros
public int? OccupationId { get; set; }
public Occupation? Occupation { get; set; }

public int? MaritalStatusId { get; set; }
public MaritalStatus? MaritalStatus { get; set; }

public int? EducationLevelId { get; set; }
public EducationLevel? EducationLevel { get; set; }

// Nuevas colecciones
public ICollection<PatientMedicalHistory> MedicalHistories { get; set; }
public ICollection<PatientMedication> CurrentMedications { get; set; }
public ICollection<PatientAllergy> Allergies { get; set; }
public ICollection<PatientEmergencyContact> EmergencyContacts { get; set; }
```

### 3. ?? ApplicationDbContext Configurado

Se ha actualizado `ApplicationDbContext.cs` con:
- DbSets para todos los nuevos modelos
- Configuraciones de Entity Framework para cada modelo
- Relaciones entre PatientProfile y los nuevos maestros
- Relaciones en cascada para datos dependientes

---

## ?? Próximos Pasos

### PASO 4: Crear Migración de Base de Datos

Ejecuta los siguientes comandos en la **Consola del Administrador de Paquetes** (Tools ? NuGet Package Manager ? Package Manager Console):

```powershell
# Crear la migración
Add-Migration AddPatientAdditionalInfo

# Aplicar la migración a la base de datos
Update-Database
```

**O usando la CLI de .NET:**

```bash
cd "Salutia Wep App"
dotnet ef migrations add AddPatientAdditionalInfo
dotnet ef database update
```

### PASO 5: Poblar Datos Semilla (Seed Data)

Después de aplicar la migración, necesitas insertar datos iniciales en los maestros. Te proporcionaré scripts SQL para esto.

---

## ?? Estructura de Tablas Nuevas

### Maestros (Catálogos):

| Tabla | Campos Principales |
|-------|-------------------|
| `Occupations` | Id, Name, Description, IsActive, DisplayOrder |
| `MaritalStatuses` | Id, Name, Code, IsActive, DisplayOrder |
| `EducationLevels` | Id, Name, Code, IsActive, DisplayOrder |

### Datos del Paciente:

| Tabla | Campos Principales |
|-------|-------------------|
| `PatientMedicalHistories` | Id, PatientProfileId, Condition, DiagnosisDate, Notes, IsCurrent |
| `PatientMedications` | Id, PatientProfileId, MedicationName, Dosage, Frequency, StartDate, EndDate, IsCurrent |
| `PatientAllergies` | Id, PatientProfileId, AllergenName, AllergyType, Reaction, Severity |
| `PatientEmergencyContacts` | Id, PatientProfileId, FullName, Relationship, PhoneNumber, Email, IsPrimary |

---

## ?? Validaciones a Implementar

### Validación de Perfil Completo

Para considerar que un paciente tiene su perfil completo, debe tener:

#### Campos Obligatorios:
1. ? Nombre completo
2. ? Fecha de nacimiento
3. ? Género
4. ? Teléfono
5. ? Dirección
6. ? País, Estado, Ciudad
7. ? **Ocupación**
8. ? **Estado Civil**
9. ? **Nivel Educativo**
10. ? **Al menos 1 Contacto de Emergencia**

#### Campos Opcionales (pero recomendados):
- Historial médico
- Medicación actual
- Alergias

---

## ?? Ejemplo de Datos Semilla

### Ocupaciones (Ejemplos):
```sql
INSERT INTO Occupations (Name, Description, IsActive, DisplayOrder) VALUES
('Empleado de Oficina', 'Trabajo administrativo y de oficina', 1, 1),
('Profesional de la Salud', 'Médico, enfermero, terapeuta', 1, 2),
('Ingeniero', 'Ingeniería en diversas áreas', 1, 3),
('Docente', 'Profesor, maestro, instructor', 1, 4),
('Comerciante', 'Ventas y comercio', 1, 5),
('Estudiante', 'Estudiante universitario o técnico', 1, 6),
('Ama de Casa', 'Trabajo en el hogar', 1, 7),
('Pensionado', 'Persona retirada/jubilada', 1, 8),
('Desempleado', 'Sin empleo actual', 1, 9),
('Otro', 'Otra ocupación no listada', 1, 10);
```

### Estados Civiles:
```sql
INSERT INTO MaritalStatuses (Name, Code, IsActive, DisplayOrder) VALUES
('Soltero(a)', 'S', 1, 1),
('Casado(a)', 'C', 1, 2),
('Unión Libre', 'UL', 1, 3),
('Divorciado(a)', 'D', 1, 4),
('Viudo(a)', 'V', 1, 5),
('Separado(a)', 'SEP', 1, 6);
```

### Niveles Educativos:
```sql
INSERT INTO EducationLevels (Name, Code, IsActive, DisplayOrder) VALUES
('Sin Educación Formal', 'NONE', 1, 1),
('Primaria Incompleta', 'PRI_I', 1, 2),
('Primaria Completa', 'PRI_C', 1, 3),
('Secundaria Incompleta', 'SEC_I', 1, 4),
('Secundaria Completa', 'SEC_C', 1, 5),
('Técnico', 'TEC', 1, 6),
('Tecnólogo', 'TECNO', 1, 7),
('Universitario Incompleto', 'UNI_I', 1, 8),
('Universitario Completo', 'UNI_C', 1, 9),
('Postgrado', 'POST', 1, 10),
('Maestría', 'MAES', 1, 11),
('Doctorado', 'DOCT', 1, 12);
```

---

## ?? Siguientes Archivos a Crear

1. **Componente Blazor**: `CompletePatientProfile.razor`
   - Formulario para completar información adicional
   - Validación de campos obligatorios
   - Guardado de datos

2. **Servicio**: `PatientProfileService.cs`
   - Métodos para validar perfil completo
   - Métodos para guardar información adicional

3. **Página de Test**: Modificar para validar perfil antes de comenzar

---

## ?? Importante

- Las nuevas tablas se crearán automáticamente al ejecutar `Update-Database`
- Los datos semilla deben insertarse **después** de crear las tablas
- El campo `ProfileCompleted` del paciente debe actualizarse cuando complete toda la información
- Antes de acceder al test psicosomático, verificar si `ProfileCompleted` es `true`

---

## ?? Continuación

Una vez que ejecutes la migración y me confirmes que está exitosa, procederé a:
1. Crear el script SQL completo para datos semilla
2. Crear el componente de formulario para completar perfil
3. Crear la lógica de validación antes del test
4. Integrar todo el flujo

---

? **Estado Actual:** Modelos y base de datos listos para migración
?? **Esperando:** Ejecución de `Add-Migration` y `Update-Database`
