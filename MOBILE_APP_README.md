# ?? Salutia Mobile App - Aplicación Móvil Multiplataforma

## ?? Descripción General

Salutia Mobile App es una aplicación móvil nativa multiplataforma desarrollada con **.NET MAUI (Multi-platform App UI)** y **Blazor Hybrid**. Proporciona las mismas funcionalidades que la aplicación web Salutia, optimizadas para dispositivos iOS y Android.

---

## ??? Arquitectura

### Tecnologías Principales

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **.NET MAUI** | 9.0+ | Framework multiplataforma |
| **Blazor Hybrid** | 9.0+ | UI con componentes Blazor reutilizables |
| **CommunityToolkit.Maui** | 12.2.0 | Componentes y funcionalidades adicionales |
| **.NET 8** | 8.0 | Runtime y librerías base |

### Estructura del Proyecto

```
Salutia.MobileApp/
??? Components/
?   ??? Layout/
?   ?   ??? MainLayout.razor  # Layout principal con navegación
?   ??? Pages/
?   ?   ??? Home.razor              # Página de inicio
?   ?   ??? Login.razor       # Página de inicio de sesión
?   ??? Routes.razor       # Configuración de rutas
?   ??? _Imports.razor          # Imports globales
??? Pages/
?   ??? MainPage.xaml         # Página MAUI principal
?   ??? MainPage.xaml.cs
??? Platforms/
? ??? Android/        # Código específico de Android
?   ??? iOS/            # Código específico de iOS
?   ??? Windows/        # Código específico de Windows
?   ??? MacCatalyst/         # Código específico de macOS
??? Resources/
?   ??? Fonts/       # Fuentes personalizadas
?   ??? Images/   # Imágenes y recursos gráficos
?   ??? Raw/                  # Archivos raw
?   ??? Styles/# Estilos XAML
??? wwwroot/
?   ??? css/
?   ?   ??? app.css     # Estilos CSS personalizados
?   ??? index.html # HTML host para Blazor
??? App.xaml        # Aplicación MAUI
??? AppShell.xaml          # Shell de navegación
??? MauiProgram.cs           # Punto de entrada y configuración

Salutia.Shared/
??? Models/
?   ??? AuthModels.cs      # Modelos compartidos
??? Services/
?   ??? IAuthService.cs    # Interfaces de servicios
??? GlobalUsings.cs          # Usings globales
```

---

## ?? Características Implementadas

### ? Funcionalidades Actuales

1. **Arquitectura Blazor Hybrid**
   - Componentes Blazor reutilizables
   - Navegación entre páginas
   - Estados y ciclo de vida de componentes

2. **UI/UX Optimizada para Móvil**
   - Diseño responsive
 - Soporte para Safe Areas (iOS)
   - Navegación bottom bar
   - Cards y componentes touch-friendly

3. **Sistema de Navegación**
   - Inicio (Home)
   - Citas Médicas
   - Salud
   - Perfil
   - Login

4. **Integración con Bootstrap**
- Bootstrap 5.3.2
   - Bootstrap Icons 1.11.1
   - Diseño consistente con la web

5. **Preparación para Servicios**
   - HttpClient configurado
   - Interfaces de servicios definidas
   - Modelos compartidos entre web y móvil

---

## ?? Paquetes NuGet Instalados

```xml
<PackageReference Include="Microsoft.Maui.Controls" Version="9.0.90" />
<PackageReference Include="Microsoft.Maui.Controls.Compatibility" Version="9.0.90" />
<PackageReference Include="Microsoft.AspNetCore.Components.WebView.Maui" Version="9.0.120" />
<PackageReference Include="Microsoft.Extensions.Http" Version="9.0.10" />
<PackageReference Include="CommunityToolkit.Maui" Version="12.2.0" />
<PackageReference Include="Microsoft.Extensions.Logging.Debug" Version="9.0" />
```

---

## ??? Configuración del Entorno

### Requisitos Previos

#### Para Desarrollo

1. **Visual Studio 2022 (17.8+)** o **Visual Studio for Mac**
   - Workload: ".NET Multi-platform App UI development"

2. **Workloads de .NET MAUI** instaladas:
   ```powershell
   dotnet workload install maui
   dotnet workload install maui-android
   dotnet workload install maui-ios
   dotnet workload install maui-maccatalyst
   dotnet workload install maui-windows
   ```

3. **SDKs Específicos por Plataforma**:
   - **Android**: Android SDK 34+ (instalado con Visual Studio)
   - **iOS**: Xcode 15+ (solo en Mac)
   - **Windows**: Windows 11 SDK

#### Verificar Instalación

```powershell
# Ver workloads instaladas
dotnet workload list

# Ver versión de .NET MAUI
dotnet --version

# Verificar que MAUI está disponible
dotnet new maui --help
```

---

## ?? Compilar y Ejecutar

### Desde Visual Studio

#### Android

1. Selecciona **Android Emulator** o un dispositivo físico en el dropdown
2. Presiona **F5** o clic en el botón ?? "Android Emulator"
3. La primera compilación puede tardar varios minutos

#### iOS (solo en Mac)

1. Selecciona **iOS Simulator** o un dispositivo físico
2. Presiona **F5** o clic en el botón ?? "iOS Simulator"
3. Puede requerir aprovisionamiento y certificados de Apple

#### Windows

1. Selecciona **Windows Machine**
2. Presiona **F5**
3. La app se ejecutará como aplicación nativa de Windows

### Desde Línea de Comandos

#### Android

```powershell
# Compilar
dotnet build "Salutia.MobileApp\Salutia.MobileApp.csproj" -f net8.0-android

# Ejecutar en emulador
dotnet build "Salutia.MobileApp\Salutia.MobileApp.csproj" -t:Run -f net8.0-android
```

#### iOS (en Mac)

```bash
# Compilar
dotnet build Salutia.MobileApp/Salutia.MobileApp.csproj -f net8.0-ios

# Ejecutar en simulador
dotnet build Salutia.MobileApp/Salutia.MobileApp.csproj -t:Run -f net8.0-ios
```

#### Windows

```powershell
# Compilar
dotnet build "Salutia.MobileApp\Salutia.MobileApp.csproj" -f net8.0-windows10.0.19041.0

# Ejecutar
dotnet run --project "Salutia.MobileApp\Salutia.MobileApp.csproj" -f net8.0-windows10.0.19041.0
```

---

## ?? Plataformas Soportadas

| Plataforma | Versión Mínima | Versión Objetivo | Estado |
|------------|----------------|------------------|--------|
| **Android** | 5.0 (API 21) | 14.0 (API 34) | ? Soportado |
| **iOS** | 11.0 | 18.0 | ? Soportado |
| **macOS** | 10.15 | 15.0 | ? Soportado (Catalyst) |
| **Windows** | 10 (1809) | 11 (22000) | ? Soportado |

---

## ?? Diseño y UI

### Paleta de Colores

```css
--salutia-primary: #1b6ec2    /* Azul principal */
--salutia-secondary: #6c757d  /* Gris */
--salutia-success: #28a745    /* Verde */
--salutia-danger: #dc3545  /* Rojo */
--salutia-warning: #ffc107    /* Amarillo */
--salutia-info: #17a2b8       /* Cyan */
```

### Componentes UI

#### Bottom Navigation Bar

Navegación principal con 4 secciones:
- ?? **Inicio**: Dashboard principal
- ?? **Citas**: Gestión de citas médicas
- ?? **Salud**: Datos de salud y monitoreo
- ?? **Perfil**: Configuración y perfil del usuario

#### Cards Interactivas

Diseño touch-friendly con:
- Mínimo 44x44px para elementos táctiles
- Feedback visual al tocar
- Animaciones suaves

#### Formularios

- Inputs con padding generoso (12px)
- Validación en tiempo real
- Mensajes de error claros

---

## ?? Integración con la API Web

### Configuración del HttpClient

```csharp
// En MauiProgram.cs
builder.Services.AddHttpClient("SalutiaAPI", client =>
{
    client.BaseAddress = new Uri("https://localhost:7213/");
    client.Timeout = TimeSpan.FromSeconds(30);
});
```

### Servicios Compartidos

Los modelos y servicios están definidos en **Salutia.Shared**:

```csharp
// IAuthService.cs
public interface IAuthService
{
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse> RegisterAsync(RegisterRequest request);
    Task<bool> LogoutAsync();
    Task<User?> GetCurrentUserAsync();
    Task<bool> IsAuthenticatedAsync();
}
```

### Implementar Servicio de Auth (TODO)

```csharp
// En Salutia.MobileApp/Services/AuthService.cs
public class AuthService : IAuthService
{
    private readonly HttpClient _httpClient;
    
    public AuthService(IHttpClientFactory httpClientFactory)
    {
    _httpClient = httpClientFactory.CreateClient("SalutiaAPI");
  }
  
    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var response = await _httpClient.PostAsJsonAsync("/api/auth/login", request);
   return await response.Content.ReadFromJsonAsync<AuthResponse>();
    }
    
    // ... implementar otros métodos
}
```

---

## ?? Agregar Nuevas Páginas

### Paso 1: Crear el Componente Razor

```razor
<!-- Salutia.MobileApp/Components/Pages/NewPage.razor -->
@page "/newpage"

<PageTitle>Nueva Página - Salutia</PageTitle>

<div class="container">
    <h1>Nueva Página</h1>
  <p>Contenido aquí...</p>
</div>

@code {
    [Inject] private NavigationManager? NavigationManager { get; set; }
    
    protected override void OnInitialized()
    {
        // Lógica de inicialización
    }
}
```

### Paso 2: Agregar Navegación

```razor
<!-- En MainLayout.razor -->
<a href="/newpage" class="nav-link text-center">
    <i class="bi bi-star fs-4"></i>
    <div class="small">Nueva</div>
</a>
```

---

## ?? Autenticación y Seguridad

### Almacenamiento Seguro

Usar **SecureStorage** de MAUI para tokens:

```csharp
// Guardar token
await SecureStorage.SetAsync("auth_token", token);

// Recuperar token
string token = await SecureStorage.GetAsync("auth_token");

// Eliminar token
SecureStorage.Remove("auth_token");
```

### Biometría

```csharp
// Verificar si hay biometría disponible
bool isBiometricAvailable = await BiometricAuthentication.IsAvailableAsync();

// Autenticar con biometría
var result = await BiometricAuthentication.AuthenticateAsync(
  "Autenticar para acceder a Salutia",
    "Usa tu huella o Face ID"
);

if (result.Authenticated)
{
    // Autenticación exitosa
}
```

---

## ?? Funcionalidades Específicas de Plataforma

### Android

#### Permisos

```xml
<!-- Platforms/Android/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

#### Notificaciones

```csharp
// En Platforms/Android/MainActivity.cs
public class MainActivity : MauiAppCompatActivity
{
    protected override void OnCreate(Bundle savedInstanceState)
    {
     base.OnCreate(savedInstanceState);
  
    // Solicitar permisos de notificación en Android 13+
        if (Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu)
    {
  RequestPermissions(new[] { 
                Manifest.Permission.PostNotifications 
        }, 0);
      }
    }
}
```

### iOS

#### Info.plist

```xml
<!-- Platforms/iOS/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Salutia necesita acceso a la cámara para escanear códigos QR</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Salutia necesita tu ubicación para encontrar centros médicos cercanos</string>
```

#### App Transport Security

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## ?? Testing

### Unit Tests

```csharp
// Salutia.MobileApp.Tests/AuthServiceTests.cs
[Fact]
public async Task LoginAsync_ValidCredentials_ReturnsSuccess()
{
    // Arrange
    var authService = new AuthService(mockHttpClientFactory);
    var request = new LoginRequest 
    { 
        Email = "test@example.com", 
        Password = "Password123!" 
    };
    
    // Act
 var result = await authService.LoginAsync(request);
    
    // Assert
    Assert.True(result.Success);
}
```

### UI Tests

```csharp
// Usar Appium para tests de UI
[Test]
public void LoginPage_ValidCredentials_NavigatesToHome()
{
    // Arrange
    var loginPage = new LoginPage(driver);
    
  // Act
    loginPage.EnterEmail("test@example.com");
    loginPage.EnterPassword("Password123!");
    loginPage.ClickLogin();
    
// Assert
    Assert.IsTrue(homePage.IsDisplayed());
}
```

---

## ?? Publicación

### Android (Google Play Store)

```powershell
# Generar AAB para producción
dotnet publish "Salutia.MobileApp\Salutia.MobileApp.csproj" `
  -f net8.0-android `
  -c Release `
  -p:AndroidKeyStore=true `
  -p:AndroidSigningKeyStore=salutia.keystore `
  -p:AndroidSigningKeyAlias=salutia `
  -p:AndroidSigningKeyPass=$env:KEY_PASSWORD `
  -p:AndroidSigningStorePass=$env:STORE_PASSWORD
```

El AAB se generará en:
```
Salutia.MobileApp\bin\Release\net8.0-android\publish\
```

### iOS (App Store)

```bash
# En Mac, generar IPA para producción
dotnet publish Salutia.MobileApp/Salutia.MobileApp.csproj \
  -f net8.0-ios \
  -c Release \
  -p:ArchiveOnBuild=true \
  -p:RuntimeIdentifier=ios-arm64
```

Luego usar **Xcode** o **Application Loader** para subir a App Store Connect.

---

## ?? Troubleshooting

### Problema: "No suitable Android SDK found"

**Solución**:
```powershell
# Instalar Android SDK
$env:ANDROID_HOME = "C:\Program Files (x86)\Android\android-sdk"
dotnet workload install maui-android
```

### Problema: Error al compilar para iOS en Windows

**Solución**: iOS solo se puede compilar en Mac. Opciones:
1. Usar Mac Build Host en Visual Studio
2. Usar un servicio CI/CD con agentes Mac (Azure DevOps, GitHub Actions)
3. Compilar localmente en un Mac

### Problema: "INSTALL_FAILED_UPDATE_INCOMPATIBLE"

**Solución**:
```powershell
# Desinstalar versión antigua del emulador/dispositivo
adb uninstall com.companyname.salutia_mobileapp

# Volver a compilar y desplegar
dotnet build -t:Run -f net8.0-android
```

### Problema: Blazor no carga en la app

**Solución**:
1. Verificar que `index.html` está en `wwwroot/`
2. Verificar que `blazor.webview.js` se carga correctamente
3. Revisar logs en Output ? Debug

```csharp
// Agregar logging detallado
#if DEBUG
builder.Logging.SetMinimumLevel(LogLevel.Debug);
#endif
```

---

## ?? Próximos Pasos

### Corto Plazo
- [ ] Implementar servicio de autenticación completo
- [ ] Agregar almacenamiento offline con SQLite
- [ ] Implementar notificaciones push
- [ ] Agregar escaneo de códigos QR (para 2FA)

### Medio Plazo
- [ ] Integración con APIs de salud (Apple Health, Google Fit)
- [ ] Recordatorios de medicamentos
- [ ] Chat con médicos
- [ ] Videollamadas

### Largo Plazo
- [ ] Modo offline completo
- [ ] Sincronización inteligente
- [ ] Wearables integration
- [ ] IA para análisis de salud

---

## ?? Recursos Adicionales

### Documentación Oficial
- [.NET MAUI Documentation](https://learn.microsoft.com/dotnet/maui/)
- [Blazor Hybrid](https://learn.microsoft.com/aspnet/core/blazor/hybrid/)
- [CommunityToolkit.Maui](https://learn.microsoft.com/dotnet/communitytoolkit/maui/)

### Tutoriales y Guías
- [Getting Started with .NET MAUI](https://learn.microsoft.com/dotnet/maui/get-started/)
- [Build your first Blazor Hybrid app](https://learn.microsoft.com/aspnet/core/blazor/hybrid/tutorials/)
- [Publishing MAUI apps](https://learn.microsoft.com/dotnet/maui/deployment/)

### Comunidad
- [.NET MAUI GitHub](https://github.com/dotnet/maui)
- [Stack Overflow - maui tag](https://stackoverflow.com/questions/tagged/maui)
- [.NET Community Discord](https://aka.ms/dotnet-discord)

---

## ?? Contribuir

Para contribuir al proyecto móvil:

1. Crea una rama feature: `git checkout -b feature/nueva-funcionalidad`
2. Haz tus cambios y commitea: `git commit -m "feat: nueva funcionalidad"`
3. Push a la rama: `git push origin feature/nueva-funcionalidad`
4. Abre un Pull Request

---

## ?? Licencia

Este proyecto es parte de Salutia y sigue la misma licencia que el proyecto principal.

---

**Última actualización**: 2025  
**Versión de la App**: 1.0.0 (Beta)  
**Plataformas**: Android, iOS, macOS, Windows
