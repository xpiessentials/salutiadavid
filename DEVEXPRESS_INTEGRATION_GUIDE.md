# Guía de Integración DevExpress 22.1 en Salutia

## ?? Resumen

Esta guía describe cómo integrar DevExpress 22.1 en el proyecto Salutia para:
- ? Crear formularios interactivos
- ? Generar reportes PDF
- ? Visualizar datos con grids y gráficos

---

## ?? Estado Actual

### ? Ya Configurado
- Paquetes DevExpress 22.1.4 agregados al `.csproj`
- Servicio `PdfReportService` creado (pendiente implementación)
- Controlador `ReportController` para descargar PDFs
- Modelos de datos para reportes

### ?? Pendiente
- Configuración completa de DevExpress Blazor UI
- Implementación del servicio de reportes PDF
- Componentes de formulario con DevExpress

---

## ?? Configuración Inicial

### 1. Paquetes Necesarios

Ya instalados en `Salutia Wep App.csproj`:
```xml
<PackageReference Include="DevExpress.Pdf.Core" Version="22.1.4" />
<PackageReference Include="DevExpress.Pdf.Drawing" Version="22.1.4" />
```

### 2. Licencia DevExpress

?? **IMPORTANTE**: DevExpress requiere una licencia válida. Asegúrate de tener:
- Licencia comercial o trial de DevExpress 22.1
- `licenses.licx` configurado en el proyecto

---

## ?? Generación de Reportes PDF

### Arquitectura Implementada

```
Usuario ? Controlador ? Servicio PDF ? DevExpress ? Archivo PDF
```

### Archivos Clave

1. **Servicio**: `Salutia Wep App/Services/PdfReportService.cs`
2. **Controlador**: `Salutia Wep App/Controllers/ReportController.cs`
3. **Modelos**: `Salutia Wep App/Models/Reports/ReportModels.cs`

### Endpoints Disponibles

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/report/patient/{id}` | GET | Reporte completo del paciente |
| `/api/report/appointments/{id}` | GET | Historial de citas médicas |
| `/api/report/psychosomatic-test/{id}` | GET | Resultado del test psicosomático |
| `/api/report/psychosomatic-test` | POST | Generar reporte desde datos |

### Ejemplo de Uso desde Blazor

```razor
@inject HttpClient Http
@inject IJSRuntime JSRuntime

<button class="btn btn-danger" @onclick="DownloadPatientReport">
    <i class="bi bi-file-pdf"></i> Descargar Reporte PDF
</button>

@code {
    [Parameter] public string PatientId { get; set; } = string.Empty;
    
    private async Task DownloadPatientReport()
    {
        var url = $"/api/report/patient/{PatientId}";
        await JSRuntime.InvokeVoidAsync("open", url, "_blank");
    }
}
```

---

## ?? Formularios (Próxima Implementación)

### Componentes DevExpress Recomendados

#### Entrada de Datos
```razor
<!-- TextBox -->
<DxTextBox @bind-Value="@model.Name" 
       NullText="Ingrese nombre..."
  CssClass="w-100" />

<!-- DateEdit -->
<DxDateEdit @bind-Date="@model.BirthDate"
DisplayFormat="dd/MM/yyyy"
     MaxDate="@DateTime.Today" />

<!-- ComboBox -->
<DxComboBox Data="@options" 
   @bind-Value="@model.Selection"
   NullText="Seleccione..." />

<!-- Memo (multilínea) -->
<DxMemo @bind-Text="@model.Notes" 
        Rows="4"
    NullText="Ingrese observaciones..." />
```

#### Layout de Formulario
```razor
<DxFormLayout>
    <DxFormLayoutGroup Caption="Información Personal">
     <DxFormLayoutItem Caption="Nombre:" ColSpanMd="6">
            <Template>
      <DxTextBox @bind-Value="@patient.FullName" />
      </Template>
  </DxFormLayoutItem>
        
        <DxFormLayoutItem Caption="Email:" ColSpanMd="6">
    <Template>
 <DxTextBox @bind-Value="@patient.Email" />
      </Template>
        </DxFormLayoutItem>
    </DxFormLayoutGroup>
</DxFormLayout>
```

---

## ?? Visualización de Datos

### Grid de Datos

```razor
<DxGrid Data="@patients"
        PageSize="15"
        ShowFilterRow="true">
    <Columns>
  <DxGridDataColumn FieldName="IdNumber" Caption="Identificación" />
        <DxGridDataColumn FieldName="FullName" Caption="Nombre" />
        <DxGridDataColumn FieldName="Email" Caption="Email" />
        <DxGridDataColumn FieldName="Phone" Caption="Teléfono" />
        
        <DxGridCommandColumn Width="150px">
         <CellDisplayTemplate>
    <button @onclick="() => ViewDetails(context)">Ver</button>
    <button @onclick="() => GeneratePdf(context)">PDF</button>
          </CellDisplayTemplate>
        </DxGridCommandColumn>
    </Columns>
</DxGrid>
```

### Calendario/Agenda

```razor
<DxScheduler StartDate="@DateTime.Today"
     DataStorage="@appointmentsDataStorage"
   ActiveViewType="@SchedulerViewType.Week">
    <DxSchedulerDayView ShowWorkTimeOnly="true" />
    <DxSchedulerWeekView ShowWorkTimeOnly="true" />
    <DxSchedulerMonthView />
</DxScheduler>
```

---

## ?? Seguridad

### Control de Acceso

Todos los endpoints de reportes requieren autenticación:

```csharp
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ReportController : ControllerBase
{
    // ...endpoints seguros
}
```

### Validación de Datos

Siempre valida los datos antes de generar reportes:

```csharp
public async Task<IActionResult> GetPatientReport(string patientId)
{
    var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
    
    // Verificar que el usuario tenga acceso al paciente
if (!await HasAccessToPatient(userId, patientId))
    {
      return Forbid();
    }
    
    // Generar reporte...
}
```

---

## ?? Modelos de Datos

### PatientFormModel

Modelo completo para formulario de paciente:

```csharp
public class PatientFormModel
{
    // Información Personal
    public string FullName { get; set; }
    public string IdNumber { get; set; }
    public DateTime BirthDate { get; set; }
    public string Gender { get; set; }
    
    // Contacto
    public string Email { get; set; }
    public string Phone { get; set; }
    public string Address { get; set; }
    
    // Médico
    public string BloodType { get; set; }
    public List<string> Allergies { get; set; }
    public string MedicalHistory { get; set; }
    
    // Emergencia
    public string EmergencyContactName { get; set; }
    public string EmergencyContactPhone { get; set; }
}
```

### ReportModels

Ver `Salutia Wep App/Models/Reports/ReportModels.cs` para:
- `PatientReportModel` - Reporte de paciente
- `AppointmentReportModel` - Reporte de citas
- `PsychosomaticTestReportModel` - Reporte de test
- `MedicalRecordReportModel` - Historial médico

---

## ?? Próximos Pasos

### 1. Implementar Generación de PDF

Completar `PdfReportService.cs` usando DevExpress.Pdf:

```csharp
public byte[] GeneratePatientReport(PatientReportModel patient)
{
 // Crear documento PDF
    // Agregar contenido con texto, tablas, gráficos
    // Aplicar formato y estilos
// Exportar a byte array
    return pdfBytes;
}
```

### 2. Crear Formularios Blazor

Crear páginas de formularios en `Components/Pages/`:
- `Pacientes/NuevoPaciente.razor` - Registro de paciente
- `Pacientes/ListaPacientes.razor` - Grid de pacientes
- `Citas/CalendarioCitas.razor` - Calendario de citas
- `Reportes/GenerarReporte.razor` - Interfaz de reportes

### 3. Integrar con Base de Datos

Conectar servicios con Entity Framework:
- Leer datos de pacientes
- Guardar formularios
- Consultar historial médico

---

## ?? Tips y Mejores Prácticas

### Performance

1. **Caché de Reportes**: Cachea PDFs generados frecuentemente
```csharp
services.AddMemoryCache();
services.AddResponseCaching();
```

2. **Generación Asíncrona**: Para reportes grandes, usa procesamiento en segundo plano
```csharp
services.AddHostedService<ReportGenerationService>();
```

### UX/UI

1. **Indicadores de Progreso**: Muestra spinners durante generación
```razor
@if (isGenerating)
{
    <div class="spinner-border"></div>
    <span>Generando reporte...</span>
}
```

2. **Validación en Cliente**: Valida formularios antes de enviar
```razor
<EditForm Model="@patient" OnValidSubmit="@Save">
    <DataAnnotationsValidator />
    <ValidationSummary />
    <!-- campos -->
</EditForm>
```

---

## ?? Recursos Adicionales

### Documentación Oficial
- [DevExpress Blazor Components](https://docs.devexpress.com/Blazor/400725/blazor-components)
- [DevExpress PDF Library](https://docs.devexpress.com/OfficeFileAPI/14912/pdf-document-api)
- [DevExpress Reporting](https://docs.devexpress.com/XtraReports/2162/web-reporting)

### Demos y Ejemplos
- [DevExpress Blazor Demos](https://demos.devexpress.com/blazor/)
- [PDF API Examples](https://github.com/DevExpress-Examples?q=pdf&type=&language=&sort=)

---

## ?? Troubleshooting

### Error: Licencia no Válida
- Verifica que tienes licencia activa de DevExpress 22.1
- Regenera `licenses.licx` si es necesario

### Error: Paquetes no Encontrados
- Verifica que el feed DevExpress Local esté configurado
- Versión disponible localmente: 22.1.4

### Error: PDF Vacío
- Implementar lógica completa en `PdfReportService`
- Ver ejemplos de DevExpress.Pdf.Drawing

---

## ?? Notas Finales

Esta guía proporciona la base para integrar DevExpress 22.1 en Salutia. La implementación completa requiere:

1. ? Licencia válida de DevExpress
2. ?? Completar implementación de `PdfReportService`
3. ?? Crear componentes Blazor de formularios
4. ?? Integrar con base de datos
5. ?? Pruebas exhaustivas

**Estado Actual**: Estructura base lista, pendiente implementación de funcionalidad completa.

---

¿Necesitas ayuda con alguna parte específica de la integración?
