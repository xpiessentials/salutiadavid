# ? Sistema de Consentimientos - Paso 3 de 9 COMPLETADO

## ?? **¡Datos Semilla Insertados Exitosamente!**

---

## ? **Verificación de Inserción:**

### **Resultado de SQL Server:**

```
Id  Title                                               Code                        Version  DisplayOrder  IsRequired  IsActive
1   Consentimiento de Protección de Datos Personales   CONSENT_DATA_PRIVACY        1        1             1           1
2   Consentimiento para Evaluación Psicológica         CONSENT_PSYCHOLOGICAL_EVAL  1        2             1           1
3   Consentimiento para Registro de Información Médica CONSENT_MEDICAL_RECORD      1        3             1           1
4   Consentimiento para Compartir con Entidad...       CONSENT_SHARE_WITH_EMPLOYER 1        4             0           1
```

? **4 plantillas insertadas correctamente**
? **3 obligatorias (IsRequired = 1)**
? **1 opcional (IsRequired = 0)**

---

## ?? **Progreso Actualizado: 33% ? 38%**

| Paso | Descripción | Estado | Progreso |
|------|-------------|--------|----------|
| 1 | Modelos de datos | ? Completo | 100% |
| 2 | Migración de BD | ? Completo | 100% |
| 3 | Servicio ConsentService | ? Completo | 100% |
| **3.5** | **Datos semilla** | ? **COMPLETO** | **100%** |
| 4 | Componente firma digital | ? Siguiente | 0% |
| 5 | Página consentimientos | ? Pendiente | 0% |
| 6 | Generación PDFs | ? Pendiente | 0% |
| 7 | Integración test | ? Pendiente | 0% |
| 8 | Vista profesionales | ? Pendiente | 0% |
| 9 | Gestión admin | ? Pendiente | 0% |

**TOTAL: 38% Completado**

---

## ?? **Validación de Datos:**

### **Consentimiento 1: Protección de Datos Personales** ?
- **Código:** `CONSENT_DATA_PRIVACY`
- **Versión:** 1
- **Obligatorio:** Sí
- **Contenido:** Ley 1581 de 2012, derechos ARCO
- **Secciones:** 5 (Recolección, Finalidad, Derechos, Seguridad, Vigencia)

### **Consentimiento 2: Evaluación Psicológica** ?
- **Código:** `CONSENT_PSYCHOLOGICAL_EVAL`
- **Versión:** 1
- **Obligatorio:** Sí
- **Contenido:** Naturaleza, limitaciones, confidencialidad
- **Secciones:** 4 (Información, Naturaleza, Limitaciones, Confidencialidad)

### **Consentimiento 3: Información Médica** ?
- **Código:** `CONSENT_MEDICAL_RECORD`
- **Versión:** 1
- **Obligatorio:** Sí
- **Contenido:** Registro, uso, acceso, derechos
- **Secciones:** 5 (Información, Uso, Acceso, Derechos, Seguridad)

### **Consentimiento 4: Compartir con Empleador** ?
- **Código:** `CONSENT_SHARE_WITH_EMPLOYER`
- **Versión:** 1
- **Obligatorio:** **No** (Opcional)
- **Contenido:** Autorización compartir, revocación
- **Secciones:** 6 (Entidad, Info NO compartida, Propósito, Uso, Revocación, Legal)

---

## ?? **Próximos Pasos Inmediatos:**

### **PASO 4: Componente de Firma Digital** ???

**Archivos a crear:**

1. **SignaturePad.razor** - Componente Blazor reutilizable
2. **signature-pad.js** - JavaScript para captura de firma
3. **signature-pad.css** - Estilos del componente

**Funcionalidades:**

- ? Canvas HTML5 para dibujar firma
- ? Botón "Limpiar" para reintentar
- ? Botón "Guardar"
- ? Conversión a PNG Base64
- ? Validación de firma no vacía
- ? Preview de la firma
- ? Responsive (móvil y escritorio)

**Tecnologías:**

- Canvas API
- JavaScript Interop
- Blazor Component Model
- Base64 encoding

---

### **PASO 5: Página de Consentimientos** ??

**Archivo:** `Components/Pages/Patient/SignConsents.razor`

**Flujo de Usuario:**

```
Paciente ? Completar Perfil ? Firmar Consentimientos ? Test
              ?                       ?                    ?
         ProfileCompleted=T    ConsentsSigned=T    TestReady=T
```

**Características:**

- ? Wizard de 4 pasos (uno por consentimiento)
- ? Scroll obligatorio hasta el final
- ? Checkbox "He leído y acepto"
- ? Integración con SignaturePad
- ? Botón "Siguiente" / "Finalizar"
- ? Barra de progreso visual
- ? Validación en cada paso
- ? Guardado automático

---

### **PASO 6: Generación de PDFs** ??

**Librería Recomendada:** QuestPDF

**Instalación:**
```powershell
cd "Salutia Wep App"
dotnet add package QuestPDF
```

**Características del PDF:**

- ? Logo de SALUTIA
- ? Encabezado con fecha y datos del paciente
- ? Contenido HTML del consentimiento
- ? Firma digital embebida
- ? Metadatos (IP, UserAgent, timestamp)
- ? Footer con hash MD5
- ? Numeración de páginas

---

## ?? **Flujo Completo del Paciente (Actualizado):**

```
1. Registro de Paciente
   ?
2. Confirmar Email
   ?
3. Primer Login
   ?
4. Sistema detecta ProfileCompleted = false
   ?
5. Redirige a /Patient/CompleteProfile
   ?
6. Paciente completa información personal
   ?
7. Sistema marca ProfileCompleted = true
   ?
8. Sistema detecta ConsentsSigned = false ? NUEVO
   ?
9. Redirige a /Patient/SignConsents ? NUEVO
   ?
10. Paciente firma 4 consentimientos ? NUEVO
    ?
11. Sistema genera 4 PDFs ? NUEVO
    ?
12. Sistema marca ConsentsSigned = true ? NUEVO
    ?
13. Redirige automáticamente al test
    ?
14. Paciente puede realizar el test ?
```

---

## ?? **Estructura de Archivos Actualizada:**

### **Creados hasta ahora:**

```
Salutia Wep App/
??? Models/
?   ??? Consent/
?       ??? ConsentModels.cs ?
??? Services/
?   ??? ConsentService.cs ?
??? Data/
?   ??? ApplicationDbContext.cs ? (actualizado)
?   ??? Migrations/
?   ?   ??? 20251204175708_AddConsentInformedSystem.cs ?
?   ??? SeedData/
?       ??? SeedConsentTemplates.sql ? (EJECUTADO)
??? Program.cs ? (actualizado)
```

### **Próximos a crear:**

```
Salutia Wep App/
??? Components/
?   ??? Shared/
?   ?   ??? SignaturePad.razor ? SIGUIENTE
?   ?   ??? SignaturePad.razor.css ?
?   ??? Pages/
?       ??? Patient/
?           ??? SignConsents.razor ?
??? wwwroot/
?   ??? js/
?   ?   ??? signature-pad.js ?
?   ??? consents/
?       ??? pdfs/ (auto-generado)
??? Services/
    ??? PdfGenerationService.cs ?
```

---

## ?? **Plan de Pruebas:**

### **Prueba 1: Verificar Plantillas en BD**
```sql
USE [Salutia-TBE]
SELECT * FROM ConsentTemplates ORDER BY DisplayOrder
```
? **Resultado:** 4 plantillas

### **Prueba 2: Verificar Servicio Registrado**
```csharp
// En Program.cs
builder.Services.AddScoped<IConsentService, ConsentService>();
```
? **Verificado**

### **Prueba 3: Compilación**
```powershell
dotnet build
```
? **Sin errores**

---

## ?? **Diseño de UI Propuesto:**

### **Página de Consentimientos:**

```
???????????????????????????????????????????
?  ?? Consentimientos Informados          ?
?  ??????????????????????  1 de 4        ?
???????????????????????????????????????????
?                                         ?
?  Consentimiento de Protección de Datos ?
?                                         ?
?  [Contenido HTML del consentimiento]    ?
?  ...                                    ?
?  ...                                    ?
?  (scroll obligatorio)                   ?
?                                         ?
?  ? He leído y acepto este consentimiento?
?                                         ?
?  ???????????????????????????????????   ?
?  ?  ?? Por favor, firme aquí:      ?   ?
?  ?  ?????????????????????????????  ?   ?
?  ?  ?                           ?  ?   ?
?  ?  ?  (Canvas para firma)      ?  ?   ?
?  ?  ?                           ?  ?   ?
?  ?  ?????????????????????????????  ?   ?
?  ?  [Limpiar]  [Guardar y Siguiente]  ?
?  ???????????????????????????????????   ?
?                                         ?
???????????????????????????????????????????
```

---

## ?? **Decisiones Técnicas Confirmadas:**

### **1. Almacenamiento de Firmas:**
- **Formato:** PNG Base64
- **Tamaño:** 400x200 px (configurable)
- **Color:** Negro sobre blanco
- **Campo:** `ConsentSignature.SignatureDataBase64` (nvarchar(MAX))

### **2. Generación de PDFs:**
- **Librería:** QuestPDF (recomendada)
  - Alternativa: iTextSharp
- **Ubicación:** `wwwroot/consents/pdfs/`
- **Nomenclatura:** `consent_{id}_{timestamp}.pdf`
- **Registro:** Tabla `ConsentDocuments`

### **3. Validación:**
- **Cliente:** JavaScript + Blazor
- **Servidor:** ConsentService
- **Reglas:**
  - 3 de 4 consentimientos son obligatorios
  - Firma no puede estar vacía
  - Debe hacer scroll hasta el final
  - Checkbox debe estar marcado

---

## ?? **Listo para Continuar:**

Ahora voy a proceder con:

1. ? Instalar librería de PDFs (QuestPDF)
2. ? Crear componente SignaturePad.razor
3. ? Crear JavaScript signature-pad.js
4. ? Crear página SignConsents.razor
5. ? Actualizar TestPsicosomatico.razor (validación)

---

**¿Estás listo para continuar con el componente de firma digital?** ??

Si me das luz verde, procedo a crear:
1. El componente de firma digital completo
2. El archivo JavaScript necesario
3. Los estilos CSS

¡Vamos por el 50% de completitud! ??
