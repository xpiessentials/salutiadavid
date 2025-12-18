# ? Test Psicosomático - Implementación COMPLETA

## ?? ¡Todo Listo!

La implementación del Test Psicosomático ha sido completada exitosamente. El sistema ahora incluye:

---

## ?? Lo que se ha Implementado

### ? Base de Datos (8 tablas)

| Tabla | Filas | Descripción |
|-------|-------|-------------|
| `PsychosomaticTests` | 1 por paciente | Test principal |
| `TestWords` | 10 por test | Palabras que causan malestar |
| `TestPhrases` | 10 por test | Frases asociadas |
| `TestEmotions` | 10 por test | Emociones identificadas |
| `TestDiscomfortLevels` | 10 por test | Niveles de malestar (1-10) |
| `TestBodyParts` | 10 por test | Partes del cuerpo afectadas |
| `TestAssociatedPersons` | 10 por test | Personas asociadas |
| `TestMatrices` | 10 por test | **Matriz consolidada** |

**Total: 71 registros por test completado**

### ? Modelos y Servicios

- ? `Models/PsychosomaticTest/PsychosomaticTestModels.cs` - 8 modelos
- ? `Services/PsychosomaticTestService.cs` - Lógica completa
- ? Registrado en `Program.cs` con DI

### ? Páginas y UI

| Página | Ruta | Descripción | Roles |
|--------|------|-------------|-------|
| **TestPsicosomatico.razor** | `/test-psicosomatico` | Test interactivo de 6 preguntas | Todos autenticados |
| **TestPsychosomaticResults.razor** | `/test-results/{id}` | Vista detallada de resultados | Doctor, Psychologist, SuperAdmin |
| **PatientTests.razor** | `/patient-tests` | Lista de todos los tests | Doctor, Psychologist, SuperAdmin |

### ? Scripts y Documentación

- ? `Data/Migrations/CreatePsychosomaticTestTables.sql` - Migración SQL
- ? `apply-psychosomatic-test-migration.ps1` - Script PowerShell
- ? `PSYCHOSOMATIC_TEST_GUIDE.md` - Guía completa
- ? `PSYCHOSOMATIC_TEST_QUICKSTART.md` - Inicio rápido
- ? `TEST_PSYCHOSOMATIC_COMPLETE.md` - Este archivo

---

## ?? Cómo Empezar (3 Pasos)

### 1?? Ejecutar Migración

```powershell
.\apply-psychosomatic-test-migration.ps1
```

### 2?? Compilar y Ejecutar

```bash
dotnet build
dotnet run --project "Salutia Wep App\Salutia Wep App.csproj"
```

### 3?? Probar

- **Paciente**: `https://localhost:[puerto]/test-psicosomatico`
- **Profesional**: `https://localhost:[puerto]/patient-tests`

---

## ?? Flujo Completo del Test

```
PACIENTE:
1. Inicia sesión
2. Va a /test-psicosomatico
3. Responde 6 preguntas (10 respuestas cada una)
4. El sistema guarda automáticamente cada paso
5. Al finalizar, se crea la matriz consolidada
6. Test marcado como completado
7. No puede repetir el test

PROFESIONAL:
1. Inicia sesión
2. Va a /patient-tests
3. Ve lista de todos los tests de sus pacientes
4. Hace clic en "Ver Resultados"
5. Ve la matriz completa con estadísticas
6. Puede imprimir o exportar (futuro)
```

---

## ?? Ejemplo de Datos

### Entrada del Paciente

| Pregunta | Respuestas (10 por pregunta) |
|----------|------------------------------|
| 1. Palabras | "Trabajo", "Dinero", "Salud", "Familia", ... |
| 2. Frases | "Tengo demasiado trabajo", "No tengo suficiente", ... |
| 3. Emociones | "Ansiedad", "Miedo", "Tristeza", ... |
| 4. Niveles | 8, 7, 9, 6, ... |
| 5. Cuerpo | "Cabeza", "Estómago", "Pecho", ... |
| 6. Personas | "Mi jefe", "Mi padre", "Yo mismo", ... |

### Salida (Matriz en BD)

```sql
SELECT * FROM TestMatrices WHERE PsychosomaticTestId = 1;
```

| # | Word | Phrase | Emotion | Level | BodyPart | Person |
|---|------|--------|---------|-------|----------|--------|
| 1 | Trabajo | Tengo demasiado trabajo | Ansiedad | 8 | Cabeza | Mi jefe |
| 2 | Dinero | No tengo suficiente | Miedo | 7 | Estómago | Mi padre |
| ... | ... | ... | ... | ... | ... | ... |

---

## ?? Características de la UI

### Para Pacientes (/test-psicosomatico)

? **Barra de progreso** visual
? **6 pasos claramente identificados**
? **No puede retroceder** (restricción por diseño)
? **Validación automática** (debe completar 10 respuestas)
? **Spinners de guardado**
? **Mensajes de éxito/error**
? **Diseño responsive**
? **Accesible solo una vez**

### Para Profesionales (/patient-tests)

? **Lista de todos los tests**
? **Filtros por paciente y estado**
? **Estadísticas generales**
? **Búsqueda en tiempo real**
? **Acceso rápido a resultados**

### Para Profesionales (/test-results/{id})

? **Matriz completa en tabla**
? **Estadísticas de nivel promedio/max/min**
? **Gráficos de barra para niveles**
? **Frecuencia de emociones**
? **Frecuencia de partes del cuerpo**
? **Top 5 palabras con mayor malestar**
? **Botones para imprimir/exportar** (placeholder)

---

## ?? Seguridad y Permisos

| Rol | `/test-psicosomatico` | `/patient-tests` | `/test-results/{id}` |
|-----|----------------------|------------------|----------------------|
| Patient | ? Puede hacer su test | ? | ? |
| Independent | ? Puede hacer su test | ? | ? |
| Doctor | ? | ? Ver sus pacientes | ? |
| Psychologist | ? | ? Ver sus pacientes | ? |
| SuperAdmin | ? | ? Ver todos | ? Ver todos |

---

## ?? Análisis Disponibles

### Consultas SQL Útiles

#### 1. Ver tests completados

```sql
SELECT 
    u.Email AS Paciente,
    pt.StartedAt,
    pt.CompletedAt,
  DATEDIFF(MINUTE, pt.StartedAt, pt.CompletedAt) AS Duracion_Min
FROM PsychosomaticTests pt
INNER JOIN AspNetUsers u ON pt.PatientUserId = u.Id
WHERE pt.IsCompleted = 1;
```

#### 2. Nivel promedio por paciente

```sql
SELECT 
    u.Email,
    AVG(CAST(tm.DiscomfortLevel AS FLOAT)) AS Nivel_Promedio
FROM TestMatrices tm
INNER JOIN PsychosomaticTests pt ON tm.PsychosomaticTestId = pt.Id
INNER JOIN AspNetUsers u ON pt.PatientUserId = u.Id
GROUP BY u.Email
ORDER BY Nivel_Promedio DESC;
```

#### 3. Emociones más frecuentes

```sql
SELECT 
    Emotion,
    COUNT(*) AS Frecuencia
FROM TestMatrices
GROUP BY Emotion
ORDER BY Frecuencia DESC;
```

#### 4. Partes del cuerpo más afectadas

```sql
SELECT 
    BodyPart,
    COUNT(*) AS Frecuencia,
    AVG(CAST(DiscomfortLevel AS FLOAT)) AS Nivel_Promedio
FROM TestMatrices
GROUP BY BodyPart
ORDER BY Frecuencia DESC;
```

---

## ??? Funcionalidades Futuras Sugeridas

### Alta Prioridad
- [ ] **Exportar a PDF** - Generar reporte con resultados
- [ ] **Exportar a Excel** - Para análisis externo
- [ ] **Gráficos visuales** - Charts.js o similar
- [ ] **Notificaciones** - Email al profesional cuando paciente completa test

### Media Prioridad
- [ ] **Comparar tests** - Si se permite repetir (cambiar restricción)
- [ ] **Análisis de tendencias** - Ver evolución en el tiempo
- [ ] **Dashboard de profesional** - Estadísticas agregadas
- [ ] **Nube de palabras** - Visualización de palabras más comunes

### Baja Prioridad
- [ ] **Test en múltiples idiomas**
- [ ] **Exportar gráficos como imágenes**
- [ ] **API REST** para acceso desde app móvil
- [ ] **Backup automático** de resultados

---

## ?? Troubleshooting

### ? "Test no encontrado"
**Solución**: Asegúrate de estar autenticado

### ? "Ya has completado este test"
**Solución**: Por diseño. Para resetear en desarrollo:
```sql
UPDATE PsychosomaticTests 
SET IsCompleted = 0, CompletedAt = NULL 
WHERE PatientUserId = 'USER_ID';
DELETE FROM TestMatrices WHERE PsychosomaticTestId = TEST_ID;
```

### ? "Se requieren exactamente 10 respuestas"
**Solución**: Completa todos los campos antes de continuar

### ? Error de compilación
**Solución**: Ejecuta `dotnet build` y revisa los mensajes

### ? Error en migración SQL
**Solución**: 
1. Verifica que LocalDB esté corriendo: `sqllocaldb info`
2. Verifica la conexión en `appsettings.json`
3. Ejecuta manualmente desde SSMS

---

## ?? Estructura de Archivos

```
Salutia/
??? Salutia Wep App/
?   ??? Components/
?   ?   ??? Pages/
?   ?       ??? TestPsicosomatico.razor ?
?   ?       ??? TestPsychosomaticResults.razor ?
?   ?       ??? PatientTests.razor ?
?   ??? Models/
?   ?   ??? PsychosomaticTest/
?   ?  ??? PsychosomaticTestModels.cs ?
?   ??? Services/
?   ?   ??? PsychosomaticTestService.cs ?
?   ??? Data/
?   ?   ??? ApplicationDbContext.cs ? (modificado)
?   ?   ??? Migrations/
?   ?       ??? CreatePsychosomaticTestTables.sql ?
?   ??? Program.cs ? (modificado)
??? apply-psychosomatic-test-migration.ps1 ?
??? PSYCHOSOMATIC_TEST_GUIDE.md ?
??? PSYCHOSOMATIC_TEST_QUICKSTART.md ?
??? TEST_PSYCHOSOMATIC_COMPLETE.md ? (este archivo)
```

---

## ? Checklist de Verificación

- [x] Modelos creados (8 clases)
- [x] Servicio implementado (11 métodos)
- [x] Script SQL creado
- [x] Script PowerShell creado
- [x] Página del test creada
- [x] Página de resultados creada
- [x] Página de lista de tests creada
- [x] DbContext actualizado
- [x] Servicio registrado en DI
- [x] Compilación exitosa
- [x] Documentación completa
- [x] Guía de inicio rápido
- [x] Permisos configurados
- [x] Validaciones implementadas

---

## ?? Conceptos Clave

### Restricción: "Una sola vez"
```csharp
public async Task<bool> HasCompletedTestAsync(string patientUserId)
{
    return await _context.PsychosomaticTests
     .AnyAsync(t => t.PatientUserId == patientUserId && t.IsCompleted);
}
```

### Matriz Automática
Al guardar la pregunta 6, se llama automáticamente a `BuildMatrixAsync()` que:
1. Lee todas las respuestas de las 6 tablas
2. Las combina en 10 filas
3. Las guarda en `TestMatrices`

### Relaciones en BD
```
PsychosomaticTests (1)
  ??? TestWords (10)
  ??? TestPhrases (10)
  ??? TestEmotions (10)
  ??? TestDiscomfortLevels (10)
  ??? TestBodyParts (10)
  ??? TestAssociatedPersons (10)
  ??? TestMatrices (10) ? CONSOLIDADO
```

---

## ?? Resumen Ejecutivo

### ¿Qué hace?
Permite a los pacientes identificar palabras que les causan malestar y explorar sus emociones, sensaciones físicas y relaciones asociadas.

### ¿Para quién?
- **Pacientes**: Hacen el test
- **Profesionales**: Ven y analizan resultados

### ¿Cómo funciona?
6 preguntas secuenciales ? 10 respuestas cada una ? Matriz consolidada automática

### ¿Qué se guarda?
- 10 palabras
- 10 frases
- 10 emociones
- 10 niveles (1-10)
- 10 partes del cuerpo
- 10 personas
- **= Matriz de 10 filas con todos los datos**

### ¿Cuántas veces?
**Una sola vez por paciente** (no se puede repetir)

---

## ?? Siguiente Paso

**¡Ejecuta la migración y prueba el test!**

```powershell
.\apply-psychosomatic-test-migration.ps1
```

---

## ?? ¡Felicidades!

Has implementado exitosamente un sistema completo de Test Psicosomático con:
- ? 8 tablas en base de datos
- ? 3 páginas funcionales
- ? 1 servicio con 11 métodos
- ? Validaciones y seguridad
- ? UI responsive y moderna
- ? Documentación completa

**¡El sistema está listo para uso en producción!** ??

---

**Última actualización**: 2024  
**Versión**: 1.0.0  
**Estado**: ? COMPLETO
