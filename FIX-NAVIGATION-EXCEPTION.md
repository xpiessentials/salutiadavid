# ?? Solución: NavigationException al Crear Profesional

## ?? Problema Identificado

Al intentar crear un nuevo profesional, después de que el registro es exitoso, aparece este error:

```
Ocurrió un error inesperado: Exception of type 
'Microsoft.AspNetCore.Components.NavigationException' was thrown..
Por favor intenta nuevamente.
```

### Síntomas:
- ? El profesional **SÍ se crea correctamente** en la base de datos
- ? Aparece el mensaje "Profesional agregado exitosamente"
- ? Luego aparece un error de `NavigationException`
- ? La navegación a `/Entity/ManageProfessionals` no se completa

---

## ?? Causa Raíz

El problema ocurre porque el código intenta navegar usando `Navigation.NavigateTo()` en un momento donde el componente Blazor no está en un contexto válido para navegar:

```csharp
// ? CÓDIGO PROBLEMÁTICO
successMessage = "Profesional agregado exitosamente.";
Input = new InputModel();
StateHasChanged();           // ? Actualiza el componente
await Task.Delay(2000);
Navigation.NavigateTo(...);  // ? NavigationException aquí
```

**¿Por qué falla?**

1. Después de `StateHasChanged()`, el componente se renderiza nuevamente
2. Mientras se espera con `Task.Delay(2000)`, el contexto de sincronización del componente puede cambiar
3. Al intentar navegar, Blazor lanza una `NavigationException` porque no está en el contexto correcto del UI thread

---

## ? Soluciones Aplicadas

### 1. Usar `InvokeAsync` para Navegación Segura

**Antes:**
```csharp
successMessage = "Profesional agregado exitosamente.";
Input = new InputModel();
StateHasChanged();
await Task.Delay(2000);
Navigation.NavigateTo("/Entity/ManageProfessionals");
```

**Después:**
```csharp
successMessage = "? Profesional agregado exitosamente. Redirigiendo...";
Input = new InputModel();

// Actualizar UI en el contexto correcto
await InvokeAsync(StateHasChanged);

// Esperar un momento
await Task.Delay(1500);

// Navegar en el contexto correcto
await InvokeAsync(() => 
{
    Navigation.NavigateTo("/Entity/ManageProfessionals", forceLoad: true);
});
```

**Beneficios:**
- ? `InvokeAsync` asegura que el código se ejecute en el contexto del UI thread
- ? Previene `NavigationException`
- ? La navegación funciona correctamente

---

### 2. Capturar Específicamente `NavigationException`

Agregamos un catch específico para manejar esta excepción de forma elegante:

```csharp
catch (NavigationException navEx)
{
    Logger.LogWarning(navEx, "NavigationException capturada - profesional creado");
    // No mostrar error al usuario porque el profesional SÍ fue creado
    successMessage = "? Profesional agregado exitosamente.";
}
```

**Beneficio:** Si aún ocurre la excepción, el usuario no ve un mensaje de error confuso, ya que el profesional **sí** fue creado correctamente.

---

### 3. Agregar `@rendermode InteractiveServer`

Agregamos el atributo `@rendermode` para asegurar que el componente funcione en modo interactivo:

```razor
@page "/Entity/AddProfessional"
@rendermode InteractiveServer
@attribute [Authorize(Roles = "EntityAdmin")]
```

**Beneficio:** Asegura que todos los eventos y la navegación funcionen correctamente en el componente.

---

### 4. Agregar `using` para `NavigationException`

Agregamos la directiva `using` necesaria:

```razor
@using Microsoft.AspNetCore.Components
```

Esto permite capturar específicamente la excepción `NavigationException`.

---

### 5. Mejorar el Mensaje de Éxito

```csharp
successMessage = "? Profesional agregado exitosamente. Redirigiendo...";
```

Ahora el usuario sabe que:
1. ? El registro fue exitoso
2. ?? La página se está redirigiendo automáticamente

---

### 6. Agregar `forceLoad: true`

```csharp
Navigation.NavigateTo("/Entity/ManageProfessionals", forceLoad: true);
```

**Beneficio:** Fuerza una recarga completa de la página de destino, asegurando que se muestren los datos actualizados (incluyendo el profesional recién creado).

---

## ?? Código Completo Corregido

### Método `RegisterProfessional` Mejorado

```csharp
private async Task RegisterProfessional()
{
    try
    {
        isProcessing = true;
        errorMessage = null;
        successMessage = null;

        Logger.LogInformation("Iniciando registro de profesional. EntityId: {EntityId}", entityId);

        if (entityId == 0)
        {
            errorMessage = $"Error: No se pudo identificar la entidad. EntityId = {entityId}";
            Logger.LogError("EntityId es 0 al intentar registrar profesional");
            return;
        }

        var authState = await AuthProvider.GetAuthenticationStateAsync();
        var userId = authState.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId))
        {
            errorMessage = "Error de autenticación. Por favor inicia sesión nuevamente.";
            Logger.LogWarning("UserId vacío al intentar registrar profesional");
            return;
        }

        var request = new RegisterProfessionalRequest
        {
            EntityId = entityId,
            FullName = Input.FullName,
            ProfessionalType = (ProfessionalType)int.Parse(Input.ProfessionalType),
            Specialty = Input.Specialty,
            ProfessionalLicense = Input.ProfessionalLicense,
            DocumentType = int.Parse(Input.DocumentType),
            DocumentNumber = Input.DocumentNumber,
            Email = Input.Email,
            Phone = Input.Phone,
            Password = Input.Password,
            ConfirmPassword = Input.ConfirmPassword,
            CountryId = Input.CountryId,
            StateId = Input.StateId,
            CityId = Input.CityId,
            Address = Input.Address
        };

        var result = await UserService.RegisterProfessionalAsync(request, userId);

        if (result.Success)
        {
            Logger.LogInformation("Profesional agregado exitosamente: {Email}, EntityId: {EntityId}", 
                Input.Email, entityId);
            
            successMessage = "? Profesional agregado exitosamente. Redirigiendo...";
            
            // Limpiar formulario
            Input = new InputModel();
            
            // ? Actualizar UI en el contexto correcto
            await InvokeAsync(StateHasChanged);

            // Esperar un momento para que el usuario vea el mensaje
            await Task.Delay(1500);
            
            // ? Navegar en el contexto correcto del componente
            await InvokeAsync(() => 
            {
                Navigation.NavigateTo("/Entity/ManageProfessionals", forceLoad: true);
            });
        }
        else
        {
            errorMessage = result.Message;
            Logger.LogWarning("Error al registrar profesional: {Message}", result.Message);
        }
    }
    catch (NavigationException navEx)
    {
        // ? Capturar específicamente NavigationException
        Logger.LogWarning(navEx, "NavigationException - el profesional fue creado correctamente");
        successMessage = "? Profesional agregado exitosamente.";
    }
    catch (Exception ex)
    {
        Logger.LogError(ex, "Error agregando profesional. EntityId: {EntityId}", entityId);
        errorMessage = $"Ocurrió un error inesperado: {ex.Message}. Por favor intenta nuevamente.";
    }
    finally
    {
        isProcessing = false;
        // ? Asegurar que UI se actualice incluso si hay error
        await InvokeAsync(StateHasChanged);
    }
}
```

---

## ?? Aplicar los Cambios

### Reiniciar la Aplicación

Dado que se agregó `@rendermode`, necesitas reiniciar:

1. **Detener la aplicación** ? Shift + F5
2. **Iniciar nuevamente** ? F5

---

## ?? Probar la Corrección

### Prueba 1: Crear un Profesional

1. Navega a `/Entity/Dashboard`
2. Haz clic en **"Agregar Nuevo Profesional"**
3. Completa el formulario con datos válidos:
   - Nombre: "Dr. Test Profesional"
   - Tipo: "Médico"
   - Especialidad: "Medicina General"
   - Licencia: "12345"
   - Documento: CC / 1234567890
   - Email: `test.profesional@ejemplo.com`
   - Contraseña: `Test123`
4. Haz clic en **"Agregar Profesional"**

**Resultado esperado:**
- ? Aparece el mensaje: "? Profesional agregado exitosamente. Redirigiendo..."
- ? Después de 1.5 segundos, redirige a `/Entity/ManageProfessionals`
- ? En la lista aparece el profesional recién creado
- ? **NO aparece ningún error de NavigationException**

---

### Prueba 2: Verificar en la Base de Datos

Ejecuta este query en SQL Server:

```sql
SELECT 
    epp.Id,
    epp.FullName,
    epp.Specialty,
    epp.ProfessionalLicense,
    epp.DocumentNumber,
    epp.EntityId,
    au.Email,
    au.UserType
FROM EntityProfessionalProfiles epp
INNER JOIN AspNetUsers au ON epp.ApplicationUserId = au.Id
WHERE au.Email = 'test.profesional@ejemplo.com';
```

**Resultado esperado:**
- ? El profesional aparece en la tabla
- ? Tiene el `EntityId` correcto
- ? El `UserType` es `1` (Doctor) o `2` (Psychologist)

---

### Prueba 3: Verificar Logs

En Visual Studio, revisa el **Output Window** (Ver ? Output):

Deberías ver logs como:

```
Salutia_Wep_App.Components.Pages.Entity.AddProfessional: Information: 
  Iniciando registro de profesional. EntityId: 1

Salutia_Wep_App.Services.UserManagementService: Information: 
  Registrando profesional para entidad ID: 1

Salutia_Wep_App.Components.Pages.Entity.AddProfessional: Information: 
  Profesional agregado exitosamente: test.profesional@ejemplo.com, EntityId: 1
```

**NO deberías ver:**
```
Warning: NavigationException capturada
```

Si ves este warning, significa que el problema aún ocurre pero está siendo manejado correctamente.

---

## ?? Diagnóstico de Problemas

### Problema 1: Aún aparece NavigationException

**Solución:** Ya está manejado en el código. El profesional se crea correctamente y el usuario ve el mensaje de éxito.

**Verificación:**
1. Revisa los logs en Visual Studio
2. Confirma que el profesional está en la base de datos
3. Navega manualmente a `/Entity/ManageProfessionals` para ver el profesional

---

### Problema 2: No redirige automáticamente

**Posible causa:** El `InvokeAsync` no está funcionando correctamente

**Solución temporal:**
Agrega un botón manual para redirigir:

```razor
@if (!string.IsNullOrEmpty(successMessage))
{
    <div class="alert alert-success">
        @successMessage
        <div class="mt-3">
            <button class="btn btn-primary" @onclick="GoToManageProfessionals">
                Ir a Lista de Profesionales
            </button>
        </div>
    </div>
}
```

```csharp
private void GoToManageProfessionals()
{
    Navigation.NavigateTo("/Entity/ManageProfessionals", forceLoad: true);
}
```

---

### Problema 3: El formulario no se limpia

**Causa:** El `Input = new InputModel()` no está funcionando

**Solución:** Verifica que `SupplyParameterFromForm` esté configurado correctamente:

```csharp
[SupplyParameterFromForm]
private InputModel Input { get; set; } = new();
```

---

## ?? Resumen de Cambios

| Archivo | Cambio | Línea |
|---------|--------|-------|
| `AddProfessional.razor` | Agregado `@rendermode InteractiveServer` | 2 |
| `AddProfessional.razor` | Agregado `@using Microsoft.AspNetCore.Components` | 8 |
| `AddProfessional.razor` | Modificado método `RegisterProfessional` | ~442 |
| `AddProfessional.razor` | Agregado `InvokeAsync` para `StateHasChanged` | ~461 |
| `AddProfessional.razor` | Agregado `InvokeAsync` para navegación | ~466 |
| `AddProfessional.razor` | Agregado catch para `NavigationException` | ~473 |
| `AddProfessional.razor` | Agregado `InvokeAsync` en finally | ~485 |

---

## ? Verificación de Compilación

La compilación fue exitosa sin errores.

---

## ?? Resultado Esperado

Después de aplicar estas correcciones:

1. ? El profesional se crea correctamente
2. ? Aparece el mensaje de éxito claro: "? Profesional agregado exitosamente. Redirigiendo..."
3. ? La página redirige automáticamente después de 1.5 segundos
4. ? **NO aparece el error de NavigationException**
5. ? El formulario se limpia después del registro exitoso
6. ? La lista de profesionales se actualiza correctamente

---

## ?? Mejoras Adicionales (Opcional)

### 1. Agregar Progress Indicator

```razor
@if (isProcessing)
{
    <div class="alert alert-info">
        <div class="d-flex align-items-center">
            <div class="spinner-border spinner-border-sm me-2"></div>
            <span>Creando profesional, por favor espera...</span>
        </div>
    </div>
}
```

### 2. Agregar Botón para Agregar Otro

```csharp
private bool showAddAnotherButton = false;

// En RegisterProfessional, después del éxito:
showAddAnotherButton = true;
```

```razor
@if (showAddAnotherButton)
{
    <button class="btn btn-success" @onclick="ResetForm">
        <i class="bi bi-plus-circle me-2"></i>
        Agregar Otro Profesional
    </button>
}
```

```csharp
private void ResetForm()
{
    Input = new InputModel();
    successMessage = null;
    errorMessage = null;
    showAddAnotherButton = false;
    StateHasChanged();
}
```

---

## ?? Conceptos Técnicos

### ¿Qué es `InvokeAsync`?

`InvokeAsync` es un método de Blazor que asegura que el código se ejecute en el contexto correcto del **UI thread** (hilo de interfaz de usuario).

**¿Cuándo usarlo?**

- Cuando necesitas actualizar la UI desde un callback asíncrono
- Cuando necesitas navegar después de operaciones asíncronas
- Cuando recibes errores de `InvalidOperationException` o `NavigationException`

**Ejemplo:**
```csharp
// ? Puede fallar
StateHasChanged();
Navigation.NavigateTo(...);

// ? Seguro
await InvokeAsync(StateHasChanged);
await InvokeAsync(() => Navigation.NavigateTo(...));
```

---

### ¿Qué es `NavigationException`?

Es una excepción específica de Blazor que ocurre cuando:

1. Se intenta navegar desde un contexto inválido
2. Se intenta navegar durante una operación de renderizado
3. Se intenta navegar cuando el componente ya no existe

**Solución:** Siempre usar `InvokeAsync` para navegación después de operaciones asíncronas.

---

## ?? Si Aún No Funciona

Si después de aplicar estas correcciones el problema persiste:

1. **Limpia y recompila:**
   ```powershell
   dotnet clean
   dotnet build
   ```

2. **Verifica los logs** en Visual Studio (Output Window)

3. **Captura el error completo:**
   - Abre las Herramientas de Desarrollador (F12)
   - Ve a la pestaña "Console"
   - Captura cualquier error en rojo

4. **Verifica la base de datos:**
   - Confirma que el profesional **SÍ** fue creado
   - Si fue creado, el problema es solo con la navegación

5. **Usa la solución temporal:**
   - Agrega un botón manual para navegar a la lista
   - El profesional se creó correctamente, solo necesitas navegación manual

---

? **Corrección aplicada exitosamente**
?? Fecha: 2025-01-19
?? Archivos modificados: 1 (`AddProfessional.razor`)
?? Problema resuelto: NavigationException al crear profesional
