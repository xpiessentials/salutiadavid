# ?? Guía Rápida - Salutia Mobile App

## ? Inicio Rápido (5 minutos)

### 1. Prerrequisitos

```powershell
# Verificar que tienes .NET 8 instalado
dotnet --version
# Debería mostrar 8.0.x o superior

# Verificar workloads de MAUI
dotnet workload list
# Debería mostrar: android, ios, maccatalyst, maui-windows
```

### 2. Abrir el Proyecto

```powershell
# Desde la raíz del repositorio
cd D:\Desarrollos\Repos\Salutia

# Abrir Visual Studio con la solución
start Salutia.sln
```

### 3. Compilar

En Visual Studio:
1. En el **Solution Explorer**, clic derecho en `Salutia.MobileApp`
2. Selecciona **"Build"**
3. Espera a que compile (primera vez puede tardar 2-3 minutos)

### 4. Ejecutar

#### En Android Emulator

1. En la barra superior, selecciona el dropdown de dispositivos
2. Elige un **Android Emulator** (ej: "Pixel 5 - API 34")
3. Presiona **F5** o clic en el botón ?? verde
4. ¡La app se abrirá en el emulador!

#### En Tu Teléfono Android (Depuración USB)

1. Habilita **"Opciones de desarrollador"** en tu Android:
   - Ve a **Ajustes ? Acerca del teléfono**
   - Toca **"Número de compilación"** 7 veces
   - Vuelve y entra en **"Opciones de desarrollador"**
   - Activa **"Depuración USB"**

2. Conecta tu teléfono por USB a la PC

3. En Visual Studio:
   - Selecciona tu dispositivo en el dropdown
   - Presiona **F5**

---

## ?? Estructura de la App

```
Inicio (Home)
??? Nueva Cita
??? Mi Salud
??? Medicamentos
??? Documentos

Bottom Navigation:
??? ?? Inicio
??? ?? Citas
??? ?? Salud
??? ?? Perfil
```

---

## ?? Modificar la UI

### Cambiar la Página de Inicio

Edita: `Salutia.MobileApp\Components\Pages\Home.razor`

```razor
@page "/"

<div class="container">
  <h1>¡Hola desde Salutia!</h1>
    <!-- Tu contenido aquí -->
</div>
```

### Cambiar Colores

Edita: `Salutia.MobileApp\wwwroot\css\app.css`

```css
:root {
    --salutia-primary: #1b6ec2; /* Cambia esto */
}
```

### Agregar un Botón en Home

```razor
<button class="btn btn-primary" @onclick="MiFuncion">
    <i class="bi bi-heart"></i> Clic Aquí
</button>

@code {
    private void MiFuncion()
    {
        // Tu código aquí
    }
}
```

---

## ?? Conectar a la API Web

### 1. Ejecutar la API Web

```powershell
# En otra terminal
cd "D:\Desarrollos\Repos\Salutia"
dotnet run --project "Salutia.AppHost\Salutia.AppHost.csproj"

# Anota la URL, ej: https://localhost:7213
```

### 2. Actualizar la URL en la App Móvil

Edita: `Salutia.MobileApp\MauiProgram.cs`

```csharp
builder.Services.AddHttpClient("SalutiaAPI", client =>
{
    // Cambiar a la URL de tu API local
    client.BaseAddress = new Uri("https://localhost:7213/");
});
```

### 3. Usar el HttpClient

```csharp
@inject IHttpClientFactory HttpClientFactory

@code {
    private async Task GetData()
    {
 var client = HttpClientFactory.CreateClient("SalutiaAPI");
        var response = await client.GetAsync("/api/users/me");
        // Procesar respuesta...
    }
}
```

---

## ?? Problemas Comunes

### "No Android emulator available"

**Solución**: Instalar un emulador

1. En Visual Studio: **Tools ? Android ? Android Device Manager**
2. Clic en **"+ New"**
3. Selecciona **"Pixel 5"** con **"API 34"**
4. Clic en **"Create"**
5. Espera a que descargue (puede tardar 10-15 minutos)

### "Build failed" en primera compilación

**Solución**: Limpiar y reconstruir

```powershell
dotnet clean
dotnet build "Salutia.MobileApp\Salutia.MobileApp.csproj"
```

### La app se abre pero muestra pantalla en blanco

**Solución**: Verificar que index.html está en wwwroot

```powershell
# Debe existir este archivo:
Test-Path "Salutia.MobileApp\wwwroot\index.html"
# Debe devolver: True
```

---

## ?? Tareas Comunes

### Agregar una Nueva Página

```razor
<!-- Salutia.MobileApp/Components/Pages/MiPagina.razor -->
@page "/mipagina"

<PageTitle>Mi Página</PageTitle>

<div class="container">
    <h1>Mi Nueva Página</h1>
</div>
```

### Navegar a Otra Página

```razor
@inject NavigationManager Nav

<button @onclick="() => Nav.NavigateTo('/mipagina')">
    Ir a Mi Página
</button>
```

### Mostrar un Alert

```razor
@inject IAlertService AlertService

<button @onclick="MostrarAlerta">Mostrar Alert</button>

@code {
    private void MostrarAlerta()
    {
        // TODO: Implementar AlertService
        // await AlertService.ShowAsync("Título", "Mensaje");
    }
}
```

### Guardar Datos Localmente

```csharp
// Guardar
await SecureStorage.SetAsync("mi_dato", "valor");

// Leer
string valor = await SecureStorage.GetAsync("mi_dato");

// Eliminar
SecureStorage.Remove("mi_dato");
```

---

## ?? Checklist de Inicio

- [ ] .NET 8 instalado
- [ ] Visual Studio 2022 con workload MAUI
- [ ] Android emulator configurado
- [ ] Proyecto compila sin errores
- [ ] App se ejecuta en emulador
- [ ] Navega entre páginas correctamente

---

## ?? Ayuda

- **Documentación completa**: Ver `MOBILE_APP_README.md`
- **Problemas**: Revisar `TROUBLESHOOTING.md`
- **API Web**: Ver `DATABASE_SETUP.md`

---

## ?? ¡Listo!

Ahora puedes empezar a desarrollar la app móvil de Salutia.

**Próximo paso**: Implementa el servicio de autenticación en `Salutia.MobileApp\Services\AuthService.cs`

```csharp
// TODO: Implementar
public class AuthService : IAuthService
{
    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
  // Tu código aquí
    }
}
```

**¡Happy Coding!** ????
