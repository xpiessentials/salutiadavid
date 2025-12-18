# ? TEST PSICOSOMÁTICO - ACTUALIZACIÓN COMPLETADA

## ?? Resumen Ejecutivo

Se ha agregado la **Pregunta 5: A qué edad sintió el malestar** al Test Psicosomático.

---

## ?? Antes vs Después

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Preguntas** | 6 | **7** (+1) |
| **Tablas** | 8 | **9** (+1 TestAges) |
| **Pregunta 5** | Parte del cuerpo | **Edad** ? |
| **Pregunta 6** | Persona | **Parte del cuerpo** |
| **Pregunta 7** | - | **Persona** |

---

## ?? Cómo Aplicar (Elige UNA opción)

### ? OPCIÓN 1: Si las tablas NO existen (Primera vez)

```powershell
.\EJECUTAR_ESTO.ps1
```

### ? OPCIÓN 2: Si las tablas YA existen (Actualización)

**Mantiene todos los datos existentes:**

```powershell
.\aplicar-actualizacion-edad.ps1
```

Este script:
- ? Crea la tabla `TestAges`
- ? Agrega columna `Age` a `TestMatrices`
- ? **NO borra datos existentes**
- ? Verifica tests completados

### ? OPCIÓN 3: Manual (Si prefieres SQL)

```sql
-- Ejecutar en SSMS o sqlcmd
sqlcmd -S "LAPTOP-DAVID\SQLEXPRESS" -d "Salutia" -E -i ".\Salutia Wep App\Data\Migrations\UpdatePsychosomaticTestAddAge.sql"
```

---

## ?? Nuevo Flujo de Preguntas

```
1. Palabras (10)          ? Sin cambios
2. Frases (10)            ? Sin cambios
3. Emociones (10)         ? Sin cambios
4. Niveles 1-10 (10)      ? Sin cambios
5. Edad ? NUEVA          ? Agregada aquí
6. Parte del Cuerpo (10)  ? Movida de posición 5
7. Persona Asociada (10)  ? Movida de posición 6
```

---

## ??? Archivos Actualizados

### ? Código
- `PsychosomaticTestModels.cs` - Modelo `TestAge` + `TestMatrix.Age`
- `ApplicationDbContext.cs` - DbSet y configuración
- `PsychosomaticTestService.cs` - Método `SaveAgesAsync()`
- `TestPsicosomatico.razor` - UI con pregunta 5
- `TestPsychosomaticResults.razor` - Columna Edad

### ? Base de Datos
- `CreatePsychosomaticTestTables.sql` - Script completo
- `UpdatePsychosomaticTestAddAge.sql` - Solo actualización ?

### ? Scripts
- `EJECUTAR_ESTO.ps1` - Actualizado para 9 tablas
- `aplicar-actualizacion-edad.ps1` - Nuevo script ?

### ? Documentación
- `TEST_PSICOSOMATICO_ACTUALIZACION.md` - Guía completa ?

---

## ?? Vista de la Nueva Pregunta

```
?????????????????????????????????????????????????
?  5?? Escriba a qué edad sintió el malestar     ?
?????????????????????????????????????????????????

???????????????????????????????????????????????
? ?? 1. Miedo                                 ?
? ?? Me da miedo estar solo                   ?
?                                             ?
? Edad: [15 años____________________]         ?
?       Ej: 15 años, Desde niño, 5 años       ?
???????????????????????????????????????????????

... (Se repite para las 10 palabras)

??????????????????????
? Siguiente Pregunta ?
??????????????????????
```

---

## ?? Resultado en la Matriz

### Antes (8 columnas):

| # | Palabra | Frase | Emoción | Nivel | Cuerpo | Persona |
|---|---------|-------|---------|-------|--------|---------|
| 1 | Miedo | ... | Ansiedad | 8 | Pecho | Padre |

### Después (9 columnas):

| # | Palabra | Frase | Emoción | Nivel | **Edad** | Cuerpo | Persona |
|---|---------|-------|---------|-------|----------|--------|---------|
| 1 | Miedo | ... | Ansiedad | 8 | **15 años** | Pecho | Padre |

---

## ? Verificación Rápida

```powershell
# Verificar que las 9 tablas existen
sqlcmd -S "LAPTOP-DAVID\SQLEXPRESS" -d "Salutia" -E -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'Test%' OR TABLE_NAME = 'PsychosomaticTests' ORDER BY TABLE_NAME"
```

**Debe mostrar:**
```
PsychosomaticTests
TestAges                 ? Debe estar presente
TestAssociatedPersons
TestBodyParts
TestDiscomfortLevels
TestEmotions
TestMatrices
TestPhrases
TestWords

(9 filas afectadas)
```

---

## ?? Verificar Estructura TestAges

```sql
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TestAges';
```

**Resultado esperado:**
```
Id                   int
PsychosomaticTestId  int
WordNumber           int
Age                  nvarchar
CreatedAt            datetime2
```

---

## ?? Notas Importantes

### Tests Existentes
Si ya tienes tests completados:
- ? **NO** tendrán datos de edad (es imposible retroactivamente)
- ? Los **nuevos** tests sí incluirán la edad
- ? Los datos existentes se mantienen intactos

### Migración Segura
- ? Script verifica antes de crear
- ? No borra datos
- ? Solo agrega estructuras nuevas

---

## ?? Pasos Finales

### 1. Aplicar la actualización

```powershell
# Si ya tienes tablas del test
.\aplicar-actualizacion-edad.ps1

# Si es primera vez
.\EJECUTAR_ESTO.ps1
```

### 2. Compilar

```powershell
dotnet build
```

### 3. Ejecutar

```powershell
dotnet run --project ".\Salutia Wep App\Salutia Wep App.csproj"
```

### 4. Probar

Navegar a: `https://localhost:[puerto]/test-psicosomatico`

---

## ?? Beneficio Terapéutico

La nueva pregunta permite:

- ? **Identificar el origen temporal** del malestar
- ? **Asociar eventos de la infancia/adolescencia**
- ? **Análisis de traumas tempranos**
- ? **Mejor contexto para el tratamiento**

---

## ?? Troubleshooting

### Error: "Columna Age no existe"
```powershell
.\aplicar-actualizacion-edad.ps1
```

### Error: "Tabla TestAges no existe"
```powershell
.\EJECUTAR_ESTO.ps1
```

### Compilación OK pero error en runtime
Verificar que `TestMatrices` tiene columna `Age`:
```sql
SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TestMatrices' AND COLUMN_NAME = 'Age';
```

---

## ? Checklist Final

- [ ] Script de actualización ejecutado
- [ ] 9 tablas verificadas
- [ ] TestAges existe
- [ ] TestMatrices tiene columna Age
- [ ] Compilación exitosa
- [ ] Aplicación ejecutándose
- [ ] Test accesible en /test-psicosomatico
- [ ] Pregunta 5 visible
- [ ] Orden correcto (7 preguntas)

---

## ?? ¡Listo!

El Test Psicosomático ahora incluye la pregunta sobre la edad, completando las **7 preguntas** del protocolo.

**Comando para ejecutar:**

```powershell
.\aplicar-actualizacion-edad.ps1
```

---

**Última actualización:** Ahora  
**Versión:** Test Psicosomático v2.0 con Edad
