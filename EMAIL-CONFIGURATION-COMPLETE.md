# ?? Configuración de Email Completada - Salutia

## ?? Resumen de Configuración

Se ha configurado exitosamente el servicio de correo electrónico SMTP para Salutia con los siguientes parámetros:

### Configuración SMTP

```json
{
  "EmailSettings": {
    "SmtpServer": "mail.iaparatodospodcast.com",
    "SmtpPort": 465,
    "SenderEmail": "notificaciones@iaparatodospodcast.com",
    "SenderName": "Salutia - Plataforma de Salud Ocupacional",
    "Username": "notificaciones@iaparatodospodcast.com",
    "Password": "********",
    "EnableSsl": true
  }
}
```

### ?? Cambios Realizados

#### 1. **appsettings.json**
- ? Configurado SMTP server: `mail.iaparatodospodcast.com`
- ? Puerto: `465` (SSL/TLS implícito)
- ? Credenciales configuradas
- ? SSL habilitado

#### 2. **EmailService.cs**
- ? Corregida la lógica de conexión SMTP
- ? Puerto 465 usa `SecureSocketOptions.SslOnConnect`
- ? Cambio de `UseSsl` a `EnableSsl` para consistencia
- ? Plantillas HTML profesionales para:
  - Confirmación de email
  - Recuperación de contraseña
  - Email de bienvenida

#### 3. **UserManagementService.cs**
- ? Agregado `IEmailSender<ApplicationUser>`
- ? Agregado `IHttpContextAccessor` para construir URLs
- ? Implementado envío de email en `RegisterIndependentUserAsync`
- ? Implementado envío de email en `RegisterEntityAsync`
- ? Manejo de errores sin fallar el registro

#### 4. **Program.cs**
- ? `RequireConfirmedAccount` configurado en `false` para desarrollo
- ?? **IMPORTANTE**: Cambiar a `true` en producción

## ?? Cómo Probar

### Opción 1: Registrar un Nuevo Usuario

1. **Inicia la aplicación**
   ```bash
   F5 en Visual Studio
   ```

2. **Navega a registro**
   - Ve a `/Account/ChooseRegistrationType`
   - Selecciona "Usuario Independiente" o "Entidad"

3. **Completa el formulario**
   - Usa un email real para recibir la confirmación
   - Completa todos los campos requeridos

4. **Verifica tu bandeja**
   - Deberías recibir un email desde `notificaciones@iaparatodospodcast.com`
   - El asunto será: "Confirma tu correo electrónico - Salutia"
   - Haz clic en el enlace de confirmación

5. **Inicia sesión**
   - Una vez confirmado, inicia sesión con tus credenciales

### Opción 2: Usuario Existente (elpecodm@hotmail.com)

#### Confirmar manualmente en la base de datos:

1. **Ejecuta el script SQL** (`CONFIRM-EMAIL-elpecodm.sql`):
   ```sql
   UPDATE AspNetUsers
   SET EmailConfirmed = 1
   WHERE Email = 'elpecodm@hotmail.com';
   ```

2. **Inicia sesión**
   - Email: `elpecodm@hotmail.com`
   - Contraseña: (la que usaste al registrarte)

## ?? Tipos de Emails Configurados

### 1. **Email de Confirmación**
- **Cuándo**: Al registrar una nueva cuenta
- **Propósito**: Verificar la dirección de email
- **Asunto**: "Confirma tu correo electrónico - Salutia"
- **Contenido**: Botón con enlace de confirmación

### 2. **Email de Bienvenida**
- **Cuándo**: Después de confirmar el email
- **Propósito**: Dar la bienvenida y explicar funcionalidades
- **Asunto**: "¡Bienvenido/a a Salutia!"
- **Contenido**: Lista de funcionalidades disponibles

### 3. **Recuperación de Contraseña**
- **Cuándo**: Al solicitar reseteo de contraseña
- **Propósito**: Enviar enlace para crear nueva contraseña
- **Asunto**: "Recuperación de Contraseña - Salutia"
- **Contenido**: Botón con enlace temporal (1 hora)

## ?? Verificación de Logs

Puedes verificar el envío de emails en los logs de la aplicación:

```
Salutia_Wep_App.Services.EmailService: Information: Email enviado exitosamente a {Email}
Salutia_Wep_App.Services.UserManagementService: Information: Email de confirmación enviado a: {Email}
```

Si hay errores:
```
Salutia_Wep_App.Services.EmailService: Error: Error al enviar email a {Email}
Salutia_Wep_App.Services.UserManagementService: Warning: No se pudo enviar email de confirmación a {Email}
```

## ?? Solución de Problemas

### El email no llega

1. **Verifica spam/correo no deseado**
   - Los emails pueden ser marcados como spam

2. **Verifica la configuración SMTP**
   - Asegúrate de que el firewall permita conexiones al puerto 465
   - Verifica que las credenciales sean correctas

3. **Revisa los logs**
   - Busca mensajes de error en la ventana de Output de Visual Studio
   - Panel: "Depurar"

4. **Verifica la conexión**
   Puedes usar telnet para verificar:
   ```bash
   telnet mail.iaparatodospodcast.com 465
   ```

### Error "Unable to connect to the remote server"

- **Causa**: El servidor SMTP puede estar bloqueado por firewall
- **Solución**: Verifica reglas de firewall o antivirus

### Error "Authentication failed"

- **Causa**: Credenciales incorrectas
- **Solución**: Verifica usuario y contraseña en `appsettings.json`

## ?? Configuración para Producción

Cuando despliegues a producción:

1. **Habilitar confirmación obligatoria**
   ```csharp
   // En Program.cs
   options.SignIn.RequireConfirmedAccount = true;
   ```

2. **Usar variables de entorno**
   ```bash
   EmailSettings__Password="TuPasswordSegura"
   ```
   
   O en Azure App Service:
   - Configuration ? Application settings
   - Agregar: `EmailSettings__Password` = `TuPasswordSegura`

3. **Habilitar SSL/TLS**
   - Asegúrate de que `EnableSsl` esté en `true`
   - Usa puerto 465 para SSL implícito
   - O puerto 587 para STARTTLS

4. **Monitorear envíos**
   - Implementa logging de todos los envíos
   - Configura alertas para fallos de envío

## ?? Notas Importantes

- ?? **Seguridad**: La contraseña del email está en `appsettings.json`. En producción, usa Azure Key Vault o variables de entorno.
- ? **Confirmación**: Actualmente NO es obligatoria (`RequireConfirmedAccount = false`) para facilitar desarrollo.
- ?? **Remitente**: Todos los emails se envían desde `notificaciones@iaparatodospodcast.com`
- ?? **Puerto 465**: Usa SSL/TLS implícito (conexión cifrada desde el inicio)

## ?? Próximos Pasos

1. **Probar el registro** de un nuevo usuario
2. **Verificar recepción** del email de confirmación
3. **Confirmar email** haciendo clic en el enlace
4. **Recibir email** de bienvenida automáticamente
5. **Probar recuperación** de contraseña si es necesario

---

? **Configuración completada y lista para usar**

Para cualquier ajuste adicional, revisa los archivos:
- `Salutia Wep App\appsettings.json`
- `Salutia Wep App\Services\EmailService.cs`
- `Salutia Wep App\Services\UserManagementService.cs`
