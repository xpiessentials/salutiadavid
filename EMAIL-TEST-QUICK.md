# ?? Prueba Rápida de Email - INSTRUCCIONES

## ? Pasos Simples para Probar el Email

### 1?? Reiniciar la Aplicación

1. Detén la aplicación actual (**Shift + F5**)
2. Inicia nuevamente (**F5**)
3. Espera a que aparezca el navegador

### 2?? Ejecutar la Prueba

Abre una **nueva pestaña** en tu navegador y ve a:

```
https://localhost:7213/api/Test/test-email?to=elpecodm@hotmail.com
```

### 3?? Ver el Resultado

Verás algo como esto en el navegador:

**? SI FUNCIONA:**
```json
{
  "success": true,
  "message": "? Email de prueba enviado exitosamente a elpecodm@hotmail.com",
  "details": {
    "to": "elpecodm@hotmail.com",
    "subject": "? Prueba de Email - Salutia",
    "server": "mail.iaparatodospodcast.com",
    "port": 465,
    "ssl": true
  }
}
```

**? SI HAY ERROR:**
```json
{
  "success": false,
  "message": "? Error al enviar el email de prueba",
  "error": "[Descripción del error aquí]"
}
```

### 4?? Revisar tu Email

1. Abre **Outlook.com** (o tu cliente de email)
2. Busca en **Bandeja de entrada**
3. Si no está, busca en **Correo no deseado (Spam)**
4. Busca un email de: `notificaciones@iaparatodospodcast.com`
5. Asunto: `? Prueba de Email - Salutia`

### 5?? Revisar Logs en Visual Studio

En la ventana **Output** de Visual Studio (parte inferior) verás:

**? ÉXITO:**
```
=== INICIANDO PRUEBA DE EMAIL ===
Destinatario: elpecodm@hotmail.com
Enviando email de prueba...
Email enviado exitosamente a elpecodm@hotmail.com
=== EMAIL ENVIADO EXITOSAMENTE ===
```

**? ERROR:**
```
=== ERROR AL ENVIAR EMAIL DE PRUEBA ===
Mensaje: [Descripción del error]
```

---

## ?? Diagnóstico Rápido

### ?? Si dice "Unable to connect"

**Problema:** No puede conectarse al servidor SMTP

**Solución:** Verifica tu conexión a Internet y firewall

### ?? Si dice "Authentication failed"

**Problema:** Usuario o contraseña incorrectos

**Verificar en `appsettings.json`:**
```json
"Username": "notificaciones@iaparatodospodcast.com",
"Password": "Joramir2025"
```

### ?? Si el email no llega (pero dice success)

**Posibles causas:**
1. **Está en SPAM** - Revisa correo no deseado
2. **Tarda en llegar** - Espera 5 minutos
3. **Email bloqueado** - Verifica que el email de destino esté activo

---

## ?? Configuración Actual

```
???  Servidor:  mail.iaparatodospodcast.com
??  Puerto:    465 (SSL/TLS)
??  Remitente:  notificaciones@iaparatodospodcast.com
??  Usuario:   notificaciones@iaparatodospodcast.com
??  SSL:       Habilitado (SslOnConnect)
```

---

## ?? URLs de Prueba

### Probar con tu email:
```
https://localhost:7213/api/Test/test-email?to=elpecodm@hotmail.com
```

### Probar con otro email:
```
https://localhost:7213/api/Test/test-email?to=TU_EMAIL@ejemplo.com
```

### Ver configuración:
```
https://localhost:7213/api/Test/email-config
```

---

## ?? Checklist de Verificación

Antes de ejecutar la prueba, verifica:

- [ ] La aplicación está corriendo (navegador abierto)
- [ ] Tienes conexión a Internet
- [ ] El email de destino existe
- [ ] Visual Studio muestra logs activos
- [ ] El puerto es 7213 (HTTPS)

---

## ?? Si Nada Funciona

1. **Copia los logs** de la ventana Output
2. **Copia el mensaje de error** del navegador
3. **Toma captura** de pantalla
4. **Comparte** para análisis adicional

---

## ? ¿Funcionó?

Si ves `"success": true` Y recibes el email, entonces:

? **El sistema de correo está funcionando perfectamente**
? **Puedes probar el registro de usuarios**
? **Puedes probar la recuperación de contraseña**
? **El sistema está listo para producción**

---

**?? Creado:** 2025-01-19
**?? Sistema:** Salutia Email Test
