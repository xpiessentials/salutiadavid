# ?? Inicio Rápido - Test Psicosomático

## ? 3 Pasos para Empezar

### 1?? Aplicar Migración (1 minuto)

Ejecuta el script PowerShell desde la raíz del proyecto:

```powershell
.\apply-psychosomatic-test-migration.ps1
```

Presiona **S** cuando te pida confirmación.

### 2?? Ejecutar la Aplicación (30 segundos)

```bash
dotnet run --project "Salutia Wep App\Salutia Wep App.csproj"
```

### 3?? Probar el Test (2 minutos)

1. Abre el navegador en `https://localhost:[puerto]`
2. Inicia sesión con cualquier usuario
3. Ve a: `/test-psicosomatico`
4. Completa las 6 preguntas

---

## ?? ¿Qué hace el Test?

El test captura **10 respuestas** en cada una de estas **6 preguntas**:

| # | Pregunta | Ejemplo de Respuesta |
|---|----------|---------------------|
| 1 | Palabras que causan malestar | "Trabajo", "Dinero", "Madre" |
| 2 | Frase para cada palabra | "Tengo demasiado trabajo" |
| 3 | Emoción que siente | "Ansiedad", "Tristeza" |
| 4 | Nivel de malestar (1-10) | 8 |
| 5 | Parte del cuerpo | "Cabeza", "Estómago" |
| 6 | Persona asociada | "Mi jefe", "Mi padre" |

Al finalizar, **automáticamente** se crea una matriz consolidada en la base de datos.

---

## ??? ¿Dónde se guardan los datos?

### Tabla Principal: `TestMatrices`

```sql
-- Ver la matriz completa de un paciente
SELECT * FROM TestMatrices 
WHERE PsychosomaticTestId = 1
ORDER BY WordNumber;
```

Resultado:

| WordNumber | Word | Phrase | Emotion | DiscomfortLevel | BodyPart | AssociatedPerson |
|------------|------|--------|---------|-----------------|----------|------------------|
| 1 | Trabajo | Tengo demasiado trabajo | Ansiedad | 8 | Cabeza | Mi jefe |
| 2 | Dinero | No tengo suficiente | Miedo | 7 | Estómago | Mi padre |
| ... | ... | ... | ... | ... | ... | ... |

---

## ?? Características Clave

? **Una sola vez**: El paciente solo puede hacer el test una vez  
? **Sin retroceso**: No puede volver a preguntas anteriores  
? **Validación automática**: Debe completar las 10 respuestas antes de continuar  
? **Guardado automático**: Cada pregunta se guarda al hacer clic en "Siguiente"  
? **Matriz automática**: Se construye al finalizar la pregunta 6  

---

## ?? Consultas Útiles

### Ver todos los tests completados

```sql
SELECT 
    u.Email,
 pt.StartedAt,
    pt.CompletedAt,
    DATEDIFF(MINUTE, pt.StartedAt, pt.CompletedAt) AS MinutosParaCompletar
FROM PsychosomaticTests pt
INNER JOIN AspNetUsers u ON pt.PatientUserId = u.Id
WHERE pt.IsCompleted = 1;
```

### Nivel promedio de malestar

```sql
SELECT 
    AVG(CAST(DiscomfortLevel AS FLOAT)) AS PromedioMalestar
FROM TestMatrices
WHERE PsychosomaticTestId = 1;
```

### Emociones más frecuentes

```sql
SELECT 
    Emotion,
    COUNT(*) AS Frecuencia
FROM TestMatrices
GROUP BY Emotion
ORDER BY Frecuencia DESC;
```

---

## ?? Troubleshooting Rápido

### ? Error: "Test no encontrado"
**Solución**: El usuario no está autenticado. Inicia sesión primero.

### ? Error: "Ya has completado este test"
**Solución**: Por diseño. Para resetear (solo en desarrollo):
```sql
UPDATE PsychosomaticTests 
SET IsCompleted = 0, CompletedAt = NULL 
WHERE PatientUserId = '[UserId]';
```

### ? Error: "Se requieren exactamente 10 respuestas"
**Solución**: Completa todos los campos antes de hacer clic en "Siguiente".

---

## ?? Archivos Importantes

| Archivo | Descripción |
|---------|-------------|
| `Models/PsychosomaticTest/PsychosomaticTestModels.cs` | Modelos de datos |
| `Services/PsychosomaticTestService.cs` | Lógica del test |
| `Components/Pages/TestPsicosomatico.razor` | Interfaz de usuario |
| `Data/Migrations/CreatePsychosomaticTestTables.sql` | Script de migración |
| `PSYCHOSOMATIC_TEST_GUIDE.md` | Guía completa |

---

## ?? Vista Previa de la UI

```
???????????????????????????????????????
?  Test Psicosomático      ?
?  Pregunta 1 de 6         ?
?  ?????????????????????????? 16%  ?
?  Identificando palabras...          ?
???????????????????????????????????????
?  Escriba 10 palabras que le causan  ?
?  malestar:    ?
?     ?
?  Palabra 1: [___________________]   ?
?  Palabra 2: [___________________]   ?
?  ...  ?
?  Palabra 10: [__________________]   ?
?       ?
?  [  Siguiente Pregunta  ?  ]        ?
???????????????????????????????????????
```

---

## ?? Siguiente Paso: Ver Resultados

Para crear una página de resultados, consulta la sección **"Próximos Pasos Sugeridos"** en `PSYCHOSOMATIC_TEST_GUIDE.md`.

---

**¡Listo para usar! ??**

?? Ejecuta: `.\apply-psychosomatic-test-migration.ps1`
