# Test Psicosomático - Guía de Implementación Completa

## ?? Descripción General

El Test Psicosomático es una herramienta de evaluación que permite a los pacientes identificar palabras que les causan malestar y explorar las emociones, sensaciones físicas y personas asociadas a ese malestar.

## ?? Flujo del Test

El test consta de **6 preguntas secuenciales** donde el usuario NO puede retroceder:

### 1?? Pregunta 1: Palabras que causan malestar
- El usuario escribe **10 palabras** que le generan malestar
- Se guardan en la tabla `TestWords`

### 2?? Pregunta 2: Frases asociadas
- Para cada palabra, el usuario escribe **1 frase** relacionada (total: 10 frases)
- Se guardan en la tabla `TestPhrases`

### 3?? Pregunta 3: Emociones
- Para cada palabra/frase, el usuario identifica la **emoción** que siente (total: 10 emociones)
- Se guardan en la tabla `TestEmotions`

### 4?? Pregunta 4: Nivel de malestar
- El usuario califica de **1 a 10** cuánto malestar le causa cada palabra/frase (total: 10 calificaciones)
- Se guardan en la tabla `TestDiscomfortLevels`

### 5?? Pregunta 5: Parte del cuerpo
- El usuario indica en qué **parte del cuerpo** siente el malestar (total: 10 partes)
- Se guardan en la tabla `TestBodyParts`

### 6?? Pregunta 6: Persona asociada
- El usuario indica qué **persona** asocia con ese malestar (total: 10 personas)
- Se guardan en la tabla `TestAssociatedPersons`
- Al finalizar, se crea automáticamente la **Matriz consolidada**

## ??? Estructura de Base de Datos

### Tablas Creadas

| Tabla | Descripción | Campos Principales |
|-------|-------------|-------------------|
| `PsychosomaticTests` | Test principal | `Id`, `PatientUserId`, `StartedAt`, `CompletedAt`, `IsCompleted` |
| `TestWords` | 10 palabras | `PsychosomaticTestId`, `WordNumber` (1-10), `Word` |
| `TestPhrases` | 10 frases | `PsychosomaticTestId`, `WordNumber` (1-10), `Phrase` |
| `TestEmotions` | 10 emociones | `PsychosomaticTestId`, `WordNumber` (1-10), `Emotion` |
| `TestDiscomfortLevels` | 10 niveles | `PsychosomaticTestId`, `WordNumber` (1-10), `DiscomfortLevel` (1-10) |
| `TestBodyParts` | 10 partes del cuerpo | `PsychosomaticTestId`, `WordNumber` (1-10), `BodyPart` |
| `TestAssociatedPersons` | 10 personas | `PsychosomaticTestId`, `WordNumber` (1-10), `PersonName` |
| `TestMatrices` | **Matriz consolidada** | Todos los campos anteriores consolidados |

### Relaciones

- Todas las tablas se relacionan con `PsychosomaticTests` mediante `PsychosomaticTestId`
- `PsychosomaticTests` se relaciona con `AspNetUsers` mediante `PatientUserId`
- Cada tabla tiene un índice único en `(PsychosomaticTestId, WordNumber)` para garantizar exactamente 10 respuestas

### Matriz Consolidada (TestMatrices)

Esta es la tabla más importante. Al finalizar el test, se crea automáticamente con **10 filas** (una por cada palabra) conteniendo:

```
| Id_Paciente | Palabra | Frase | Emocion | Nivel_Malestar | Cuerpo | Persona |
|-------------|---------|-------|---------|----------------|--------|---------|
| user123 | palabra1| frase1| emocion1| 7              | Cabeza | Persona1|
| user123     | palabra2| frase2| emocion2| 9       | Pecho  | Persona2|
| ...         | ...     | ...   | ...     | ...            | ...    | ...  |
```

## ?? Archivos Creados/Modificados

### Nuevos Archivos

1. **`Models/PsychosomaticTest/PsychosomaticTestModels.cs`**
   - Define todos los modelos de datos del test

2. **`Services/PsychosomaticTestService.cs`**
   - Servicio que maneja toda la lógica del test
   - Métodos para guardar cada pregunta
   - Construcción automática de la matriz

3. **`Data/Migrations/CreatePsychosomaticTestTables.sql`**
   - Script SQL para crear todas las tablas

4. **`apply-psychosomatic-test-migration.ps1`**
   - Script PowerShell para aplicar la migración fácilmente

5. **`PSYCHOSOMATIC_TEST_GUIDE.md`** (este archivo)
   - Guía completa de implementación

### Archivos Modificados

1. **`Data/ApplicationDbContext.cs`**
   - Agregados DbSets para todas las tablas del test
   - Configuradas relaciones y constraints

2. **`Components/Pages/TestPsicosomatico.razor`**
   - Rediseñado completamente con el nuevo flujo de 6 preguntas
   - UI mejorada con Bootstrap 5
   - Validaciones en cada paso
   - Sin posibilidad de retroceder

3. **`Program.cs`**
   - Registrado `PsychosomaticTestService` en DI

## ?? Instrucciones de Instalación

### Paso 1: Aplicar Migración de Base de Datos

#### Opción A: Usar el script PowerShell (Recomendado)

```powershell
# Ejecutar desde la raíz del proyecto
.\apply-psychosomatic-test-migration.ps1
```

#### Opción B: Ejecutar SQL manualmente

```bash
# Conectarse a LocalDB
sqlcmd -S "(localdb)\MSSQLLocalDB" -d "Salutia"

# Ejecutar el script
:r "Salutia Wep App\Data\Migrations\CreatePsychosomaticTestTables.sql"
GO
```

### Paso 2: Compilar el Proyecto

```bash
dotnet build
```

### Paso 3: Ejecutar la Aplicación

```bash
dotnet run --project "Salutia Wep App\Salutia Wep App.csproj"
```

### Paso 4: Acceder al Test

1. Iniciar sesión como **paciente** o cualquier usuario autenticado
2. Navegar a: `https://localhost:[puerto]/test-psicosomatico`
3. Completar el test siguiendo las 6 preguntas

## ?? Restricciones y Validaciones

### Restricciones de Negocio

1. **Un paciente solo puede completar el test UNA VEZ**
   - El sistema verifica `HasCompletedTestAsync()`
   - Una vez completado, muestra mensaje informativo

2. **No se puede retroceder**
   - No hay botón "Anterior"
   - Una vez guardada una pregunta, no se puede modificar

3. **Todas las respuestas son obligatorias**
   - Se valida que las 10 respuestas estén completas antes de avanzar
   - Los niveles de malestar tienen valor por defecto (5)

### Validaciones Técnicas

- **WordNumber**: Debe estar entre 1 y 10 (constraint en DB)
- **DiscomfortLevel**: Debe estar entre 1 y 10 (constraint en DB)
- **Palabras**: Máximo 100 caracteres
- **Frases**: Máximo 500 caracteres
- **Emociones**: Máximo 100 caracteres
- **Partes del cuerpo**: Máximo 100 caracteres
- **Personas**: Máximo 200 caracteres

## ?? Uso de los Datos

### Consultar la Matriz de un Paciente

```sql
SELECT 
    WordNumber,
    Word,
    Phrase,
    Emotion,
    DiscomfortLevel,
    BodyPart,
    AssociatedPerson
FROM TestMatrices
WHERE PsychosomaticTestId = (
    SELECT Id 
    FROM PsychosomaticTests 
    WHERE PatientUserId = '[UserId]' 
      AND IsCompleted = 1
)
ORDER BY WordNumber;
```

### Obtener Estadísticas

```sql
-- Nivel promedio de malestar por paciente
SELECT 
  pt.PatientUserId,
    AVG(CAST(tm.DiscomfortLevel AS FLOAT)) AS PromedioMalestar,
    MAX(tm.DiscomfortLevel) AS MalestMax,
    MIN(tm.DiscomfortLevel) AS MalestarMin
FROM PsychosomaticTests pt
INNER JOIN TestMatrices tm ON pt.Id = tm.PsychosomaticTestId
WHERE pt.IsCompleted = 1
GROUP BY pt.PatientUserId;
```

### Usar en C#

```csharp
// Obtener matriz de un test
var matrix = await _testService.GetMatrixAsync(testId);

// Procesar resultados
foreach (var row in matrix)
{
    Console.WriteLine($"{row.WordNumber}. {row.Word} -> {row.Emotion} (Nivel: {row.DiscomfortLevel})");
}
```

## ?? Interfaz de Usuario

### Características de la UI

- ? **Barra de progreso** visual (6 pasos)
- ? **Texto descriptivo** para cada pregunta
- ? **Validación en tiempo real**
- ? **Indicadores de guardado** (spinners)
- ? **Mensajes de error claros**
- ? **Diseño responsive** (Bootstrap 5)
- ? **Iconos intuitivos** (Bootstrap Icons)

### Flujo Visual

```
Pregunta 1: 10 campos de texto (palabras)
 ?
Pregunta 2: 10 tarjetas con palabra + campo de texto (frase)
     ?
Pregunta 3: 10 tarjetas con palabra + frase + campo de texto (emoción)
     ?
Pregunta 4: 10 tarjetas con palabra + frase + slider 1-10
     ?
Pregunta 5: 10 tarjetas con palabra + frase + campo de texto (cuerpo)
     ?
Pregunta 6: 10 tarjetas con palabra + frase + campo de texto (persona)
     ?
COMPLETADO: Mensaje de éxito + botón volver al inicio
```

## ?? Servicios y Métodos

### PsychosomaticTestService

#### Métodos Principales

```csharp
// Verificar si completó el test
Task<bool> HasCompletedTestAsync(string patientUserId)

// Obtener o crear test
Task<PsychosomaticTest> GetOrCreateTestAsync(string patientUserId)

// Guardar respuestas
Task SaveWordsAsync(int testId, List<string> words)
Task SavePhrasesAsync(int testId, List<string> phrases)
Task SaveEmotionsAsync(int testId, List<string> emotions)
Task SaveDiscomfortLevelsAsync(int testId, List<int> levels)
Task SaveBodyPartsAsync(int testId, List<string> bodyParts)
Task SaveAssociatedPersonsAndCompleteTestAsync(int testId, List<string> persons)

// Consultar datos
Task<List<TestWord>> GetWordsAsync(int testId)
Task<List<TestPhrase>> GetPhrasesAsync(int testId)
Task<List<TestMatrix>> GetMatrixAsync(int testId)
Task<PsychosomaticTest?> GetTestByIdAsync(int testId)
```

## ?? Troubleshooting

### Error: "Test no encontrado"

**Causa**: El test no fue creado correctamente

**Solución**:
```csharp
var test = await _testService.GetOrCreateTestAsync(userId);
```

### Error: "Se requieren exactamente 10 respuestas"

**Causa**: No se completaron las 10 respuestas en alguna pregunta

**Solución**: Verificar que todos los campos estén llenos antes de enviar

### Error: "Ya has completado este test"

**Causa**: El test fue marcado como completado

**Solución**: Esto es por diseño. Si necesitas resetear:
```sql
-- Solo para desarrollo/testing
UPDATE PsychosomaticTests 
SET IsCompleted = 0, CompletedAt = NULL 
WHERE PatientUserId = '[UserId]';
```

### Error: "Foreign key constraint"

**Causa**: El usuario no existe en AspNetUsers

**Solución**: Asegurarse de que el usuario esté autenticado y su ID sea válido

## ?? Próximos Pasos Sugeridos

### Funcionalidades Adicionales

1. **Panel de Resultados**
   - Crear vista para que el profesional vea la matriz del paciente
   - Gráficos de barras para niveles de malestar
   - Nube de palabras con las emociones más frecuentes

2. **Análisis Avanzado**
   - Identificar patrones en las respuestas
   - Relacionar partes del cuerpo con emociones
   - Generar reporte PDF con los resultados

3. **Dashboard de Profesional**
   - Ver todos los tests completados de sus pacientes
   - Comparar resultados entre pacientes
   - Exportar datos a Excel

4. **Notificaciones**
   - Notificar al profesional cuando un paciente completa el test
   - Recordatorios por email

### Ejemplo de Vista de Resultados

```razor
@page "/test-results/{testId:int}"
@inject PsychosomaticTestService TestService

<h3>Resultados del Test Psicosomático</h3>

@if (matrix != null)
{
    <table class="table">
        <thead>
       <tr>
            <th>#</th>
         <th>Palabra</th>
           <th>Frase</th>
          <th>Emoción</th>
             <th>Nivel</th>
      <th>Cuerpo</th>
        <th>Persona</th>
            </tr>
        </thead>
        <tbody>
     @foreach (var row in matrix)
   {
        <tr>
 <td>@row.WordNumber</td>
  <td>@row.Word</td>
 <td>@row.Phrase</td>
  <td>@row.Emotion</td>
 <td>
         <div class="progress">
          <div class="progress-bar" style="width: @(row.DiscomfortLevel * 10)%">
   @row.DiscomfortLevel
   </div>
         </div>
     </td>
              <td>@row.BodyPart</td>
            <td>@row.AssociatedPerson</td>
 </tr>
     }
    </tbody>
    </table>
}

@code {
    [Parameter] public int TestId { get; set; }
    private List<TestMatrix>? matrix;

    protected override async Task OnInitializedAsync()
    {
    matrix = await TestService.GetMatrixAsync(TestId);
    }
}
```

## ? Checklist de Verificación

- [ ] Tablas creadas en la base de datos
- [ ] Servicio registrado en DI
- [ ] Página accesible en `/test-psicosomatico`
- [ ] Usuario puede iniciar el test
- [ ] Las 6 preguntas funcionan correctamente
- [ ] No se puede retroceder
- [ ] Validaciones funcionan
- [ ] Matriz se crea al finalizar
- [ ] Test se marca como completado
- [ ] No se puede repetir el test

## ?? Notas Finales

- **Seguridad**: El test requiere autenticación (`@attribute [Authorize]`)
- **Rendimiento**: Todas las consultas usan índices optimizados
- **Escalabilidad**: La estructura soporta múltiples tests por paciente (si se elimina la restricción)
- **Mantenibilidad**: Código bien documentado y organizado
- **Extensibilidad**: Fácil de agregar nuevas preguntas o análisis

---

## ?? Soporte

Si tienes problemas o preguntas:
1. Revisa la sección de Troubleshooting
2. Verifica los logs de la aplicación
3. Consulta los mensajes de error en la consola

**¡Implementación completada exitosamente! ??**
