# ?? GUÍA: Configurar Contraseña de Aplicación de Gmail

## ? Problema Actual

Error: `535: 5.7.8 Username and Password not accepted`

**Causa**: La contraseña en `appsettings.json` no es una contraseña de aplicación válida de Gmail.

---

## ? Solución: Generar Contraseña de Aplicación

### Paso 1: Habilitar Verificación en 2 Pasos

1. **Inicia sesión en Gmail**: https://mail.google.com con `salutiadesarrollo@gmail.com`

2. **Ve a tu cuenta de Google**: 
   - Click en tu foto de perfil (esquina superior derecha)
   - Click en "Gestionar tu cuenta de Google"

3. **Ve a Seguridad**:
   - En el menú lateral, click en "Seguridad"
   - O directamente: https://myaccount.google.com/security

4. **Habilita la verificación en 2 pasos**:
   - Busca la sección "Cómo inicias sesión en Google"
   - Click en "Verificación en 2 pasos"
- Click en "Comenzar"
   - Sigue los pasos (te pedirá tu teléfono)
   - **Importante**: Completa todo el proceso

---

### Paso 2: Generar Contraseña de Aplicación

1. **Una vez habilitada la verificación en 2 pasos**, regresa a:
   https://myaccount.google.com/security

2. **Busca "Contraseñas de aplicaciones"**:
   - Está en la sección "Cómo inicias sesión en Google"
   - O ve directamente a: https://myaccount.google.com/apppasswords

3. **Si no ves "Contraseñas de aplicaciones"**:
   - Asegúrate de haber completado la verificación en 2 pasos
   - Espera unos minutos
   - Recarga la página

4. **Genera la contraseña**:
   - Click en "Contraseñas de aplicaciones"
   - Ingresa tu contraseña de Gmail si te la pide
   - En "Seleccionar app": Elige "Otro (nombre personalizado)"
   - Escribe: `Salutia Web Application`
   - Click en "Generar"

5. **Copia la contraseña**:
   - Gmail mostrará una contraseña de 16 caracteres
   - Ejemplo: `abcd efgh ijkl mnop` (sin espacios reales, solo visual)
   - **¡Copia esta contraseña AHORA! No podrás verla de nuevo**

---

### Paso 3: Actualizar appsettings.json

1. **Abre el archivo**: `Salutia Wep App\appsettings.json`

2. **Reemplaza la contraseña**:

```json
"EmailSettings": {
  "SmtpServer": "smtp.gmail.com",
  "SmtpPort": 587,
  "SenderName": "Salutia - Sistema de Salud",
  "SenderEmail": "salutiadesarrollo@gmail.com",
  "Username": "salutiadesarrollo@gmail.com",
  "Password": "PEGA_AQUI_LA_CONTRASEÑA_DE_16_CARACTERES",
  "UseSsl": true
}
```

3. **IMPORTANTE**: 
   - Pega la contraseña **SIN ESPACIOS**
   - Gmail la muestra con espacios solo para facilitar la lectura
   - Ejemplo: Si ves `abcd efgh ijkl mnop`, pégala como `abcdefghijklmnop`

4. **Guarda el archivo**

---

### Paso 4: Reiniciar la Aplicación

1. **Detén la aplicación** (Shift+F5 en Visual Studio)

2. **Inicia de nuevo** (F5)

3. **Prueba el envío**:
   - Ve a: https://localhost:7213/test/send-email
   - Haz click en "Enviar Email Simple"
   - Debería funcionar ahora

---

## ?? Verificación Rápida

### ? Checklist antes de probar:

- [ ] Verificación en 2 pasos HABILITADA en Gmail
- [ ] Contraseña de aplicación GENERADA correctamente
- [ ] Contraseña COPIADA sin espacios
- [ ] `appsettings.json` ACTUALIZADO con la nueva contraseña
- [ ] Archivo GUARDADO
- [ ] Aplicación REINICIADA

---

## ?? Solución de Problemas

### Problema: No veo "Contraseñas de aplicaciones"

**Causa**: Verificación en 2 pasos no está habilitada o no se completó correctamente.

**Solución**:
1. Ve a: https://myaccount.google.com/security
2. Verifica que "Verificación en 2 pasos" esté ACTIVADA
3. Si no está, actívala primero
4. Espera 5-10 minutos
5. Refresca la página

### Problema: Gmail dice "Contraseña incorrecta"

**Causa**: La contraseña tiene espacios o caracteres extra.

**Solución**:
1. Vuelve a copiar la contraseña de aplicación
2. Pégala en un editor de texto primero
3. Elimina TODOS los espacios
4. Copia de nuevo (sin espacios)
5. Pega en `appsettings.json`

### Problema: Error 535 persiste

**Soluciones**:

1. **Genera una NUEVA contraseña de aplicación**:
   - Elimina la anterior en Google
   - Crea una nueva
   - Actualiza `appsettings.json`

2. **Verifica el email**:
   - Asegúrate de que `salutiadesarrollo@gmail.com` es correcto
   - Username y SenderEmail deben ser iguales

3. **Verifica SMTP**:
   ```json
   "SmtpServer": "smtp.gmail.com",  // Debe ser exactamente esto
   "SmtpPort": 587,              // Puerto correcto
   "UseSsl": true             // Debe ser true
   ```

---

## ?? Alternativa: Usar Otro Proveedor

Si Gmail sigue dando problemas, considera usar:

### SendGrid (Recomendado para producción):
- Gratis hasta 100 emails/día
- Más confiable que Gmail
- No requiere contraseña de aplicación

### Configuración SendGrid:
```json
"EmailSettings": {
  "SmtpServer": "smtp.sendgrid.net",
  "SmtpPort": 587,
  "SenderName": "Salutia - Sistema de Salud",
  "SenderEmail": "salutiadesarrollo@gmail.com",
  "Username": "apikey",
  "Password": "TU_API_KEY_DE_SENDGRID",
  "UseSsl": true
}
```

### Mailgun:
- Gratis hasta 100 emails/día
- Excelente para desarrollo

### Gmail para Desarrollo:
- Habilitar "Acceso de aplicaciones menos seguras" (NO recomendado)
- Usar OAuth 2.0 (complejo)
- Usar contraseña de aplicación (lo que estamos haciendo)

---

## ? Resumen de Pasos

1. **Habilitar 2FA** en Gmail
2. **Generar contraseña** de aplicación
3. **Copiar** la contraseña (sin espacios)
4. **Actualizar** `appsettings.json`
5. **Guardar** el archivo
6. **Reiniciar** la aplicación
7. **Probar** el envío

---

## ?? Notas Importantes

- ?? **NUNCA** uses tu contraseña personal de Gmail
- ? **SIEMPRE** usa contraseñas de aplicación
- ?? **NO** compartas la contraseña de aplicación
- ?? **GUARDA** la contraseña en un lugar seguro
- ?? **REGENERA** la contraseña si la pierdes
- ??? **ELIMINA** contraseñas de aplicación que no uses

---

## ?? Después de Configurar

Una vez que funcione:

1. **Prueba todos los tipos de correo**:
   - Email simple
   - Email de bienvenida
   - Email de reseteo de contraseña

2. **Documenta la contraseña**:
   - Guárdala en un gestor de contraseñas
   - No la dejes en `appsettings.json` en producción
   - Usa variables de entorno o Azure Key Vault

3. **Elimina la página de prueba**:
   ```
   Salutia Wep App\Components\Pages\TestSendEmail.razor
   ```

---

**Estado Actual**: ? Contraseña inválida  
**Siguiente Paso**: Generar contraseña de aplicación válida  
**Tiempo Estimado**: 5-10 minutos
