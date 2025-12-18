# ?? Sistema de Consentimientos Informados Digitales - Progreso

## ? Estado Actual: 33% Completado (3 de 9 pasos)

---

## ?? Objetivo del Sistema

Implementar un sistema completo de consentimientos informados digitales que permita:
- Recopilar consentimientos antes del test psicosomático
- Firmar electrónicamente con pad de firma
- Generar PDFs diligenciados
- Permitir descarga por profesionales y entidades
- Editar plantillas por SuperAdmin y EntityAdmin
- Auditoría completa de cambios y descargas

---

## ? PASOS COMPLETADOS

### **Paso 1: ? Modelos Creados**

**Archivo:** `Salutia Wep App/Models/Consent/ConsentModels.cs`

**Modelos Implementados:**

| Modelo | Descripción | Campos Clave |
|--------|-------------|--------------|
| `ConsentTemplate` | Plantilla de consentimiento editable | Title, Code, ContentHtml, Version, EntityId |
| `PatientConsent` | Registro de consentimiento firmado | PsychosomaticTestId, ConsentTemplateId, IsAccepted |
| `ConsentSignature` | Firma digital del paciente | SignatureDataBase64, SignatureType, SignerFullName |
| `ConsentDocument` | Registro de PDFs generados | DocumentUrl, DocumentPath, FileHash, DownloadCount |
| `ConsentTemplateHistory` | Historial de cambios en plantillas | PreviousVersion, PreviousContentHtml, ChangeReason |

**Características Clave:**
- ? Soporte para plantillas globales y por entidad
- ? Versionamiento de plantillas
- ? Tipos de firma: Dibujada, Tipografiada, Imagen
- ? Auditoría completa con IP, User Agent, timestamps
- ? Hash MD5 para verificación de integridad de PDFs

---

### **Paso 2: ? Migración de Base de Datos**

**Archivo:** `Salutia Wep App/Data/Migrations/20251204175708_AddConsentInformedSystem.cs`

**Tablas Creadas:**

```sql
1. ConsentTemplates           -- Plantillas de consentimientos
2. PatientConsents            -- Consentimientos firmados
3. ConsentSignatures          -- Firmas digitales
4. ConsentDocuments           -- PDFs generados
5. ConsentTemplateHistories   -- Historial de cambios
```

**Índices Creados:**
- `IX_ConsentTemplates_Code`
- `IX_ConsentTemplates_EntityId_Code`
- `IX_PatientConsents_PsychosomaticTestId_ConsentTemplateId`
- `IX_PatientConsents_PatientUserId`
- `IX_ConsentDocuments_PsychosomaticTestId`
- `IX_ConsentSignatures_PatientConsentId` (Unique)

**Estado:** ? Aplicada exitosamente

---

### **Paso 3: ? Servicio de Gestión**

**Archivo:** `Salutia Wep App/Services/ConsentService.cs`

**Métodos Implementados: 18**

#### **Gestión de Plantillas (5 métodos):**
| Método | Descripción |
|--------|-------------|
| `GetActiveTemplatesAsync()` | Obtiene plantillas activas (globales o por entidad) |
| `GetTemplateByCodeAsync()` | Busca plantilla por código |
| `CreateTemplateAsync()` | Crea nueva plantilla |
| `UpdateTemplateAsync()` | Actualiza plantilla y guarda historial |
| `DeactivateTemplateAsync()` | Desactiva plantilla |

#### **Gestión de Consentimientos (3 métodos):**
| Método | Descripción |
|--------|-------------|
| `GetConsentsByTestAsync()` | Obtiene consentimientos de un test |
| `HasSignedAllRequiredConsentsAsync()` | Valida si firmó todos los obligatorios |
| `SaveConsentAsync()` | Guarda consentimiento + firma |

#### **Generación de PDFs (2 métodos):**
| Método | Descripción |
|--------|-------------|
| `GenerateConsentPdfAsync()` | Genera PDF individual |
| `GenerateAllConsentsPdfPackageAsync()` | Genera paquete con todos |

#### **Descarga y Auditoría (4 métodos):**
| Método | Descripción |
|--------|-------------|
| `GetDocumentAsync()` | Obtiene documento por ID |
| `RegisterDownloadAsync()` | Registra descarga |
| `GetDocumentsByTestAsync()` | Lista documentos de un test |
| `GetTemplateHistoryAsync()` | Historial de cambios |

#### **Validación (1 método):**
| Método | Descripción |
|--------|-------------|
| `ValidateConsentIntegrityAsync()` | Valida integridad con hash MD5 |

#### **Métodos Auxiliares (3):**
- `CalculateFileHashAsync()` - Calcula hash MD5
- Gestión de directorios
- Transacciones de base de datos

**Estado:** ? Implementado y registrado en `Program.cs`

---

## ?? Datos Semilla

**Archivo:** `Salutia Wep App/Data/SeedData/SeedConsentTemplates.sql`

### **4 Plantillas de Consentimiento:**

| # | Título | Código | Obligatorio | Contenido |
|---|--------|--------|-------------|-----------|
| 1 | Protección de Datos Personales | `CONSENT_DATA_PRIVACY` | ? Sí | Ley 1581 de 2012, derechos ARCO, finalidad |
| 2 | Evaluación Psicológica | `CONSENT_PSYCHOLOGICAL_EVAL` | ? Sí | Naturaleza, limitaciones, confidencialidad |
| 3 | Registro Información Médica | `CONSENT_MEDICAL_RECORD` | ? Sí | Historia clínica, acceso, seguridad |
| 4 | Compartir con Empleador | `CONSENT_SHARE_WITH_EMPLOYER` | ? No | Resultados a entidad, revocación |

**Características del Script:**
- ? Verifica existencia de SuperAdmin
- ? Contenido HTML completo y formateado
- ? Referencias legales (Ley 1581, Ley 1090, Res. 2346)
- ? Secciones claras y estructuradas
- ? Alertas y notas informativas

**Estado:** ? Listo para ejecutar

---

## ?? PASOS PENDIENTES (6 de 9)

### **Paso 4: Componente de Firma Digital** ?

**Tareas:**
- Crear componente Blazor `SignaturePad.razor`
- Integrar librería JavaScript para captura de firma
- Soporte para firma dibujada (canvas)
- Soporte para firma tipografiada
- Botón para limpiar y repetir
- Convertir a Base64 PNG

---

### **Paso 5: Página de Consentimientos** ?

**Archivo a Crear:** `Components/Pages/Patient/SignConsents.razor`

**Funcionalidades:**
- Mostrar los 4 consentimientos en pasos
- Scroll obligatorio hasta el final
- Checkbox "He leído y acepto"
- Pad de firma integrado
- Validación antes de continuar
- Guardado automático

---

### **Paso 6: Repositorio de PDFs** ?

**Tareas:**
- Instalar librería de generación de PDFs (QuestPDF o iTextSharp)
- Crear plantilla HTML para PDFs
- Incluir logo y encabezado
- Firma digital en el PDF
- Metadatos (fecha, IP, versión)

---

### **Paso 7: Integración con Flujo del Test** ?

**Modificaciones:**
1. Actualizar `TestPsicosomatico.razor`
2. Agregar validación: Perfil Completo ? Consentimientos ? Test
3. Redirigir a `/Patient/SignConsents` si no ha firmado
4. Bloquear acceso al test sin consentimientos

---

### **Paso 8: Vista para Profesionales/Entidades** ?

**Archivos a Crear:**
- `Components/Pages/Professional/PatientConsents.razor`
- `Components/Pages/Entity/ConsentReports.razor`

**Funcionalidades:**
- Listar tests con consentimientos
- Botón "Descargar PDFs"
- Registro de descarga
- Verificación de integridad
- Historial de accesos

---

### **Paso 9: Gestión de Plantillas (Admin)** ?

**Archivos a Crear:**
- `Components/Pages/Admin/ManageConsentTemplates.razor`
- `Components/Pages/Admin/EditConsentTemplate.razor`
- `Components/Pages/Entity/EntityConsentTemplates.razor`

**Funcionalidades:**
- CRUD de plantillas
- Editor HTML rich-text
- Previsualización
- Historial de versiones
- Activar/Desactivar plantillas

---

## ?? Estructura de Archivos

### **Archivos Creados: 3**

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
?       ??? SeedConsentTemplates.sql ?
??? Program.cs ? (actualizado)
```

### **Archivos Pendientes: 8+**

```
Salutia Wep App/
??? Components/
?   ??? Shared/
?   ?   ??? SignaturePad.razor ?
?   ??? Pages/
?       ??? Patient/
?       ?   ??? SignConsents.razor ?
?       ??? Professional/
?       ?   ??? PatientConsents.razor ?
?       ??? Entity/
?       ?   ??? ConsentReports.razor ?
?       ?   ??? EntityConsentTemplates.razor ?
?       ??? Admin/
?           ??? ManageConsentTemplates.razor ?
?           ??? EditConsentTemplate.razor ?
??? wwwroot/
    ??? js/
    ?   ??? signature-pad.js ?
    ??? consents/
        ??? pdfs/ (creado automáticamente)
```

---

## ?? Próximos Pasos Inmediatos

### **1. Ejecutar Script de Datos Semilla** ??

```sql
-- Ejecutar en SQL Server Management Studio
USE SalutiaDB
GO
-- Copiar y ejecutar el contenido de:
Salutia Wep App/Data/SeedData/SeedConsentTemplates.sql
```

**Verificación:**
```sql
SELECT Id, Title, Code, IsRequired, IsActive 
FROM ConsentTemplates 
ORDER BY DisplayOrder
```

Deberías ver 4 plantillas insertadas.

---

### **2. Instalar Librería de PDFs** ??

Opción A - QuestPDF (Recomendado):
```powershell
cd "Salutia Wep App"
dotnet add package QuestPDF
```

Opción B - iTextSharp:
```powershell
cd "Salutia Wep App"
dotnet add package itext7
```

---

### **3. Crear Componente SignaturePad** ???

**Tecnologías a usar:**
- Canvas HTML5
- JavaScript para captura de trazos
- Interop de Blazor
- Conversión a Base64 PNG

---

### **4. Crear Página de Consentimientos** ??

**Flujo:**
```
1. Cargar plantillas activas
   ?
2. Mostrar consentimiento 1 de 4
   ?
3. Usuario lee (scroll hasta final)
   ?
4. Checkbox "He leído y acepto"
   ?
5. Firmar en pad digital
   ?
6. Guardar y pasar al siguiente
   ?
7. Repetir para 4 consentimientos
   ?
8. Generar PDFs
   ?
9. Redirigir al test
```

---

## ?? Métricas de Progreso

| Componente | Estado | Progreso |
|------------|--------|----------|
| **Modelos** | ? Completo | 100% |
| **Base de Datos** | ? Completo | 100% |
| **Servicio** | ? Completo | 100% |
| **Datos Semilla** | ? Pendiente | 0% |
| **Componente Firma** | ? No Iniciado | 0% |
| **Página Consentimientos** | ? No Iniciado | 0% |
| **Generación PDFs** | ? No Iniciado | 0% |
| **Integración Test** | ? No Iniciado | 0% |
| **Vista Profesionales** | ? No Iniciado | 0% |
| **Gestión Admin** | ? No Iniciado | 0% |
| **TOTAL** | ?? En Progreso | **33%** |

---

## ?? Decisiones Técnicas

### **Firma Digital:**
- **Formato:** PNG Base64
- **Almacenamiento:** Directamente en BD (campo nvarchar(max))
- **Validación:** Nombre + Documento debe coincidir con perfil
- **Tamaño recomendado:** 400x200 px

### **PDFs:**
- **Librería:** QuestPDF (moderna, performante, open-source)
- **Almacenamiento:** Archivo físico + registro en BD
- **Seguridad:** Hash MD5 para verificación de integridad
- **Nomenclatura:** `consent_{id}_{timestamp}.pdf`

### **Flujo de Validación:**
```
Registro ? Confirmar Email ? Login
    ?
Completar Perfil
    ?
Firmar 4 Consentimientos ? NUEVO
    ?
Realizar Test Psicosomático
```

### **Auditoría:**
- Registro de IP y User Agent en cada firma
- Snapshot del HTML al momento de firmar
- Historial completo de cambios en plantillas
- Log de descargas con usuario y timestamp

---

## ?? Listo para Continuar

Una vez que ejecutes el script de datos semilla y confirmes que las 4 plantillas están en la BD, podemos proceder con:

1. Instalar librería de PDFs
2. Crear componente SignaturePad
3. Crear página de consentimientos
4. Integrar con flujo del test

---

**?? Sistema de Consentimientos: 33% Completado**  
**?? Fecha: 2025-01-19**  
**? Fundación sólida construida - Lista para UI/UX**
