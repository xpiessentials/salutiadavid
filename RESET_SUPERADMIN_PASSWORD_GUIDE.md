# ?? GUÍA: Cambiar Contraseña del SuperAdmin

## ¿Olvidaste la contraseña del SuperAdmin?

No te preocupes, aquí hay **3 formas** de cambiarla:

---

## ? **MÉTODO 1: Script PowerShell (RECOMENDADO)**

Este es el método más fácil y seguro.

### Pasos:

1. **Abre PowerShell** en el directorio del proyecto
   ```powershell
   cd "D:\Desarrollos\Repos\Salutia"
   ```

2. **Ejecuta el script**
   ```powershell
   .\reset-superadmin-password.ps1
   ```

3. **Sigue las instrucciones**:
   - Ingresa la nueva contraseña
   - Confírmala
   - El script actualizará automáticamente la base de datos

4. **¡Listo!** Ahora puedes iniciar sesión con:
   - **Usuario**: `elpeco1@msn.com`
   - **Contraseña**: [la que acabas de establecer]

### Si el script falla:

Si obtienes un error de "No se puede ejecutar scripts", ejecuta esto primero:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Luego vuelve a ejecutar el script.

---

## ? **MÉTODO 2: SQL Server Management Studio**

Si prefieres usar SQL directamente:

### Pasos:

1. **Abre SQL Server Management Studio (SSMS)**

2. **Conéctate a tu servidor**:
   - Servidor: `LAPTOP-DAVID\SQLEXPRESS`
   - Autenticación: Windows

3. **Abre el archivo SQL**:
   ```
   D:\Desarrollos\Repos\Salutia\reset-superadmin-password.sql
   ```

4. **Ejecuta la primera consulta** para verificar que existe el usuario:
   ```sql
   SELECT Id, UserName, Email, EmailConfirmed
   FROM AspNetUsers
   WHERE LOWER(Email) = 'elpeco1@msn.com';
   ```

5. **Para cambiar la contraseña**, usa el script de PowerShell (método 1)
   - El SQL solo sirve para verificar, no para cambiar la contraseña
   - Necesitas generar un hash válido con ASP.NET Core Identity

---

## ? **MÉTODO 3: Desde la aplicación (Si aún tienes acceso)**

Si tienes acceso a la aplicación como administrador:

1. Inicia sesión como SuperAdmin (si recuerdas la contraseña)
2. Ve a **Account/Manage**
3. Selecciona **Cambiar contraseña**
4. Ingresa la contraseña actual y la nueva

---

## ?? **Verificar el cambio**

Después de cambiar la contraseña:

1. **Abre tu aplicación**: `https://localhost:7142` (o tu puerto)

2. **Haz clic en "Iniciar Sesión"**

3. **Ingresa las credenciales**:
   - Email: `elpeco1@msn.com`
   - Contraseña: [tu nueva contraseña]

4. **Verifica que puedes acceder** al Dashboard Admin

---

## ? **Problemas comunes**

### Error: "El usuario no existe"

Si el script dice que no encontró el usuario, verifica con esta consulta SQL:

```sql
USE Salutia;
GO

SELECT * FROM AspNetUsers;
```

Si no aparece ningún SuperAdmin, necesitas crearlo. Usa este script:
```powershell
.\create-superadmin.ps1
```

### Error: "No se puede conectar a la base de datos"

Verifica que SQL Server esté corriendo:
```powershell
.\test-database-connection.ps1
```

### Error: "La contraseña no cumple los requisitos"

La contraseña debe tener al menos:
- 6 caracteres (mínimo)
- Se recomienda: letras mayúsculas, minúsculas, números y símbolos
- Ejemplo: `Salutia2025!`

---

## ?? **Información del SuperAdmin**

- **Email**: `elpeco1@msn.com`
- **Username**: `elpeco1@msn.com`
- **Rol**: `SuperAdmin`
- **Permisos**: Acceso completo a toda la aplicación

---

## ?? **Siguientes pasos**

Una vez que hayas recuperado el acceso:

1. **Cambia la contraseña** a una segura que puedas recordar
2. **Guárdala en un lugar seguro** (gestor de contraseñas)
3. **Activa la autenticación de dos factores** (2FA):
   - Ve a Account/Manage
   - Selecciona "Autenticador"
   - Escanea el código QR

---

## ?? **Consejos de seguridad**

- ? Usa una contraseña fuerte y única
- ? Activa 2FA para mayor seguridad
- ? No compartas las credenciales de SuperAdmin
- ? Cambia la contraseña periódicamente
- ? Revisa los logs de acceso regularmente

---

## ?? **¿Necesitas más ayuda?**

Si ninguno de estos métodos funciona:

1. Revisa los logs de la aplicación
2. Verifica que la base de datos esté funcionando
3. Consulta el archivo `TROUBLESHOOTING.md`
4. Revisa la documentación en `CREATE_SUPERADMIN_GUIDE.md`

---

**Última actualización**: Enero 2025
