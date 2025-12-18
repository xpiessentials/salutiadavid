# Solución de Problemas Comunes en Salutia

## Problemas Resueltos

### ? Error: "Failed to load resource: Salutia%20Wep%20App.styles.css 404"

**Causa**: El archivo CSS scoped generado por Blazor usa guiones bajos (`_`) en lugar de espacios, pero el HTML estaba referenciando el archivo con espacios.

**Solución Aplicada**: 
- Corregido en `Components/App.razor`
- Cambio de: `<link rel="stylesheet" href="Salutia Wep App.styles.css" />`
- A: `<link rel="stylesheet" href="Salutia_Wep_App.styles.css" />`

**Estado**: ? RESUELTO

---

### ?? Error: "Uncaught (in promise) SyntaxError: [object Object] is not valid JSON"

**Causa Posible**: Este error puede ocurrir por varias razones:
1. Problemas con la base de datos no inicializada
2. Errores en la configuración de Identity
3. Problemas con archivos estáticos faltantes

**Soluciones a Aplicar**:

#### 1. Aplicar Migraciones de Base de Datos

La base de datos debe crearse antes de usar la aplicación:

```powershell
# Desde la raíz del proyecto
dotnet ef database update --project "Salutia Wep App" --startup-project "Salutia Wep App"
```

#### 2. Verificar que SQL Server Express esté en ejecución

```powershell
# Verificar el servicio
Get-Service -Name "MSSQL$SQLEXPRESS"

# Si no está corriendo, iniciarlo
Start-Service -Name "MSSQL$SQLEXPRESS"
```

#### 3. Limpiar y Reconstruir el Proyecto

```powershell
# Limpiar
dotnet clean

# Reconstruir
dotnet build

# Ejecutar
dotnet run --project "Salutia.AppHost\Salutia.AppHost.csproj"
```

---

## Verificación de Archivos Estáticos

Asegúrate de que los siguientes archivos existen en `wwwroot`:

```
Salutia Wep App/wwwroot/
??? app.css ?
??? favicon.png ?
??? bootstrap/
?   ??? bootstrap.min.css ?
??? _framework/ (generado automáticamente)
```

---

## Pasos para Iniciar la Aplicación Correctamente

### Método 1: Usando .NET Aspire (Recomendado)

```powershell
# 1. Aplicar migraciones (solo la primera vez)
dotnet ef database update --project "Salutia Wep App" --startup-project "Salutia Wep App"

# 2. Ejecutar desde el AppHost
dotnet run --project "Salutia.AppHost\Salutia.AppHost.csproj"
```

### Método 2: Ejecutar solo la aplicación Blazor

```powershell
# 1. Aplicar migraciones (solo la primera vez)
dotnet ef database update --project "Salutia Wep App" --startup-project "Salutia Wep App"

# 2. Ejecutar la aplicación
dotnet run --project "Salutia Wep App\Salutia Wep App.csproj"
```

### Método 3: Desde Visual Studio

1. **Establecer proyecto de inicio**: Clic derecho en `Salutia.AppHost` ? "Set as Startup Project"
2. **Ejecutar**: Presionar F5 o clic en el botón ?? "Start"
3. Se abrirá el Dashboard de Aspire en el navegador
4. Desde el dashboard, acceder a la aplicación

---

## Verificación de Conectividad a la Base de Datos

### Probar conexión con SQLCMD

```powershell
sqlcmd -S LAPTOP-DAVID\SQLEXPRESS -E -Q "SELECT @@VERSION"
```

### Verificar que la base de datos existe

```powershell
sqlcmd -S LAPTOP-DAVID\SQLEXPRESS -E -Q "SELECT name FROM sys.databases WHERE name = 'Salutia'"
```

### Ver las tablas creadas

```powershell
sqlcmd -S LAPTOP-DAVID\SQLEXPRESS -d Salutia -E -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES"
```

---

## Problemas Comunes y Soluciones

### Problema: "An unhandled error has occurred" al cargar la página

**Solución**:
1. Verifica los logs del navegador (F12 ? Console)
2. Verifica los logs de Visual Studio (Output ? Debug)
3. Asegúrate de que la base de datos está creada y las migraciones aplicadas
4. Verifica que SQL Server Express está en ejecución

### Problema: Imágenes no cargan (iconos de Bootstrap)

**Causa**: Los iconos de Bootstrap están definidos como SVG inline en el CSS

**Verificación**: 
- Abre `Components/Layout/NavMenu.razor.css`
- Los iconos deben estar definidos como `background-image: url("data:image/svg+xml,...")`

### Problema: Error 404 en archivos CSS

**Solución**:
1. Limpia el proyecto: `dotnet clean`
2. Reconstruye: `dotnet build`
3. Verifica que `App.razor` usa `Salutia_Wep_App.styles.css` (con guiones bajos)

---

## Herramientas de Diagnóstico

### Verificar errores de compilación

```powershell
dotnet build "Salutia Wep App\Salutia Wep App.csproj" --verbosity detailed
```

### Ver logs detallados al ejecutar

```powershell
dotnet run --project "Salutia Wep App\Salutia Wep App.csproj" --verbosity detailed
```

### Limpiar caché de NuGet

```powershell
dotnet nuget locals all --clear
```

---

## Checklist de Verificación Antes de Ejecutar

- [ ] SQL Server Express está en ejecución
- [ ] La cadena de conexión es correcta en `appsettings.json`
- [ ] Las migraciones están aplicadas (`dotnet ef database update`)
- [ ] El proyecto compila sin errores (`dotnet build`)
- [ ] Los archivos en `wwwroot` existen (bootstrap, app.css)
- [ ] El archivo `App.razor` usa `Salutia_Wep_App.styles.css`

---

## URLs de la Aplicación

Cuando ejecutas con .NET Aspire:
- **Dashboard de Aspire**: https://localhost:17141 (el puerto puede variar)
- **Aplicación Blazor**: https://localhost:59982 (el puerto puede variar)

Las URLs exactas se mostrarán en la consola al iniciar la aplicación.

---

## Contacto y Soporte

Para problemas adicionales, revisa:
1. Los logs en la consola de Visual Studio
2. Los logs en el navegador (F12 ? Console)
3. El archivo `DATABASE_SETUP.md` para problemas relacionados con la base de datos
4. La documentación de .NET Aspire: https://learn.microsoft.com/dotnet/aspire/

---

## Notas Importantes

?? **Antes de hacer commit a Git**: Asegúrate de no subir información sensible en `appsettings.json`. Usa `appsettings.Development.json` para configuraciones locales.

?? **Base de Datos en Desarrollo**: La base de datos actual está configurada para desarrollo local. No uses esta configuración en producción.

?? **Migraciones**: Siempre crea una nueva migración después de modificar el `ApplicationDbContext`.
