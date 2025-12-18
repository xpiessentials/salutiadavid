# ?? Guía de Prueba de Email - Salutia

## ? Controlador de Prueba Creado

He creado un controlador API especial (`TestController.cs`) **solo para desarrollo** que permite probar el envío de emails directamente.

## ?? Cómo Realizar la Prueba

### Opción 1: Usando el Navegador (Recomendado)

1. **Asegúrate de que la aplicación esté corriendo** (F5 en Visual Studio)

2. **Abre tu navegador** y visita una de estas URLs:

   **Para enviar a tu email:**
   ```
   https://localhost:7213/api/Test/test-email?to=elpecodm@hotmail.com
   ```

   **Para enviar a otro email:**
   ```
   https://localhost:7213/api/Test/test-email?to=TU_EMAIL@ejemplo.com
   ```

3. **Verás una respuesta JSON** indicando si el email se envió exitosamente:

   ? **Éxito:**
   ```json
   {
     "success": true,
     "message": "? Email de prueba enviado exitosamente a elpecodm@hotmail.com",
     "details": {
       "to": "elpecodm@hotmail.com",
       "subject": "? Prueba de Email - Salutia",
       "server": "mail.iaparatodospodcast.com",
       "port": 465,
       "ssl": true,
       "sentAt": "2025-01-19T..."
     }
   }
   ```

   ? **Error:**
   ```json
   {
     "success": false,
     "message": "? Error al enviar el email de prueba",
     "error": "Mensaje del error",
     "details": {...}
   }
   ```

4. **Revisa tu bandeja de entrada** (o spam) en el email que especificaste

### Opción 2: Usando PowerShell

Ejecuta este comando en PowerShell:

```powershell
# Cambiar el email por el que quieras probar
$email = "elpecodm@hotmail.com"
Invoke-RestMethod -Uri "https://localhost:7213/api/Test/test-email?to=$email" -Method Get | ConvertTo-Json -Depth 3
```

### Opción 3: Usando cURL

```bash
curl "https://localhost:7213/api/Test/test-email?to=elpecodm@hotmail.com"
```

## ?? Ver Configuración del Email

Para verificar la configuración actual sin enviar un email:

```
https://localhost:7213/api/Test/email-config
```

Respuesta esperada:
```json
{
  "server": "mail.iaparatodospodcast.com",
  "port": 465,
  "ssl": true,
  "sender": "notificaciones@iaparatodospodcast.com",
  "senderName": "Salutia - Plataforma de Salud Ocupacional",
  "configured": true,
  "environment": "Development"
}
```

## ?? Revisar Logs Detallados

Los logs en Visual Studio mostrarán información detallada:

### ? Si funciona correctamente:

```
Salutia_Wep_App.Controllers.TestController: Information: === INICIANDO PRUEBA DE EMAIL ===
Salutia_Wep_App.Controllers.TestController: Information: Destinatario: elpecodm@hotmail.com
Salutia_Wep_App.Controllers.TestController: Information: Enviando email de prueba...
Salutia_Wep_App.Services.EmailService: Information: Email enviado exitosamente a elpecodm@hotmail.com
Salutia_Wep_App.Controllers.TestController: Information: === EMAIL ENVIADO EXITOSAMENTE ===
```

### ? Si hay un error:

```
Salutia_Wep_App.Controllers.TestController: Error: === ERROR AL ENVIAR EMAIL DE PRUEBA ===
Salutia_Wep_App.Controllers.TestController: Error: Mensaje: [Descripción del error]
Salutia_Wep_App.Controllers.TestController: Error: StackTrace: [Detalles técnicos]
```

## ?? Posibles Problemas y Soluciones

### Problema 1: "Unable to connect to the remote server"

**Causa:** El servidor SMTP no es alcanzable

**Soluciones:**
1. Verifica tu conexión a Internet
2. Verifica que el firewall no esté bloqueando el puerto 465
3. Verifica que el antivirus no esté bloqueando MailKit

**Prueba de conectividad:**
```powershell
Test-NetConnection -ComputerName mail.iaparatodospodcast.com -Port 465
```

### Problema 2: "Authentication failed"

**Causa:** Credenciales incorrectas

**Soluciones:**
1. Verifica el usuario en `appsettings.json`:
   ```json
   "Username": "notificaciones@iaparatodospodcast.com"
   ```

2. Verifica la contraseña:
   ```json
   "Password": "Joramir2025"
   ```

3. Verifica que la cuenta de email existe y está activa

### Problema 3: "5.7.1 Authentication Required"

**Causa:** El servidor SMTP requiere autenticación

**Solución:** Ya está configurado en `EmailService.cs`:
```csharp
await client.AuthenticateAsync(_emailSettings.Username, _emailSettings.Password);
```

### Problema 4: Email no llega pero no hay error

**Posibles causas:**

1. **El email está en SPAM** 
   - Revisa la carpeta de correo no deseado
   - Marca el remitente como seguro

2. **El servidor está rechazando silenciosamente**
   - Verifica la configuración del dominio
   - Contacta al administrador del servidor de correo

3. **El email tarda en llegar**
   - Espera 5-10 minutos
   - Los servidores SMTP a veces tienen delay

## ?? Verificaciones Técnicas

### 1. Verificar Configuración en appsettings.json

```json
{
  "EmailSettings": {
    "SmtpServer": "mail.iaparatodospodcast.com",
    "SmtpPort": 465,
    "SenderEmail": "notificaciones@iaparatodospodcast.com",
    "SenderName": "Salutia - Plataforma de Salud Ocupacional",
    "Username": "notificaciones@iaparatodospodcast.com",
    "Password": "Joramir2025",
    "EnableSsl": true
  }
}
```

### 2. Verificar que MailKit está instalado

```bash
dotnet list "Salutia Wep App" package | findstr MailKit
```

Debería mostrar:
```
> MailKit    [version]
```

### 3. Verificar Servicio Registrado en Program.cs

```csharp
builder.Services.AddScoped<IEmailService, EmailService>();
```

## ?? Contenido del Email de Prueba

El email que recibirás incluirá:

- ? Confirmación de que el sistema funciona
- ?? Detalles de la configuración SMTP
- ?? Fecha y hora de envío
- ?? Información del remitente
- ?? Lista de funcionalidades configuradas

## ?? Próximos Pasos

### Si la prueba es exitosa ?

1. ? El sistema de email está funcionando correctamente
2. ? Puedes probar el flujo completo de registro
3. ? Puedes probar la recuperación de contraseña
4. ? El sistema está listo para usar

### Si la prueba falla ?

1. ? Revisa los logs detallados en la consola
2. ? Verifica la configuración en `appsettings.json`
3. ? Verifica la conectividad con el servidor SMTP
4. ? Contacta al administrador del servidor de correo
5. ? Comparte los logs de error para análisis adicional

## ?? Seguridad

?? **IMPORTANTE:** 

- Este endpoint **solo funciona en modo Development**
- En producción, retorna `404 Not Found`
- No expone la contraseña del email
- Solo para pruebas internas

## ?? Comandos Útiles

### Reiniciar la aplicación
```powershell
# En Visual Studio: Shift + F5, luego F5
```

### Ver logs en tiempo real
```powershell
# Panel de Output en Visual Studio
# Seleccionar: "Depurar" o "Salutia Wep App"
```

### Limpiar y recompilar
```powershell
dotnet clean
dotnet build
```

---

## ?? Ejemplo de Uso Completo

1. **Iniciar la aplicación** (F5)
2. **Abrir el navegador**
3. **Ir a:** `https://localhost:7213/api/Test/test-email?to=elpecodm@hotmail.com`
4. **Ver respuesta JSON** con `success: true`
5. **Revisar email** en `elpecodm@hotmail.com`
6. **Verificar logs** en Visual Studio (Output window)

---

? **Sistema de prueba listo para usar**
?? Creado: 2025-01-19
